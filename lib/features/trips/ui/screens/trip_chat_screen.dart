/// Qaddy's Trip Chat screen.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Chat" section.
/// Only placeholder messages exist (see placeholder-trip-data.md's "Chat"
/// section) — no Announcements, Photos or Shared updates data exists yet,
/// so this screen displays the messages it has rather than inventing the
/// rest.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';

/// Trip Chat (route `/trips/chat`).
class TripChatScreen extends StatelessWidget {
  const TripChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Chat')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final (index, message)
                in melbourneGolfWeekendMessages.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _MessageTile(
                message: message.sender,
                body: message.message,
                time: message.time,
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
    required this.message,
    required this.body,
    required this.time,
  });

  final String message;
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
          QaddyAvatar(name: message),
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
                        message,
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
