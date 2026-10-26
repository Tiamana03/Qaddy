/// Qaddy's Trip Chat screen.
///
/// See `docs/features/trips-feature-integration.md`'s "Group Chat" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Trip Chat (route `/trips/:tripId/chat`).
class TripChatScreen extends ConsumerWidget {
  const TripChatScreen({required this.tripId, super.key});

  /// The trip whose chat is shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Chat')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final (index, message) in plan.messages.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _MessageTile(
                sender: message.sender,
                body: message.text,
                time: message.sentAt.toFriendlyTime(),
              ),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.sender,
    required this.body,
    required this.time,
  });

  final String sender;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyAvatar(name: sender),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        sender,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: typography.small.copyWith(
                        color: colours.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  body,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
