/// Qaddy's Live Leaderboard — standings for the active round.
///
/// Sprint 2.4 — see `docs/sprints/sprint-02-04-leaderboard.md`. Player
/// standings are sourced from `docs/standards/placeholder-data.md`'s
/// "Leaderboard" section (8 players, matching the round's Player Count).
///
/// Like `LiveScorecardScreen` (Sprint 2.3), this screen is intentionally
/// not wired into `app_router.dart` — `docs/architecture/navigation.md`
/// defines no route for it, and neither this sprint's "Build" nor "Do Not
/// Build" sections ask for one, so none is invented here.
///
/// The screen is a plain `StatelessWidget`: nothing on it is interactive
/// (no score-entry controls — that's `LiveScorecardScreen`'s job), so
/// there's no state to hold. Ranking is computed once per build from the
/// static placeholder list via `rankLeaderboard`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/logic/leaderboard_ranking.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';
import 'package:qaddy/features/rounds/ui/widgets/leaderboard_row.dart';

/// The Live Leaderboard screen.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final ranked = rankLeaderboard(richmondGolfClubLeaderboard);

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Leaderboard',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sectionGap),
            for (final (index, entry) in ranked.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              LeaderboardRow(ranked: entry),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
