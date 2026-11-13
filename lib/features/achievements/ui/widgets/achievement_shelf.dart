/// The achievement shelf: every badge the golfer can earn, the earned ones lit
/// in gold and the rest waiting in the dark, with the one to chase next.
/// Tapping a badge says how to earn it and how close they are.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
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

/// A hexagonal badge, as the approved Profile mockup draws them: a gold
/// outline and a gold emblem when earned, a dim outline and a lock when not.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.achievement,
    this.size = 56,
    super.key,
  });

  /// The achievement.
  final Achievement achievement;

  /// The badge's width.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final unlocked = achievement.unlocked;

    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(
        painter: _HexagonPainter(
          fill: unlocked
              ? colours.gold.withValues(alpha: 0.16)
              : colours.surface1,
          outline: unlocked ? colours.gold : colours.border,
          width: unlocked ? 1.8 : 1.2,
        ),
        child: Center(
          child: Icon(
            unlocked ? achievementIcon(achievement.id) : Icons.lock_outline,
            size: size * 0.44,
            color: unlocked ? colours.gold : colours.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter({
    required this.fill,
    required this.outline,
    required this.width,
  });

  final Color fill;
  final Color outline;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    // A pointy-topped hexagon with softened corners.
    final w = size.width;
    final h = size.height;
    final inset = width / 2;
    final path = Path()
      ..moveTo(w / 2, inset)
      ..lineTo(w - inset, h * 0.25)
      ..lineTo(w - inset, h * 0.75)
      ..lineTo(w / 2, h - inset)
      ..lineTo(inset, h * 0.75)
      ..lineTo(inset, h * 0.25)
      ..close();
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_HexagonPainter old) =>
      old.fill != fill || old.outline != outline || old.width != width;
}

/// The golfer's progress, drawn as the mockup's "Your Golf Journey" card: an
/// emblem, what to chase next, how many badges are earned and a gold bar
/// towards the next one. Tapping it says how to earn that badge.
class AchievementJourneyCard extends StatelessWidget {
  const AchievementJourneyCard({required this.achievements, super.key});

  /// Every achievement, earned or not.
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final next = nextUp(achievements);
    final earned = achievements.where((a) => a.unlocked).length;

    final title = next == null
        ? 'Every badge earned. Legend.'
        : '${next.title} · ${next.progressLabel}';

    return Semantics(
      button: next != null,
      label:
          'Your golf journey. $title. '
          '$earned of ${achievements.length} earned.',
      excludeSemantics: true,
      onTap: next == null ? null : () => showAchievementSheet(context, next),
      child: Material(
        color: colours.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          side: BorderSide(color: colours.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: next == null
              ? null
              : () => showAchievementSheet(context, next),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colours.surface1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colours.border),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: colours.gold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Your golf journey',
                            style: QaddyText.cardTitle.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QaddyText.listMeta.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '$earned of ${achievements.length}',
                          style: QaddyText.cardTitle.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                        Text(
                          'badges earned',
                          style: QaddyText.weatherCondition.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (next != null) ...<Widget>[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: colours.textSecondary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(radius.large),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: MediaQuery.disableAnimationsOf(context)
                          ? (next?.fraction ?? 1)
                          : 0,
                      end: next?.fraction ?? 1,
                    ),
                    duration: QaddyMotion.standard.loading,
                    curve: QaddyMotion.standard.enter,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: colours.selected.withValues(alpha: 0.35),
                      valueColor: AlwaysStoppedAnimation<Color>(colours.gold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The row of hexagonal badges under the journey card; six fit across and the
/// rest scroll. Tapping one says how to earn it and how close the golfer is.
class AchievementBadgeRow extends StatelessWidget {
  const AchievementBadgeRow({required this.achievements, super.key});

  /// Every achievement, earned or not.
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final item = (constraints.maxWidth - gap * 5) / 6;

        return SizedBox(
          height: item * 1.1 + 24,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: gap),
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
                  radius: 36,
                  onTap: () {
                    QaddyHaptics.selection();
                    showAchievementSheet(context, achievement);
                  },
                  child: SizedBox(
                    width: item,
                    child: Column(
                      children: <Widget>[
                        AchievementBadge(
                          achievement: achievement,
                          size: item - 4,
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            achievement.title,
                            maxLines: 1,
                            style: QaddyText.weatherCondition.copyWith(
                              fontSize: 11,
                              height: 13 / 11,
                              color: achievement.unlocked
                                  ? colours.textPrimary
                                  : colours.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// The journey card and the badge row together.
class AchievementShelf extends StatelessWidget {
  const AchievementShelf({required this.achievements, super.key});

  /// Every achievement, earned or not.
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AchievementJourneyCard(achievements: achievements),
        const SizedBox(height: 14),
        AchievementBadgeRow(achievements: achievements),
      ],
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
