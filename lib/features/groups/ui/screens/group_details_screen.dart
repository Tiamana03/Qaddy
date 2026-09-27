/// Qaddy's Group Details screen — one group's overview, members, season
/// standings and upcoming round.
///
/// See `docs/architecture/group-details.md`. Displays Saturday Boys — the
/// shared placeholder group (see `placeholder_groups.dart`).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_card.dart';
import 'package:qaddy/features/groups/ui/widgets/group_leaderboard_row.dart';

/// Group Details (route `/friends/groups/details`).
class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final group = saturdayBoys;

    return QaddyScaffold(
      appBar: AppBar(title: Text(group.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            _OverviewCard(group: group),
            SizedBox(height: spacing.sectionGap),
            const _MembersCard(),
            SizedBox(height: spacing.sectionGap),
            const _SeasonSummaryCard(),
            SizedBox(height: spacing.sectionGap),
            const _LeaderboardCard(),
            SizedBox(height: spacing.sectionGap),
            const _UpcomingRoundCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final (statusLabel, _) = groupStatusBadgeContent(group.status);

    return QaddySectionCard(
      title: 'Group Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(label: 'Owner', value: group.ownerId),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Member Count', value: '${group.totalMembers}'),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Status', value: statusLabel),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Home Course', value: group.homeCourse ?? 'Not set'),
          SizedBox(height: spacing.sm),
          _InfoRow(
            label: 'Competition',
            value: group.competitionFormat ?? 'Not set',
          ),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Created', value: group.createdAt.toFriendlyDate()),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Members',
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.md,
        children: <Widget>[
          for (final member in saturdayBoysMembers)
            SizedBox(
              width: spacing.hero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  QaddyAvatar(name: member.name),
                  SizedBox(height: spacing.xs),
                  Text(
                    member.name,
                    textAlign: TextAlign.center,
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'HCP ${member.handicap}',
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonSummaryCard extends StatelessWidget {
  const _SeasonSummaryCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    const summary = saturdayBoysSeasonSummary;

    return QaddySectionCard(
      title: 'Season Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(label: 'Season', value: summary.season),
          SizedBox(height: spacing.sm),
          _InfoRow(
            label: 'Rounds Completed',
            value: '${summary.roundsCompleted}',
          ),
          SizedBox(height: spacing.sm),
          _InfoRow(
            label: 'Rounds Remaining',
            value: '${summary.roundsRemaining}',
          ),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Leader', value: summary.leader),
          SizedBox(height: spacing.sm),
          _InfoRow(
            label: 'Average Attendance',
            value: '${summary.averageAttendance}',
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Leaderboard',
      child: Column(
        children: <Widget>[
          for (final (index, entry)
              in saturdayBoysLeaderboard.indexed) ...<Widget>[
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

class _UpcomingRoundCard extends StatelessWidget {
  const _UpcomingRoundCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    const round = saturdayBoysUpcomingRound;

    return QaddySectionCard(
      title: 'Upcoming Group Round',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(label: 'Course', value: round.course),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Date', value: round.date),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Tee Time', value: round.teeTime),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Competition', value: round.competition),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Players', value: '${round.players}'),
          SizedBox(height: spacing.sm),
          _InfoRow(label: 'Side Games', value: round.sideGames),
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
