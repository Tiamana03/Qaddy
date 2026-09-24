/// Leaderboard ranking and tie handling.
///
/// See `docs/sprints/sprint-02-04-leaderboard.md`'s "Ranking Rules" and
/// "Tie Handling" sections: sort by lowest relative-to-par, then lowest
/// gross score, then furthest hole completed, then original player order.
/// Players tied on both relative-to-par and gross score share a
/// "T"-prefixed position, with the next distinct position skipping ahead
/// by the size of the tied group (e.g. `1, T1, T1, 4`) — never duplicating
/// a plain rank number.
library;

import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';

/// Ranks [entries], returning them in leaderboard order with computed
/// positions.
List<RankedLeaderboardEntry> rankLeaderboard(List<LeaderboardEntry> entries) {
  final withOriginalIndex =
      <(int, LeaderboardEntry)>[
        for (final (index, entry) in entries.indexed) (index, entry),
      ]..sort((a, b) {
        final relativeCompare = a.$2.relativeToPar.compareTo(
          b.$2.relativeToPar,
        );
        if (relativeCompare != 0) {
          return relativeCompare;
        }
        final grossCompare = a.$2.grossScore.compareTo(b.$2.grossScore);
        if (grossCompare != 0) {
          return grossCompare;
        }
        // "Furthest hole completed" — more holes played ranks first.
        final throughCompare = b.$2.throughHole.compareTo(a.$2.throughHole);
        if (throughCompare != 0) {
          return throughCompare;
        }
        return a.$1.compareTo(b.$1);
      });

  final ranked = <RankedLeaderboardEntry>[];
  for (var i = 0; i < withOriginalIndex.length; i++) {
    final entry = withOriginalIndex[i].$2;
    final tiedWithPrevious =
        i > 0 && _sameStanding(entry, withOriginalIndex[i - 1].$2);
    final tiedWithNext =
        i < withOriginalIndex.length - 1 &&
        _sameStanding(entry, withOriginalIndex[i + 1].$2);
    final rankNumber = tiedWithPrevious
        ? _rankNumberOf(ranked[i - 1].position)
        : i + 1;
    final isTied = tiedWithPrevious || tiedWithNext;

    ranked.add(
      RankedLeaderboardEntry(
        position: isTied ? 'T$rankNumber' : '$rankNumber',
        entry: entry,
        isLeader: rankNumber == 1,
      ),
    );
  }
  return ranked;
}

/// Two entries share a standing when they're equal on both primary
/// ranking criteria (relative-to-par and gross score).
bool _sameStanding(LeaderboardEntry a, LeaderboardEntry b) =>
    a.relativeToPar == b.relativeToPar && a.grossScore == b.grossScore;

int _rankNumberOf(String position) =>
    int.parse(position.startsWith('T') ? position.substring(1) : position);
