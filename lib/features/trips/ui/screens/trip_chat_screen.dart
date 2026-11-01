/// Qaddy's Trip Chat screen — the group conversation for one trip.
///
/// See `docs/features/trips-feature-integration.md`'s "Group Chat" section.
/// Messages live in the trips store. With no backend there is nobody on the
/// other end, so delivery ticks and the typing indicator are timed
/// placeholders (see [_TripChatScreenState._simulateDelivery]).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_chat_composer.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_message_bubble.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Trip Chat (route `/trips/:tripId/chat`).
class TripChatScreen extends ConsumerStatefulWidget {
  const TripChatScreen({required this.tripId, super.key});

  /// The trip whose chat is shown.
  final String tripId;

  @override
  ConsumerState<TripChatScreen> createState() => _TripChatScreenState();
}

class _TripChatScreenState extends ConsumerState<TripChatScreen> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Timer> _timers = <Timer>[];

  /// Who the placeholder typing indicator names, while it is showing.
  String? _typing;

  /// Messages sent in this visit; they slide in when they appear.
  final Set<String> _justSent = <String>{};

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _later(Duration after, VoidCallback action) {
    _timers.add(
      Timer(after, () {
        if (mounted) {
          action();
        }
      }),
    );
  }

  void _send() {
    final id = ref
        .read(tripsProvider.notifier)
        .sendMessage(widget.tripId, _text.text);
    if (id == null) {
      return;
    }
    _text.clear();
    _justSent.add(id);
    QaddyHaptics.light();
    _simulateDelivery(id);
  }

  /// Advances the message sent -> delivered -> read on a timer and, when the
  /// trip's chat settings allow, shows another member "typing" for a moment.
  /// Stands in for real delivery until there is a backend.
  void _simulateDelivery(String messageId) {
    final controller = ref.read(tripsProvider.notifier);
    final settings = ref.read(tripPlanProvider(widget.tripId)).chatSettings;
    final others = ref
        .read(tripPlanProvider(widget.tripId))
        .confirmedMembers
        .map((member) => member.displayName)
        .where((name) => name != currentUserName)
        .toList();

    _later(const Duration(milliseconds: 600), () {
      controller.setMessageStatus(
        widget.tripId,
        messageId,
        MessageStatus.delivered,
      );
    });
    if (settings.readReceipts) {
      _later(const Duration(milliseconds: 1600), () {
        controller.setMessageStatus(
          widget.tripId,
          messageId,
          MessageStatus.read,
        );
      });
    }
    if (settings.typingIndicators && others.isNotEmpty) {
      _later(const Duration(milliseconds: 900), () {
        setState(() => _typing = others.first);
        _scrollToLatest();
      });
      _later(const Duration(milliseconds: 3200), () {
        setState(() => _typing = null);
      });
    }
  }

  Widget _arrive(String id, Widget bubble) => _justSent.contains(id)
      ? QaddyFadeSlideIn(offset: 16, child: bubble)
      : bubble;

  /// The list is reversed, so offset 0 is the newest message.
  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      unawaited(
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    // Follow new messages unless the golfer has scrolled up to read history;
    // their own messages always pull the view down.
    ref.listen<List<TripMessage>>(
      tripPlanProvider(widget.tripId).select((plan) => plan.messages),
      (previous, next) {
        if (previous == null || next.length <= previous.length) {
          return;
        }
        final nearLatest = !_scroll.hasClients || _scroll.offset < 120;
        if (nearLatest || next.last.sender == currentUserName) {
          _scrollToLatest();
        }
      },
    );

    final items = _chatItems(plan.messages);

    return QaddyScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Trip Chat'),
            Text(
              '${trip.name} · ${plan.confirmedMembers.length} going',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
        actions: <Widget>[
          if (plan.chatSettings.muted)
            Padding(
              padding: EdgeInsets.only(right: spacing.md),
              child: Tooltip(
                message: 'Notifications muted',
                child: Icon(
                  Icons.notifications_off_outlined,
                  color: colours.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: plan.messages.isEmpty && _typing == null
                ? const QaddyEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    message:
                        'Say hello to the group — plan tee times, split '
                        'lifts, settle the bets.',
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: EdgeInsets.only(bottom: spacing.md),
                    itemCount: items.length + (_typing == null ? 0 : 1),
                    itemBuilder: (context, position) {
                      final typing = _typing;
                      if (typing != null && position == 0) {
                        return ChatTypingIndicator(name: typing);
                      }
                      // Items are oldest-first; the list runs newest-first.
                      final index = typing == null ? position : position - 1;
                      final item = items[items.length - 1 - index];
                      return switch (item) {
                        _DayItem(:final day) => ChatDaySeparator(day: day),
                        _MessageItem(:final message, :final startsRun) =>
                          _arrive(
                            message.id,
                            TripMessageBubble(
                              message: message,
                              isMine: message.sender == currentUserName,
                              startsRun: startsRun,
                              showReceipt: plan.chatSettings.readReceipts,
                            ),
                          ),
                      };
                    },
                  ),
          ),
          TripChatComposer(controller: _text, onSend: _send),
        ],
      ),
    );
  }
}

sealed class _ChatItem {
  const _ChatItem();
}

class _DayItem extends _ChatItem {
  const _DayItem(this.day);
  final DateTime day;
}

class _MessageItem extends _ChatItem {
  const _MessageItem(this.message, {required this.startsRun});
  final TripMessage message;
  final bool startsRun;
}

/// Messages (oldest first) with a separator before each new day and a flag
/// marking the first message of every run from one sender.
List<_ChatItem> _chatItems(List<TripMessage> messages) {
  final items = <_ChatItem>[];
  TripMessage? previous;
  for (final message in messages) {
    final newDay =
        previous == null ||
        message.sentAt.year != previous.sentAt.year ||
        message.sentAt.month != previous.sentAt.month ||
        message.sentAt.day != previous.sentAt.day;
    if (newDay) {
      items.add(_DayItem(message.sentAt));
    }
    items.add(
      _MessageItem(
        message,
        startsRun:
            previous == null ||
            newDay ||
            previous.sender != message.sender ||
            message.sentAt.difference(previous.sentAt).inMinutes >= 10,
      ),
    );
    previous = message;
  }
  return items;
}
