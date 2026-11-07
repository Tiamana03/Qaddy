/// The round's side games as a row of tiles, as the approved Live Scoring
/// mockup draws them: an icon, the game, its hole and where it stands.
///
/// Qaddy does not score side games yet, so a tile says only what is true: the
/// game, its hole and whether that hole has been played. Entries and winners
/// are not invented.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// Tiles for [games], given how many holes [holesPlayed] the round has.
class SideGameTiles extends StatelessWidget {
  const SideGameTiles({
    required this.games,
    required this.holesPlayed,
    super.key,
  });

  /// The side games.
  final List<SideGame> games;

  /// Holes everyone has scored.
  final int holesPlayed;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (index, game) in games.indexed) ...<Widget>[
            if (index > 0) SizedBox(width: spacing.cardGap),
            Expanded(
              child: _Tile(game: game, played: holesPlayed >= game.hole),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.game, required this.played});

  final SideGame game;
  final bool played;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      container: true,
      label:
          '${game.name}, hole ${game.hole}, '
          '${played ? 'played' : 'coming up'}.',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(radius.large),
            border: Border.all(color: colours.border),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                played ? Icons.check_circle_outline : Icons.flag_outlined,
                color: colours.gold,
                size: 28,
              ),
              SizedBox(height: spacing.sm),
              Text(
                game.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(
                  color: colours.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Hole ${game.hole}',
                style: typography.caption.copyWith(
                  color: colours.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(height: spacing.sm),
              Text(
                played ? 'Played' : 'Coming up',
                style: typography.caption.copyWith(
                  color: played ? colours.accent : colours.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
