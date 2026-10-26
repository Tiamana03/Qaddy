/// The pieces a chat conversation is drawn from: message bubbles, day
/// separators and the typing indicator.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';

/// A small profile circle — [QaddyAvatar] scaled down to chat size.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({required this.name, super.key});

  /// The person the avatar stands for.
  final String name;

  /// Edge length of the circle.
  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(child: QaddyAvatar(name: name)),
      ),
    );
  }
}

/// One chat message. The golfer's own messages sit on the right on the brand
/// gradient; everyone else's sit on the left on a neutral surface, led by a
/// profile circle and name at the start of each run of messages.
class TripMessageBubble extends StatelessWidget {
  const TripMessageBubble({
    required this.message,
    required this.isMine,
    required this.startsRun,
    this.showReceipt = true,
    super.key,
  });

  /// The message to draw.
  final TripMessage message;

  /// Whether the signed-in golfer sent it.
  final bool isMine;

  /// Whether this is the first message of a run from the same sender (which
  /// is when the sender's name and avatar are shown).
  final bool startsRun;

  /// Whether to show the delivery ticks on the golfer's own messages.
  final bool showReceipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final tail = Radius.circular(radius.small);
    final round = Radius.circular(radius.large);
    final borderRadius = BorderRadius.only(
      topLeft: round,
      topRight: round,
      bottomLeft: isMine ? round : tail,
      bottomRight: isMine ? tail : round,
    );
    final foreground = isMine
        ? theme.colorScheme.onPrimary
        : colours.textPrimary;
    final subdued = isMine
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.75)
        : colours.textTertiary;

    final bubble = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: isMine ? colours.gradientGreen : null,
        color: isMine ? null : colours.surface2,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message.text,
            style: typography.body.copyWith(color: foreground),
          ),
          SizedBox(height: spacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                message.sentAt.toFriendlyTime(),
                style: typography.small.copyWith(color: subdued),
              ),
              if (isMine && showReceipt) ...<Widget>[
                SizedBox(width: spacing.xs),
                _Receipt(status: message.status, subdued: subdued),
              ],
            ],
          ),
        ],
      ),
    );

    final semanticLabel = StringBuffer(isMine ? 'You' : message.sender)
      ..write(': ${message.text}. ${message.sentAt.toFriendlyTime()}');
    if (isMine && showReceipt) {
      semanticLabel.write('. ${_receiptLabel(message.status)}');
    }

    return Padding(
      padding: EdgeInsets.only(top: startsRun ? spacing.md : spacing.xs),
      child: Semantics(
        label: semanticLabel.toString(),
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (!isMine)
              SizedBox(
                width: ChatAvatar.size + spacing.sm,
                child: startsRun
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: ChatAvatar(name: message.sender),
                      )
                    : null,
              ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                ),
                child: Column(
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!isMine && startsRun)
                      Padding(
                        padding: EdgeInsets.only(
                          left: spacing.xs,
                          bottom: spacing.xs,
                        ),
                        child: Text(
                          message.sender,
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ),
                    bubble,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _receiptLabel(MessageStatus status) => switch (status) {
  MessageStatus.sent => 'Sent',
  MessageStatus.delivered => 'Delivered',
  MessageStatus.read => 'Read',
};

/// Sent / delivered / read ticks (placeholder: the status is advanced by a
/// timer, not by other people's devices).
class _Receipt extends StatelessWidget {
  const _Receipt({required this.status, required this.subdued});

  final MessageStatus status;
  final Color subdued;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    return Icon(
      status == MessageStatus.sent ? Icons.check : Icons.done_all,
      size: 14,
      color: status == MessageStatus.read ? colours.gold : subdued,
    );
  }
}

/// "Today", "Yesterday" or "Sat 24 Oct" — the heading between days of chat.
class ChatDaySeparator extends StatelessWidget {
  const ChatDaySeparator({required this.day, super.key});

  /// Any moment on the day being labelled.
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final label = day.isToday
        ? 'Today'
        : day.isYesterday
        ? 'Yesterday'
        : day.toShortWeekdayAndDate();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: colours.surface1,
            borderRadius: BorderRadius.circular(radius.large),
            border: Border.all(color: colours.border),
          ),
          child: Text(
            label,
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// "Ben is typing…" with three bouncing dots. A placeholder: nothing on the
/// other end is actually typing yet.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({required this.name, super.key});

  /// Who is (pretending to be) typing.
  final String name;

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour "reduce motion": show still dots rather than bouncing ones.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    return Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: Semantics(
        liveRegion: true,
        label: '${widget.name} is typing',
        excludeSemantics: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ChatAvatar(name: widget.name),
            SizedBox(width: spacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.md,
              ),
              decoration: BoxDecoration(
                color: colours.surface2,
                borderRadius: BorderRadius.circular(radius.large),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(right: i < 2 ? spacing.xs : 0),
                        child: _Dot(
                          // Each dot peaks a third of a cycle after the last.
                          level: _level((_controller.value - i / 3) % 1),
                          colour: colours.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 0–1 "how raised" for a dot at phase [t] (0–1 around the cycle).
  double _level(double t) => t < 0.5 ? t * 2 : (1 - t) * 2;
}

class _Dot extends StatelessWidget {
  const _Dot({required this.level, required this.colour});

  final double level;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -4 * level),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.5 + 0.5 * level),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
