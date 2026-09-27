/// Qaddy's Friend Requests screen — incoming and outgoing requests.
///
/// See `docs/architecture/friend-requests.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/friend_request_row.dart';

/// Friend Requests (route `/friends/requests`).
class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final incoming = incomingFriendRequests;
    final outgoing = outgoingFriendRequests;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Incoming',
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.md),
            if (incoming.isEmpty)
              const QaddyEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No incoming requests',
                message: "You're all caught up.",
              )
            else
              for (final (index, request) in incoming.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.cardGap),
                FriendRequestRow(request: request),
              ],
            SizedBox(height: spacing.sectionGap),
            Text(
              'Outgoing',
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.md),
            if (outgoing.isEmpty)
              const QaddyEmptyState(
                icon: Icons.outbox_outlined,
                title: 'No outgoing requests',
                message: "You haven't sent any friend requests.",
              )
            else
              for (final (index, request) in outgoing.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.cardGap),
                FriendRequestRow(request: request),
              ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
