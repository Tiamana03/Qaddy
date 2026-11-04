/// Qaddy's Statistics screen — the story of the rounds the golfer has
/// actually played.
///
/// Everything on it is worked out from finished rounds (see
/// `logic/career_stats.dart`): how they are scoring, how their form is
/// moving, which holes they love and dread, and who they keep beating or
/// losing to. With no rounds yet it invites them to play one. See
/// `docs/features/statistics-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_chart.dart';
import 'package:qaddy/features/statistics/ui/widgets/rival_row.dart';
import 'package:qaddy/features/statistics/ui/widgets/score_mix_bar.dart';

/// Statistics (route `/profile/statistics`).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: stats == null
          ? Center(
              child: QaddyEmptyState(
                icon: Icons.insights_outlined,
                title: 'Your story starts on the first tee',
                message:
                    'Play a round and this fills with your scoring, your '
                    'form, your best holes and who you keep beating.',
                actionLabel: 'Start a round',
                onAction: () => context.go(AppRoutes.rounds),
              ),
            )
          : _Story(stats: stats),
    );
  }
}

class _Story extends ConsumerWidget {
  const _Story({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final hasResults = ref.watch(completedRoundProvider) != null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: staggered(<Widget>[
          SizedBox(height: spacing.lg),
          _Hero(
            stats: stats,
            hasResults: hasResults,
            handicap: ref.watch(golferDetailsProvider).handicap,
          ),
          SizedBox(height: spacing.sectionGap),
          const QaddySectionHeading(title: 'Your form'),
          SizedBox(height: spacing.md),
          _FormCard(stats: stats),
          SizedBox(height: spacing.sectionGap),
          const QaddySectionHeading(title: 'How you score'),
          SizedBox(height: spacing.md),
          _MixCard(stats: stats),
          if (stats.favouriteHole != null) ...<Widget>[
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your holes'),
            SizedBox(height: spacing.md),
            _HolesCard(stats: stats),
          ],
          if (stats.rivals.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Head to head'),
            SizedBox(height: spacing.md),
            _RivalsCard(rivals: stats.rivals.take(5).toList()),
          ],
          SizedBox(height: spacing.sectionGap),
          const QaddySectionHeading(title: 'Highlights'),
          SizedBox(height: spacing.md),
          _HighlightsCard(stats: stats),
          SizedBox(height: spacing.xl),
        ]),
      ),
    );
  }
}

/// The headline: the average, said big, and what is behind it.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.stats,
    required this.hasResults,
    required this.handicap,
  });

  final double? handicap;

  final CareerStats stats;
  final bool hasResults;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return QaddyHeroCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.lerp(colours.accentTeal, colours.backgroundBase, 0.45)!,
          Color.lerp(colours.accentIndigo, colours.backgroundBase, 0.7)!,
        ],
      ),
      footer: hasResults
          ? QaddyGoldButton(
              label: 'See your last round',
              icon: Icons.emoji_events_outlined,
              tall: true,
              onPressed: () => context.push(AppRoutes.roundComplete),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const QaddyEyebrow('Your game'),
          SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: animate ? 0 : stats.averagePoints,
                  end: stats.averagePoints,
                ),
                duration: QaddyMotion.standard.loading,
                curve: QaddyMotion.standard.enter,
                builder: (context, value, _) => Text(
                  '${value.round()}',
                  style: typography.display.copyWith(
                    color: onGradient,
                    height: 1,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: Text(
                    'Stableford points\na round',
                    style: typography.h3.copyWith(color: onGradient),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(formStory(stats), style: typography.body.copyWith(color: muted)),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              QaddyInfoChip(
                icon: Icons.flag_outlined,
                text: roundsLabel(stats.rounds),
              ),
              QaddyInfoChip(
                icon: Icons.emoji_events_outlined,
                text: stats.wins == 1
                    ? '1 win · ${winRateLabel(stats)}'
                    : '${stats.wins} wins · ${winRateLabel(stats)}',
              ),
              if (handicap case final handicap?)
                QaddyInfoChip(
                  icon: Icons.speed_outlined,
                  text: 'Handicap ${handicapLabel(handicap)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final shown = stats.form();

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            shown.length == 1
                ? 'Points in your round'
                : 'Points over your last ${shown.length} rounds',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.md),
          FormChart(rounds: shown),
        ],
      ),
    );
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            parOrBetterLine(stats.mix),
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Across ${stats.holesPlayed} holes',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          ScoreMixBar(mix: stats.mix),
        ],
      ),
    );
  }
}

class _HolesCard extends StatelessWidget {
  const _HolesCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final favourite = stats.favouriteHole!;
    final toughest = stats.toughestHole!;

    Widget spotlight(
      String label,
      HoleStat hole,
      Color colour,
      IconData icon,
    ) => Expanded(
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colours.surface2,
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 16, color: colour),
                SizedBox(width: spacing.xs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(color: colour),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Hole ${hole.number}',
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            Text(
              'Par ${hole.par} · ${pointsAverage(hole.averagePoints)} pts',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
    );

    Widget average(String label, double? value) => Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value == null ? '–' : pointsAverage(value),
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              spotlight(
                'Your favourite',
                favourite,
                colours.gold,
                Icons.favorite_border,
              ),
              SizedBox(width: spacing.cardGap),
              spotlight(
                'Your nemesis',
                toughest,
                colours.accentOrange,
                Icons.sentiment_dissatisfied_outlined,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Average points a hole',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Row(
            children: <Widget>[
              average('Par 3s', stats.parThreeAverage),
              average('Par 4s', stats.parFourAverage),
              average('Par 5s', stats.parFiveAverage),
              average('Front 9', stats.frontNineAverage),
              average('Back 9', stats.backNineAverage),
            ],
          ),
        ],
      ),
    );
  }
}

class _RivalsCard extends StatelessWidget {
  const _RivalsCard({required this.rivals});

  final List<Rival> rivals;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, rival) in rivals.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.lg),
            RivalRow(rival: rival),
          ],
        ],
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final best = stats.bestRound;
    final rows = <({IconData icon, Color colour, String title, String detail})>[
      (
        icon: Icons.emoji_events,
        colour: colours.gold,
        title: 'Best round: ${best.points} points',
        detail:
            '${best.round.course} · '
            '${best.date.day} ${best.date.monthAbbreviation}'
            '${best.holes < 18 ? ' · ${best.holes} holes' : ''}',
      ),
      if (stats.mostBirdiesInARound > 0)
        (
          icon: Icons.local_fire_department_outlined,
          colour: colours.accentTeal,
          title: 'Most birdies in a round: ${stats.mostBirdiesInARound}',
          detail: 'Birdies or better',
        ),
      if (stats.longestWinStreak >= 2)
        (
          icon: Icons.bolt,
          colour: colours.accentOrange,
          title: 'Longest win streak: ${stats.longestWinStreak} rounds',
          detail: 'Back to back',
        ),
      (
        icon: Icons.golf_course,
        colour: colours.accentSky,
        title: '${stats.holesPlayed} holes played',
        detail: roundsLabel(stats.rounds),
      ),
    ];

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                QaddyIconBadge(icon: row.icon, colour: row.colour),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        row.title,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        row.detail,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
