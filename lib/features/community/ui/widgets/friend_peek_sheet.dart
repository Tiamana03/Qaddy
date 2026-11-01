/// A quick look at one friend, without leaving Friends Home.
///
/// Every friend in the squad can be tapped; this is what answers. Only Tom has
/// a full profile in Release 1, so only his sheet offers "View profile" —
/// everyone else gets the same facts in the sheet itself.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

/// Opens the peek sheet for [friend]. [now] is the moment "last played" is
/// measured from.
Future<void> showFriendPeek(
  BuildContext context,
  Friend friend, {
  required DateTime now,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (sheetContext) => FriendPeekSheet(
      friend: friend,
      now: now,
      onViewProfile: friend.id == tom.id
          ? () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.friendProfile);
            }
          : null,
    ),
  );
}

/// The content of the peek sheet.
class FriendPeekSheet extends StatelessWidget {
  const FriendPeekSheet({
    required this.friend,
    required this.now,
    this.onViewProfile,
    super.key,
  });

  /// The friend being looked at.
  final Friend friend;

  /// The moment "last played" is measured from.
  final DateTime now;

  /// Opens the full profile. Omit when the friend has none.
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.pagePadding,
          0,
          spacing.pagePadding,
          spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: spacing.hero + spacing.lg,
              height: spacing.hero + spacing.lg,
              child: FittedBox(child: QaddyAvatar(name: friend.displayName)),
            ),
            SizedBox(height: spacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    friend.displayName,
                    style: typography.h2.copyWith(color: colours.textPrimary),
                  ),
                ),
                if (friend.favourite) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  Icon(Icons.star, color: colours.gold),
                ],
              ],
            ),
            SizedBox(height: spacing.xs),
            Text(
              lastPlayedLabel(friend, now),
              style: typography.body.copyWith(
                color: playedRecently(friend, now)
                    ? colours.accent
                    : colours.textSecondary,
              ),
            ),
            SizedBox(height: spacing.lg),
            Container(
              padding: EdgeInsets.all(spacing.cardPadding),
              decoration: BoxDecoration(
                color: colours.surface2,
                borderRadius: BorderRadius.circular(radius.large),
              ),
              child: Column(
                children: <Widget>[
                  QaddyInfoRow(
                    label: 'Handicap',
                    value: handicapLabel(friend.handicap),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(label: 'Home club', value: friend.homeClub),
                  if (friend.favouriteCourse != null) ...<Widget>[
                    SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: 'Favourite course',
                      value: friend.favouriteCourse!,
                    ),
                  ],
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(label: 'Location', value: friend.location),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Rounds together',
                    value: '${friend.roundsPlayed}',
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Friends since',
                    value: '${friend.createdAt.year}',
                  ),
                ],
              ),
            ),
            if (onViewProfile != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              QaddyPrimaryButton(
                label: 'View profile',
                onPressed: onViewProfile,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
