/// The achievement shelf: every badge the golfer can earn, the earned ones lit
/// in gold and the rest waiting in the dark, with the one to chase next.
/// Tapping a badge says how to earn it and how close they are.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/achievements/models/achievement.dart';

/// The icon for the achievement with this id.
IconData achievementIcon(String id) {
  return switch (id) {
    'first-round' => Icons.flag,
    'full-eighteen' => Icons.golf_course,
    'birdie-hunter' => Icons.flutter_dash,
    'eagle-eye' => Icons.visibility,
    'winner' => Icons.emoji_events,
    'on-a-roll' => Icons.local_fire_department,
    'social-golfer' => Icons.groups,
    'regular' => Icons.event_repeat,
    _ => Icons.military_tech,
  };
}

/// A round badge: gold when earned, dim with a lock when not.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.achievement,
    this.size = 56,
    super.key,
  });

  /// The achievement.
  final Achievement achievement;

  /// The badge's diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final unlocked = achievement.unlocked;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked
            ? colours.gold.withValues(alpha: 0.2)
            : colours.surface2,
        border: Border.all(
          color: unlocked ? colours.gold : colours.border,
          width: unlocked ? 2 : 1,
        ),
      ),
      child: Icon(
        unlocked ? achievementIcon(achievement.id) : Icons.lock_outline,
        size: size * 0.46,
        color: unlocked ? colours.gold : colours.textTertiary,
      ),
    );
  }
}

/// A scrollable row of badges with the next target beneath.
class AchievementShelf extends StatelessWidget {
  const AchievementShelf({required this.achievements, super.key});

  /// Every achievement, earned or not.
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final next = nextUp(achievements);
    final earned = achievements.where((a) => a.unlocked).length;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: achievements.length,
              separatorBuilder: (context, index) => SizedBox(width: spacing.md),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Semantics(
                  button: true,
                  label:
                      '${achievement.title}. ${achievement.blurb}. '
                      '${achievement.progressLabel}.',
                  excludeSemantics: true,
                  onTap: () => showAchievementSheet(context, achievement),
                  child: InkResponse(
                    radius: 40,
                    onTap: () {
                      QaddyHaptics.selection();
                      showAchievementSheet(context, achievement);
                    },
                    child: SizedBox(
                      width: 72,
                      child: Column(
                        children: <Widget>[
                          AchievementBadge(achievement: achievement),
                          SizedBox(height: spacing.sm),
                          Text(
                            achievement.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(
                              color: achievement.unlocked
                                  ? colours.textPrimary
                                  : colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: spacing.lg),
          if (next == null)
            Text(
              'You have earned every achievement. Legend.',
              style: typography.body.copyWith(color: colours.accent),
            )
          else ...<Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: QaddyEyebrow('NEXT UP')),
                Text(
                  '$earned of ${achievements.length} earned',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Text(
              next.title,
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            Text(
              '${next.blurb} · ${next.progressLabel}',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.large),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: MediaQuery.disableAnimationsOf(context)
                      ? next.fraction
                      : 0,
                  end: next.fraction,
                ),
                duration: QaddyMotion.standard.loading,
                curve: QaddyMotion.standard.enter,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: colours.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(colours.gold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens a sheet that says what [achievement] is and how close the golfer is.
Future<void> showAchievementSheet(
  BuildContext context,
  Achievement achievement,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (context) => _AchievementSheet(achievement: achievement),
  );
}

class _AchievementSheet extends StatelessWidget {
  const _AchievementSheet({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.pagePadding,
          0,
          spacing.pagePadding,
          spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AchievementBadge(achievement: achievement, size: 88),
            SizedBox(height: spacing.md),
            Text(
              achievement.title,
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            Text(
              achievement.blurb,
              textAlign: TextAlign.center,
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.lg),
            if (achievement.unlocked)
              Text(
                'Earned',
                style: typography.h3.copyWith(color: colours.accent),
              )
            else ...<Widget>[
              Text(
                achievement.progressLabel,
                style: typography.h3.copyWith(color: colours.textPrimary),
              ),
              SizedBox(height: spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(radius.large),
                child: LinearProgressIndicator(
                  value: achievement.fraction,
                  minHeight: 8,
                  backgroundColor: colours.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(colours.gold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
