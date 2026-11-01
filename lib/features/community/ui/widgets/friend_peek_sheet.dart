/// A quick look at one friend, without leaving Friends Home — and the easiest
/// way to ask them for a round.
///
/// Every friend in the squad can be tapped; this is what answers. Only Tom has
/// a full profile in Release 1, so only his sheet offers "View profile" —
/// everyone else gets the same facts in the sheet itself.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

/// Opens the peek sheet for [friend]. [now] is the moment "last played" is
/// measured from.
Future<void> showFriendPeek(
  BuildContext context,
  WidgetRef ref,
  Friend friend, {
  required DateTime now,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (sheetContext) => FriendPeekSheet(
      friend: friend,
      now: now,
      onInvite: () {
        Navigator.of(sheetContext).pop();
        QaddyHaptics.light();
        shareOrCopy(
          context,
          ref,
          text: inviteMessage(friend, currentUserName),
          subject: 'Fancy a round?',
        );
      },
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
    required this.onInvite,
    this.onViewProfile,
    super.key,
  });

  /// The friend being looked at.
  final Friend friend;

  /// The moment "last played" is measured from.
  final DateTime now;

  /// Sends the friend an invitation to play.
  final VoidCallback onInvite;

  /// Opens the full profile. Omit when the friend has none.
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final recent = playedRecently(friend, now);

    Widget place(IconData icon, String text) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 16, color: colours.textSecondary),
        SizedBox(width: spacing.xs),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
        ),
      ],
    );

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
            Container(
              width: spacing.hero + spacing.lg,
              height: spacing.hero + spacing.lg,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: recent ? colours.gold : colours.border,
                  width: 3,
                ),
              ),
              child: FittedBox(child: QaddyAvatar(name: friend.displayName)),
            ),
            SizedBox(height: spacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    friend.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                color: recent ? colours.accent : colours.textSecondary,
              ),
            ),
            SizedBox(height: spacing.lg),
            Row(
              children: <Widget>[
                _Stat(value: handicapLabel(friend.handicap), label: 'Handicap'),
                SizedBox(width: spacing.cardGap),
                _Stat(
                  value: '${friend.roundsPlayed}',
                  label: friend.roundsPlayed == 1
                      ? 'Round together'
                      : 'Rounds together',
                ),
                SizedBox(width: spacing.cardGap),
                _Stat(value: '${friend.createdAt.year}', label: 'Mates since'),
              ],
            ),
            SizedBox(height: spacing.lg),
            place(Icons.flag_outlined, friend.homeClub),
            if (friend.favouriteCourse != null) ...<Widget>[
              SizedBox(height: spacing.xs),
              place(Icons.favorite_border, 'Loves ${friend.favouriteCourse}'),
            ],
            SizedBox(height: spacing.xs),
            place(Icons.place_outlined, friend.location),
            SizedBox(height: spacing.xl),
            QaddyGoldButton(
              label: 'Fancy a round, ${friend.displayName}?',
              icon: Icons.send_rounded,
              onPressed: onInvite,
            ),
            if (onViewProfile != null) ...<Widget>[
              SizedBox(height: spacing.md),
              QaddySecondaryButton(
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

/// One headline number with its caption.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: spacing.md,
            horizontal: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: colours.surface2,
            borderRadius: BorderRadius.circular(radius.large),
          ),
          child: Column(
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: typography.h2.copyWith(color: colours.textPrimary),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: typography.caption.copyWith(
                  color: colours.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
