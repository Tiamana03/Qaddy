/// Qaddy's Round Complete screen — the end-of-round experience.
///
/// Sprint 2.5 — see `docs/sprints/sprint-02-05-round-complete.md`. Reuses
/// Sprint 2.4's `richmondGolfClubLeaderboard`, `rankLeaderboard`,
/// `LeaderboardRow`, `PositionBadge`, `QaddyAvatar` and `QaddyStatusBadge`
/// rather than duplicating any of them.
///
/// Like `LiveScorecardScreen` and `LeaderboardScreen`, this screen is
/// intentionally not wired into `app_router.dart` as a destination — no
/// route is defined for it in `navigation.md`. Its "Return Home" and
/// "Start New Round" actions are the one exception the sprint explicitly
/// calls for ("Navigation only"): they navigate to the *already-existing,
/// documented* `/home` and `/rounds` routes, without inventing any new
/// route.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/logic/leaderboard_ranking.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';
import 'package:qaddy/features/rounds/ui/widgets/leaderboard_row.dart';
import 'package:qaddy/features/rounds/ui/widgets/round_summary_card.dart';
import 'package:qaddy/features/rounds/ui/widgets/winner_card.dart';

/// The Round Complete screen — winner, final standings and summary.
class RoundCompleteScreen extends StatelessWidget {
  const RoundCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final ranked = rankLeaderboard(richmondGolfClubLeaderboard);
    final winners = ranked.where((entry) => entry.isLeader).toList();
    final winnerNames = winners.map((w) => w.entry.name).join(' & ');

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Round Complete',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sectionGap),
            WinnerCard(winners: winners),
            SizedBox(height: spacing.sectionGap),
            RoundSummaryCard(
              courseName: 'Richmond Golf Club',
              date: 'Saturday',
              playerCount: richmondGolfClubLeaderboard.length,
              completedHoles: 18,
              winnerNames: winnerNames,
              roundStatus: 'Completed',
            ),
            SizedBox(height: spacing.sectionGap),
            Text(
              'Final Leaderboard',
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.md),
            for (final (index, entry) in ranked.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              LeaderboardRow(ranked: entry),
            ],
            SizedBox(height: spacing.sectionGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddySecondaryButton(
                    label: 'Return Home',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: QaddyPrimaryButton(
                    label: 'Start New Round',
                    onPressed: () => context.go(AppRoutes.rounds),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
