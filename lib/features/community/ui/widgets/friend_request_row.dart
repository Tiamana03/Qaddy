/// A single row on the Friend Requests screen — see
/// `docs/architecture/friend-requests.md`'s "Screen Contents" section.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/community/models/friend_request.dart';

/// One [FriendRequest]'s row — Accept/Decline for incoming, Cancel for
/// outgoing. Every action is "Visual only", per
/// `docs/features/friends-feature-integration.md`'s Button Behaviour table,
/// so each is wired to a no-op rather than left disabled (see
/// `docs/architecture/friends-engineering-decisions.md`'s "Visual-Only
/// Actions Are Explicit, Not Silent").
class FriendRequestRow extends StatelessWidget {
  const FriendRequestRow({required this.request, super.key});

  /// The friend request to display.
  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final friend = request.friend;

    return QaddyCard(
      child: Row(
        children: <Widget>[
          QaddyAvatar(name: friend.displayName),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  friend.displayName,
                  style: typography.body.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'HCP ${friend.handicap}  ·  Sent ${request.sentDescription}',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (request.direction == FriendRequestDirection.incoming) ...<Widget>[
            QaddyIconButton(
              icon: Icons.check,
              onPressed: () {},
              semanticLabel: 'Accept',
            ),
            SizedBox(width: spacing.xs),
            QaddyIconButton(
              icon: Icons.close,
              onPressed: () {},
              semanticLabel: 'Decline',
            ),
          ] else
            QaddyIconButton(
              icon: Icons.close,
              onPressed: () {},
              semanticLabel: 'Cancel',
            ),
        ],
      ),
    );
  }
}
