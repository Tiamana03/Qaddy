/// Your squad as faces: a horizontal strip of friends, each ringed in gold if
/// they played in the last couple of days, with the best handicap crowned.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';

/// The squad strip. Tapping a face calls [onFriendTap]; the trailing "Add"
/// tile calls [onAdd].
class SquadStrip extends StatelessWidget {
  const SquadStrip({
    required this.friends,
    required this.now,
    required this.onFriendTap,
    required this.onAdd,
    super.key,
  });

  /// The friends to show, already in display order.
  final List<Friend> friends;

  /// The moment "played recently" is measured from.
  final DateTime now;

  /// Called with the friend whose face was tapped.
  final ValueChanged<Friend> onFriendTap;

  /// Called when the Add tile is tapped.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final best = bestHandicap(friends);

    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: friends.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: spacing.md),
        itemBuilder: (context, index) {
          if (index == friends.length) {
            return _AddTile(onTap: onAdd);
          }
          final friend = friends[index];
          return QaddyFadeSlideIn(
            offset: 8,
            delay: staggerDelay(index),
            child: _SquadMember(
              friend: friend,
              active: playedRecently(friend, now),
              best: identical(friend, best),
              onTap: () => onFriendTap(friend),
            ),
          );
        },
      ),
    );
  }
}

class _SquadMember extends StatelessWidget {
  const _SquadMember({
    required this.friend,
    required this.active,
    required this.best,
    required this.onTap,
  });

  final Friend friend;
  final bool active;
  final bool best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final label = StringBuffer(friend.displayName)
      ..write(', handicap ${handicapLabel(friend.handicap)}');
    if (active) {
      label.write(', played recently');
    }
    if (best) {
      label.write(', best handicap in your squad');
    }

    return Semantics(
      button: true,
      label: label.toString(),
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 48,
        child: SizedBox(
          width: 80,
          child: Column(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? colours.gold : colours.border,
                        width: active ? 2.5 : 1.5,
                      ),
                    ),
                    child: FittedBox(
                      child: QaddyAvatar(name: friend.displayName),
                    ),
                  ),
                  if (best)
                    Positioned(
                      right: -2,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colours.gold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colours.background,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          size: 14,
                          color: colours.backgroundBase,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing.xs),
              Text(
                friend.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(
                  color: colours.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'HCP ${handicapLabel(friend.handicap)}',
                style: typography.caption.copyWith(color: colours.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      label: 'Add a friend',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 48,
        child: SizedBox(
          width: 80,
          child: Column(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colours.surface1,
                  border: Border.all(color: colours.accent),
                ),
                child: Icon(Icons.add, color: colours.accent, size: 28),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Add',
                style: typography.small.copyWith(
                  color: colours.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
