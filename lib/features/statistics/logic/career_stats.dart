/// The golfer's story, worked out from the rounds they have actually played.
///
/// Nothing here is invented or estimated: every number comes from the scores
/// recorded in finished rounds. Points are Stableford points, scaled to a
/// full eighteen holes so a round cut short can be compared fairly with a
/// full one.
library;

import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';

/// One finished round, seen from the golfer's seat.
class YourRound {
  const YourRound({
    required this.round,
    required this.standing,
    required this.field,
    required this.holes,
  });

  /// The round itself.
  final Round round;

  /// The golfer's row in that round's table.
  final PlayerStanding standing;

  /// How many golfers played.
  final int field;

  /// How many holes everyone played.
  final int holes;

  /// When it was finished.
  DateTime get date => round.completedAt ?? round.startedAt;

  /// Stableford points over the holes played.
  int get points => standing.points;

  /// Points scaled to eighteen holes, so partial rounds compare fairly.
  double get pointsPer18 => holes == 0 ? 0 : points * 18 / holes;

  /// Whether the golfer won (or shared) a round with someone to beat.
  bool get won => field > 1 && standing.isLeader;
}

/// How the golfer's holes broke down.
class ScoreMix {
  const ScoreMix({
    required this.eagleOrBetter,
    required this.birdies,
    required this.pars,
    required this.bogeys,
    required this.doubleOrWorse,
    required this.pickedUp,
  });

  /// Eagles, albatrosses and holes in one.
  final int eagleOrBetter;

  /// One under par.
  final int birdies;

  /// Level par.
  final int pars;

  /// One over par.
  final int bogeys;

  /// Two or more over par.
  final int doubleOrWorse;

  /// Holes picked up.
  final int pickedUp;

  /// Every hole counted.
  int get total =>
      eagleOrBetter + birdies + pars + bogeys + doubleOrWorse + pickedUp;

  /// Holes at par or better.
  int get parOrBetter => eagleOrBetter + birdies + pars;

  /// The share of holes at par or better (0–1).
  double get parOrBetterRate => total == 0 ? 0 : parOrBetter / total;
}

/// How the golfer plays one hole of the course.
class HoleStat {
  const HoleStat({
    required this.number,
    required this.par,
    required this.averagePoints,
    required this.played,
  });

  /// The hole number.
  final int number;

  /// Its par.
  final int par;

  /// Average Stableford points over the times it was played.
  final double averagePoints;

  /// How many rounds it has been played in.
  final int played;
}

/// The golfer's record against one playing partner.
class Rival {
  const Rival({
    required this.name,
    required this.together,
    required this.youWon,
    required this.theyWon,
    required this.halved,
  });

  /// The partner's name.
  final String name;

  /// Rounds played together.
  final int together;

  /// Rounds the golfer beat them.
  final int youWon;

  /// Rounds they beat the golfer.
  final int theyWon;

  /// Rounds finished level on points.
  final int halved;
}

/// Everything Statistics says, for a golfer with at least one finished round.
class CareerStats {
  const CareerStats({
    required this.rounds,
    required this.chronological,
    required this.holesPlayed,
    required this.wins,
    required this.averagePoints,
    required this.bestRound,
    required this.formTrend,
    required this.mix,
    required this.holeStats,
    required this.parThreeAverage,
    required this.parFourAverage,
    required this.parFiveAverage,
    required this.frontNineAverage,
    required this.backNineAverage,
    required this.mostBirdiesInARound,
    required this.longestWinStreak,
    required this.rivals,
  });

  /// Builds the stats from [history] (any order) for the golfer named [you],
  /// or returns `null` when they have no finished round with a hole played.
  static CareerStats? of(List<Round> history, {required String you}) {
    final mine = <YourRound>[];
    for (final round in history) {
      final holes = round.holesPlayed;
      if (holes == 0 || round.playerNamed(you) == null) {
        continue;
      }
      final standings = standingsOf(round);
      mine.add(
        YourRound(
          round: round,
          standing: standings.firstWhere((s) => s.player.name == you),
          field: round.players.length,
          holes: holes,
        ),
      );
    }
    if (mine.isEmpty) {
      return null;
    }
    mine.sort((a, b) => a.date.compareTo(b.date));

    // Holes: the mix, per-hole averages, par-type and nine-hole averages.
    var eagles = 0;
    var birdies = 0;
    var pars = 0;
    var bogeys = 0;
    var doubles = 0;
    var pickedUp = 0;
    var holesPlayed = 0;
    final holePoints = <int, List<int>>{};
    final parPoints = <int, List<int>>{3: <int>[], 4: <int>[], 5: <int>[]};
    final front = <int>[];
    final back = <int>[];
    var mostBirdies = 0;

    for (final entry in mine) {
      final round = entry.round;
      final me = round.playerNamed(you)!;
      var roundBirdies = 0;
      for (var i = 0; i < round.holes.length; i++) {
        if (!round.isHolePlayed(i)) {
          continue;
        }
        holesPlayed++;
        final hole = round.holes[i];
        final gross = round.grossAt(you, i)!;
        final points = pointsAt(round, me, i);
        switch (scoreKind(gross, hole.par)) {
          case ScoreKind.ace || ScoreKind.albatross || ScoreKind.eagle:
            eagles++;
            roundBirdies++;
          case ScoreKind.birdie:
            birdies++;
            roundBirdies++;
          case ScoreKind.par:
            pars++;
          case ScoreKind.bogey:
            bogeys++;
          case ScoreKind.double || ScoreKind.worse:
            doubles++;
          case ScoreKind.pickedUp:
            pickedUp++;
        }
        holePoints.putIfAbsent(hole.number, () => <int>[]).add(points);
        parPoints[hole.par]?.add(points);
        (i < 9 ? front : back).add(points);
      }
      if (roundBirdies > mostBirdies) {
        mostBirdies = roundBirdies;
      }
    }

    double average(List<int> values) => values.isEmpty
        ? 0
        : values.fold<int>(0, (a, b) => a + b) / values.length;

    final holeStats = <HoleStat>[
      for (final entry in holePoints.entries)
        HoleStat(
          number: entry.key,
          par: mine.first.round.holes[entry.key - 1].par,
          averagePoints: average(entry.value),
          played: entry.value.length,
        ),
    ]..sort((a, b) => a.number.compareTo(b.number));

    // Best round: the most points over eighteen; the latest wins a tie.
    var best = mine.first;
    for (final entry in mine) {
      if (entry.pointsPer18 >= best.pointsPer18) {
        best = entry;
      }
    }

    // Form: the last three rounds against the three before them.
    double? trend;
    if (mine.length >= 4) {
      final recent = mine.sublist(mine.length - 3);
      final beforeAll = mine.sublist(0, mine.length - 3);
      final before = beforeAll.length > 3
          ? beforeAll.sublist(beforeAll.length - 3)
          : beforeAll;
      double mean(List<YourRound> r) =>
          r.fold<double>(0, (a, b) => a + b.pointsPer18) / r.length;
      trend = mean(recent) - mean(before);
    }

    // Win streak: the longest run of consecutive won rounds.
    var streak = 0;
    var run = 0;
    for (final entry in mine) {
      run = entry.won ? run + 1 : 0;
      if (run > streak) {
        streak = run;
      }
    }

    return CareerStats(
      rounds: mine.length,
      chronological: mine,
      holesPlayed: holesPlayed,
      wins: mine.where((r) => r.won).length,
      averagePoints:
          mine.fold<double>(0, (a, b) => a + b.pointsPer18) / mine.length,
      bestRound: best,
      formTrend: trend,
      mix: ScoreMix(
        eagleOrBetter: eagles,
        birdies: birdies,
        pars: pars,
        bogeys: bogeys,
        doubleOrWorse: doubles,
        pickedUp: pickedUp,
      ),
      holeStats: holeStats,
      parThreeAverage: parPoints[3]!.isEmpty ? null : average(parPoints[3]!),
      parFourAverage: parPoints[4]!.isEmpty ? null : average(parPoints[4]!),
      parFiveAverage: parPoints[5]!.isEmpty ? null : average(parPoints[5]!),
      frontNineAverage: front.isEmpty ? null : average(front),
      backNineAverage: back.isEmpty ? null : average(back),
      mostBirdiesInARound: mostBirdies,
      longestWinStreak: streak,
      rivals: _rivals(mine, you),
    );
  }

  /// Rounds the golfer has played (with at least one hole).
  final int rounds;

  /// Those rounds, oldest first.
  final List<YourRound> chronological;

  /// Holes played across them.
  final int holesPlayed;

  /// Rounds won (or shared) against at least one other golfer.
  final int wins;

  /// Average Stableford points per eighteen holes.
  final double averagePoints;

  /// The round with the most points per eighteen.
  final YourRound bestRound;

  /// Points per eighteen in the last three rounds minus the three before.
  /// `null` until there are four rounds to compare.
  final double? formTrend;

  /// How every hole broke down.
  final ScoreMix mix;

  /// Per-hole averages, in hole order.
  final List<HoleStat> holeStats;

  /// Average points on par 3s, if any have been played.
  final double? parThreeAverage;

  /// Average points on par 4s, if any have been played.
  final double? parFourAverage;

  /// Average points on par 5s, if any have been played.
  final double? parFiveAverage;

  /// Average points per hole on the front nine.
  final double? frontNineAverage;

  /// Average points per hole on the back nine.
  final double? backNineAverage;

  /// The most birdies or better in a single round.
  final int mostBirdiesInARound;

  /// The longest run of consecutive round wins.
  final int longestWinStreak;

  /// Head-to-head records, the most-played partner first.
  final List<Rival> rivals;

  /// The last [count] rounds, oldest first — the form guide.
  List<YourRound> form([int count = 8]) => chronological.length <= count
      ? chronological
      : chronological.sublist(chronological.length - count);

  /// The share of rounds won.
  double get winRate => rounds == 0 ? 0 : wins / rounds;

  /// The hole the golfer plays best (most average points; the more-played
  /// hole wins a tie), or `null` if fewer than four holes have been played.
  HoleStat? get favouriteHole => _extreme(best: true);

  /// The hole that gives the golfer most trouble.
  HoleStat? get toughestHole => _extreme(best: false);

  HoleStat? _extreme({required bool best}) {
    if (holeStats.length < 4) {
      return null;
    }
    var pick = holeStats.first;
    for (final stat in holeStats) {
      final better = best
          ? stat.averagePoints > pick.averagePoints
          : stat.averagePoints < pick.averagePoints;
      final level = stat.averagePoints == pick.averagePoints;
      if (better || (level && stat.played > pick.played)) {
        pick = stat;
      }
    }
    return pick;
  }

  static List<Rival> _rivals(List<YourRound> mine, String you) {
    final won = <String, int>{};
    final lost = <String, int>{};
    final level = <String, int>{};
    for (final entry in mine) {
      final table = standingsOf(entry.round);
      for (final other in entry.round.players) {
        if (other.name == you) {
          continue;
        }
        final theirs = table.firstWhere((s) => s.player.name == other.name);
        final bucket = entry.points > theirs.points
            ? won
            : entry.points < theirs.points
            ? lost
            : level;
        bucket[other.name] = (bucket[other.name] ?? 0) + 1;
      }
    }
    final names = <String>{...won.keys, ...lost.keys, ...level.keys};
    final rivals =
        <Rival>[
          for (final name in names)
            Rival(
              name: name,
              together:
                  (won[name] ?? 0) + (lost[name] ?? 0) + (level[name] ?? 0),
              youWon: won[name] ?? 0,
              theyWon: lost[name] ?? 0,
              halved: level[name] ?? 0,
            ),
        ]..sort((a, b) {
          final byTogether = b.together.compareTo(a.together);
          return byTogether != 0 ? byTogether : a.name.compareTo(b.name);
        });
    return rivals;
  }
}
