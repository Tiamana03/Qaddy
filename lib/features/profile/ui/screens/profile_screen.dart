/// Qaddy's Profile screen — the current user's own identity page.
///
/// See `docs/features/profile-feature-integration.md`. Release 1 is a
/// single, aggregated screen — see
/// `docs/architecture/profile-engineering-decisions.md`'s "Release 1 Is
/// One Aggregated Screen" — so every section below renders directly on
/// `/profile` rather than linking out to a sub-screen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/profile/models/placeholder_profile.dart';

/// The Profile destination (route `/profile`).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _ProfileHeader(),
            SizedBox(height: spacing.sectionGap),
            const _DetailsCard(),
            SizedBox(height: spacing.sectionGap),
            const _QuickActionsCard(),
            SizedBox(height: spacing.sectionGap),
            const _ProfileSummary(),
            SizedBox(height: spacing.sectionGap),
            const _PlayingStatisticsCard(),
            SizedBox(height: spacing.sectionGap),
            const _CurrentSeasonCard(),
            SizedBox(height: spacing.sectionGap),
            const _PersonalBestsCard(),
            SizedBox(height: spacing.sectionGap),
            const _AchievementShowcaseCard(),
            SizedBox(height: spacing.sectionGap),
            const _FavouriteCoursesCard(),
            SizedBox(height: spacing.sectionGap),
            const _FavouritePlayingPartnersCard(),
            SizedBox(height: spacing.sectionGap),
            const _EquipmentCard(),
            SizedBox(height: spacing.sectionGap),
            const _RecentActivityCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Center(
      child: Column(
        children: <Widget>[
          QaddyAvatar(name: profile.displayName),
          SizedBox(height: spacing.sm),
          Text(
            profile.displayName,
            style: typography.h1.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            '${profile.homeCourse}  ·  HCP ${profile.handicap}',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          const QaddyStatusBadge(
            label: 'Active',
            tone: QaddyStatusBadgeTone.success,
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(
            label: 'Favourite Course',
            value: profile.favouriteCourse ?? 'Not set',
          ),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Location', value: profile.location),
          SizedBox(height: spacing.sm),
          _InfoRow(
            label: 'Member Since',
            value: profile.joinedDate.toFriendlyDate(),
          ),
          SizedBox(height: spacing.sm),
          const _InfoRow(label: 'Profile Visibility', value: 'Friends Only'),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Quick Actions',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.profileStatistics),
          borderRadius: BorderRadius.circular(radius.medium),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              children: <Widget>[
                Icon(Icons.bar_chart, color: colours.gold),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    'View Statistics',
                    style: typography.body.copyWith(color: colours.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right, color: colours.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      children: <Widget>[
        QaddyStatisticCard(label: 'Friends', value: '$profileFriendsCount'),
        QaddyStatisticCard(label: 'Groups', value: '$profileGroupsCount'),
        QaddyStatisticCard(label: 'Trips', value: '$profileTripsCount'),
        const QaddyStatisticCard(
          label: 'Courses Played',
          value: '$profileCoursesPlayed',
        ),
        const QaddyStatisticCard(
          label: 'Rounds Played',
          value: '$profileRoundsPlayed',
        ),
        const QaddyStatisticCard(
          label: 'Seasons Completed',
          value: '$profileSeasonsCompleted',
        ),
        const QaddyStatisticCard(
          label: 'Achievements',
          value: '$profileAchievementsCount',
        ),
      ],
    );
  }
}

class _PlayingStatisticsCard extends StatelessWidget {
  const _PlayingStatisticsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Average Score', '$profileAverageScore'),
      ('Average Stableford', '$profileAverageStableford'),
      ('Best Round', '$profileBestRound'),
      ('Best Stableford', '$profileBestStableford'),
      ('Birdies', '$profileBirdies'),
      ('Eagles', '$profileEagles'),
      ('Pars', '$profilePars'),
      ('Fairways Hit', '$profileFairwaysHitPercent%'),
      ('Greens in Regulation', '$profileGreensInRegulationPercent%'),
      ('Average Putts', '$profileAveragePutts'),
    ];

    return QaddySectionCard(
      title: 'Playing Statistics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _InfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _CurrentSeasonCard extends StatelessWidget {
  const _CurrentSeasonCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final standing = profileCurrentSeasonStanding;

    return QaddySectionCard(
      title: 'Current Season',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(label: 'Season', value: profileCurrentSeasonName),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Group', value: profileCurrentSeasonGroup),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Position', value: _ordinal(standing.rank)),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Points', value: '${standing.points}'),
        ],
      ),
    );
  }

  static String _ordinal(int rank) {
    if (rank % 10 == 1 && rank % 100 != 11) {
      return '${rank}st';
    }
    if (rank % 10 == 2 && rank % 100 != 12) {
      return '${rank}nd';
    }
    if (rank % 10 == 3 && rank % 100 != 13) {
      return '${rank}rd';
    }
    return '${rank}th';
  }
}

class _PersonalBestsCard extends StatelessWidget {
  const _PersonalBestsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final rows = <(String, String)>[
      ('Best Round', '$profileBestRound'),
      ('Best Front Nine', '$profileBestFrontNine'),
      ('Best Back Nine', '$profileBestBackNine'),
      ('Most Birdies', '$profileMostBirdies'),
      ('Longest Drive', formatDistance(profileLongestDriveMetres)),
      ('Longest Putt', formatDistance(profileLongestPuttMetres)),
    ];

    return QaddySectionCard(
      title: 'Personal Bests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _InfoRow(label: row.$1, value: row.$2),
          ],
        ],
      ),
    );
  }
}

class _AchievementShowcaseCard extends StatelessWidget {
  const _AchievementShowcaseCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Achievement Showcase',
      child: Column(
        children: <Widget>[
          for (final (index, achievement)
              in profileAchievementShowcase.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            Row(
              children: <Widget>[
                Icon(Icons.emoji_events, color: colours.gold),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: typography.body.copyWith(color: colours.textPrimary),
                  ),
                ),
                QaddyStatusBadge(
                  label: achievement.unlocked ? 'Unlocked' : 'Locked',
                  tone: achievement.unlocked
                      ? QaddyStatusBadgeTone.success
                      : QaddyStatusBadgeTone.info,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FavouriteCoursesCard extends StatelessWidget {
  const _FavouriteCoursesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Favourite Courses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, course)
              in profileFavouriteCourses.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.xs),
            Text(
              course,
              style: typography.body.copyWith(color: colours.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavouritePlayingPartnersCard extends StatelessWidget {
  const _FavouritePlayingPartnersCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Favourite Playing Partners',
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.md,
        children: <Widget>[
          for (final friend in profileFavouritePlayingPartners)
            SizedBox(
              width: spacing.hero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  QaddyAvatar(name: friend.displayName),
                  SizedBox(height: spacing.xs),
                  Text(
                    friend.displayName,
                    textAlign: TextAlign.center,
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Equipment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, item) in profileEquipment.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _InfoRow(label: item.club, value: item.value),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Recent Activity',
      child: Column(
        children: <Widget>[
          for (final (index, entry)
              in profileRecentActivity.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                Icon(Icons.history, color: colours.gold, size: spacing.lg),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    entry.description,
                    style: typography.body.copyWith(color: colours.textPrimary),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  entry.when,
                  style: typography.small.copyWith(color: colours.textTertiary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: typography.body.copyWith(
              color: colours.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Lays out [children] two-per-row on mobile and one-per-row-of-four on
/// tablet/desktop — the same layout `DashboardScreen`'s Quick Actions and
/// Statistics Preview already use.
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final perRow = context.isMobile ? 2 : 4;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += perRow) {
      final rowItems = children.skip(i).take(perRow).toList();
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: spacing.cardGap));
      }
      rows.add(
        Row(
          children: <Widget>[
            for (final (index, item) in rowItems.indexed) ...<Widget>[
              if (index > 0) SizedBox(width: spacing.cardGap),
              Expanded(child: item),
            ],
            // Pad an incomplete final row so cards keep a consistent width.
            for (var pad = rowItems.length; pad < perRow; pad++) ...<Widget>[
              SizedBox(width: spacing.cardGap),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}
