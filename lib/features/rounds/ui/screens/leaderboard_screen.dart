/// The leaderboard: who is winning, by how much and how far through they are.
///
/// Stableford points decide it. It shows the round being played or, when none
/// is, the last one finished. See `docs/features/rounds-release-candidate.md`.
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
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/leaderboard_table.dart';
import 'package:qaddy/features/rounds/ui/widgets/side_game_tiles.dart';

/// The Leaderboard (route `/rounds/leaderboard`).
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final round =
        ref.watch(liveRoundProvider) ?? ref.watch(completedRoundProvider);
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final radius = theme.extension<QaddyRadius>()!;

    if (round == null) {
      return QaddyScaffold(
        appBar: AppBar(title: const Text('Leaderboard')),
        body: Center(
          child: QaddyEmptyState(
            icon: Icons.leaderboard_outlined,
            title: 'No round yet',
            message: 'Start a round and the leaderboard builds itself.',
            actionLabel: 'Go to Rounds',
            onAction: () => context.go(AppRoutes.rounds),
          ),
        ),
      );
    }

    final standings = standingsOf(round);
    final played = round.holesPlayed;
    final chase = chaseLine(standings, currentUserName);
    final status = round.isCompleted
        ? 'Final · $played holes'
        : played == 0
        ? 'Waiting for the first hole'
        : 'After $played ${played == 1 ? 'hole' : 'holes'}';

    final leader = standings.isEmpty
        ? ''
        : standings.first.player.name == currentUserName
        ? 'You'
        : standings.first.player.name;
    final yours = standings
        .where((s) => s.player.name == currentUserName)
        .firstOrNull;

    return QaddyScaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Leaderboard'),
            Text(
              round.course,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.md),
            QaddyEyebrow(status),
            SizedBox(height: spacing.xs),
            Text(
              played == 0
                  ? 'All square'
                  : winnersHeadline(
                      standings,
                      you: currentUserName,
                      finished: round.isCompleted,
                    ),
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            if (chase != null && played > 0) ...<Widget>[
              SizedBox(height: spacing.xs),
              Text(
                chase,
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ],
            SizedBox(height: spacing.lg),
            LeaderboardTable(round: round, standings: standings),
            if (upcomingRoundSideGames.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Side games (sample)'),
              SizedBox(height: spacing.md),
              SideGameTiles(games: upcomingRoundSideGames, holesPlayed: played),
            ],
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Round summary'),
            SizedBox(height: spacing.md),
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(radius.large),
                border: Border.all(color: colours.border),
              ),
              child: Column(
                children: <Widget>[
                  QaddyInfoRow(
                    label: 'Holes completed',
                    value: '$played / ${round.holes.length}',
                  ),
                  SizedBox(height: spacing.md),
                  QaddyInfoRow(label: 'Format', value: round.format),
                  if (played > 0 && standings.isNotEmpty) ...<Widget>[
                    SizedBox(height: spacing.md),
                    QaddyInfoRow(
                      label: round.isCompleted ? 'Winner' : 'Leading',
                      value: '$leader · ${standings.first.points} pts',
                    ),
                  ],
                  if (yours != null && played > 0) ...<Widget>[
                    SizedBox(height: spacing.md),
                    QaddyInfoRow(
                      label: 'Your position',
                      value: '${yours.position} · ${yours.points} pts',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}
