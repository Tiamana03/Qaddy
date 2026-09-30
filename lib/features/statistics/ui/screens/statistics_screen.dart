/// Qaddy's Statistics screen — the detailed performance-analysis layer
/// behind Profile.
///
/// See `docs/features/statistics-feature-integration.md`. Release 1 is a
/// single screen reached from Profile — see
/// `docs/architecture/statistics-engineering-decisions.md`'s "Statistics Is
/// Reached From Profile, Not the Bottom Navigation".
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/ui/widgets/group_leaderboard_row.dart';
import 'package:qaddy/features/statistics/logic/stat_trend_formatting.dart';
import 'package:qaddy/features/statistics/models/placeholder_statistics.dart';

/// Statistics (route `/profile/statistics`).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _CareerTotalsCard(),
            SizedBox(height: spacing.sectionGap),
            const _ScoringStatisticsCard(),
            SizedBox(height: spacing.sectionGap),
            const _ScoringBreakdownCard(),
            SizedBox(height: spacing.sectionGap),
            const _TrendsCard(),
            SizedBox(height: spacing.sectionGap),
            const _PersonalRecordsCard(),
            SizedBox(height: spacing.sectionGap),
            const _SeasonPerformanceCard(),
            SizedBox(height: spacing.sectionGap),
            const _RivalryPerformanceCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _CareerTotalsCard extends StatelessWidget {
  const _CareerTotalsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Rounds Played', '$statisticsRoundsPlayed'),
      ('Courses Played', '$statisticsCoursesPlayed'),
      ('Golf Trips', '$statisticsTripsCount'),
      ('Total Stableford Points', '$statisticsTotalStablefordPoints'),
    ];

    return QaddySectionCard(
      title: 'Career Totals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _ScoringStatisticsCard extends StatelessWidget {
  const _ScoringStatisticsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Average Score', '$statisticsAverageScore'),
      ('Average Stableford', '$statisticsAverageStableford'),
      ('Fairways Hit', '$statisticsFairwaysHitPercent%'),
      ('Greens in Regulation', '$statisticsGreensInRegulationPercent%'),
      ('Average Putts', '$statisticsAveragePutts'),
    ];

    return QaddySectionCard(
      title: 'Scoring Statistics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _ScoringBreakdownCard extends StatelessWidget {
  const _ScoringBreakdownCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Birdies', '$statisticsBirdies'),
      ('Eagles', '$statisticsEagles'),
      ('Pars', '$statisticsPars'),
    ];

    return QaddySectionCard(
      title: 'Scoring Breakdown',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Trends',
      child: Row(
        children: <Widget>[
          for (final (index, trend) in statisticsTrends.indexed) ...<Widget>[
            if (index > 0) SizedBox(width: spacing.cardGap),
            Expanded(
              child: QaddyStatisticCard(
                label: trend.label,
                value: formatStatValue(trend.currentValue),
                trend: formatTrendText(trend),
                isPositiveTrend: trend.isImprovement,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalRecordsCard extends StatelessWidget {
  const _PersonalRecordsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Best Round', '$statisticsBestRound'),
      ('Best Front Nine', '$statisticsBestFrontNine'),
      ('Best Back Nine', '$statisticsBestBackNine'),
      ('Most Birdies', '$statisticsMostBirdies'),
      ('Longest Drive', formatDistance(statisticsLongestDriveMetres)),
      ('Longest Putt', formatDistance(statisticsLongestPuttMetres)),
    ];

    return QaddySectionCard(
      title: 'Personal Records',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _SeasonPerformanceCard extends StatelessWidget {
  const _SeasonPerformanceCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final summary = statisticsSeasonSummary;

    return QaddySectionCard(
      title: 'Season Performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyInfoRow(label: 'Group', value: statisticsSeasonGroupName),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Season', value: summary.season),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(
            label: 'Rounds Completed',
            value: '${summary.roundsCompleted}',
          ),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(
            label: 'Rounds Remaining',
            value: '${summary.roundsRemaining}',
          ),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Leader', value: summary.leader),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(
            label: 'Average Attendance',
            value: '${summary.averageAttendance}',
          ),
          SizedBox(height: spacing.md),
          for (final (index, entry)
              in statisticsSeasonLeaderboard.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            GroupLeaderboardRow(
              rank: entry.rank,
              player: entry.player,
              points: entry.points,
            ),
          ],
        ],
      ),
    );
  }
}

class _RivalryPerformanceCard extends StatelessWidget {
  const _RivalryPerformanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final rivalry = statisticsRivalry;

    return QaddySectionCard(
      title: 'Rivalry Performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'You vs ${rivalry.friendName}',
            style: typography.h4.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.md),
          QaddyInfoRow(
            label: 'Rounds Played',
            value: '${rivalry.roundsPlayed}',
          ),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Wins', value: '${rivalry.wins}'),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Losses', value: '${rivalry.losses}'),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Draws', value: '${rivalry.draws}'),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Last Result', value: rivalry.lastResult),
        ],
      ),
    );
  }
}
