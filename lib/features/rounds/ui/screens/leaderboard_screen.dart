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
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/standing_row.dart';

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
    final leaderPoints = standings.isEmpty ? 0 : standings.first.points;
    final chase = chaseLine(standings, currentUserName);
    final status = round.isCompleted
        ? 'Final · $played holes'
        : played == 0
        ? 'Waiting for the first hole'
        : 'After $played ${played == 1 ? 'hole' : 'holes'}';

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            QaddyEyebrow(
              '${round.format.toUpperCase()} · ${status.toUpperCase()}',
            ),
            SizedBox(height: spacing.sm),
            Text(
              played == 0
                  ? 'All square'
                  : winnersHeadline(
                      standings,
                      you: currentUserName,
                      finished: round.isCompleted,
                    ),
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            if (chase != null && played > 0) ...<Widget>[
              SizedBox(height: spacing.xs),
              Text(
                chase,
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ],
            SizedBox(height: spacing.xl),
            for (final (index, standing) in standings.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              StandingRow(
                standing: standing,
                isYou: standing.player.name == currentUserName,
                leaderPoints: leaderPoints,
                holesPlayed: played,
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}
