/// Friends List's row — see `docs/features/friends-feature-integration.md`'s
/// "Friends List" section ("Avatar, name, handicap. Favourite indicator.").
/// Built on [QaddyCard], reusing [QaddyAvatar] — the same composition
/// `QaddyTripCard` and `PlayerCard` already use for their own list rows.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/community/models/friend.dart';

/// A summary row for one [Friend], used on Friends List.
class FriendCard extends StatelessWidget {
  const FriendCard({required this.friend, this.onTap, super.key});

  /// The friend to summarise.
  final Friend friend;

  /// Called when the card is tapped. Omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      onTap: onTap,
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
                  'HCP ${friend.handicap}',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (friend.favourite) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.star, color: colours.gold),
          ],
          if (onTap != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ],
      ),
    );
  }
}
