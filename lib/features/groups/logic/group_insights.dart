/// What the Groups screens can say about a group, worked out from what is
/// already known — nothing is invented.
library;

import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

export 'package:qaddy/core/utils/formatting.dart' show ordinal;

/// One line about a group for its card: the next round when there is one,
/// otherwise the size and season.
String groupLine(Group group, {String? nextRound}) {
  if (nextRound != null) {
    return nextRound;
  }
  final members = group.totalMembers == 1
      ? '1 member'
      : '${group.totalMembers} members';
  final season = group.season;
  return season == null ? members : '$members · $season';
}

/// A message rallying a group to its next round: when, where and "who's in?".
String rallyMessage({
  required String groupName,
  required GroupUpcomingRound round,
  required String yourName,
}) =>
    '$groupName: ${round.date} at ${round.teeTime}, ${round.course} '
    "(${round.competition}). Who's in? – $yourName";

/// The season table from the golfer's point of view: the podium, where they
/// stand and the gap to the golfer just ahead (or the one chasing them).
class SeasonRace {
  const SeasonRace({
    required this.standings,
    required this.you,
    required this.roundsRemaining,
  });

  /// Builds the race from a group's leaderboard. [yourName] picks the golfer
  /// out of the table; they may not be in it.
  factory SeasonRace.of(
    List<GroupLeaderboardEntry> leaderboard, {
    required String yourName,
    required int roundsRemaining,
  }) {
    final standings = <GroupLeaderboardEntry>[...leaderboard]
      ..sort((a, b) => a.rank.compareTo(b.rank));
    GroupLeaderboardEntry? you;
    for (final entry in standings) {
      if (entry.player == yourName) {
        you = entry;
      }
    }
    return SeasonRace(
      standings: standings,
      you: you,
      roundsRemaining: roundsRemaining,
    );
  }

  /// Every golfer, best first.
  final List<GroupLeaderboardEntry> standings;

  /// The golfer's own row, or `null` when they are not in the table.
  final GroupLeaderboardEntry? you;

  /// Rounds left in the season.
  final int roundsRemaining;

  /// The top three.
  List<GroupLeaderboardEntry> get podium => standings.take(3).toList();

  /// Whether the golfer is on [podium].
  bool get youOnPodium => you != null && you!.rank <= 3;

  /// "You lead the season", "You're 5th" — or a neutral line when the golfer
  /// is not in the table.
  String get headline {
    final mine = you;
    if (mine == null) {
      return 'Season standings';
    }
    return mine.rank == 1
        ? 'You lead the season'
        : "You're ${ordinal(mine.rank)}";
  }

  /// What separates the golfer from their neighbour: "4 points behind Ben" or,
  /// out in front, "7 points clear of Tom". `null` when there is nobody to
  /// compare with.
  String? get chase {
    final mine = you;
    if (mine == null) {
      return null;
    }
    final index = standings.indexOf(mine);
    if (index > 0) {
      final ahead = standings[index - 1];
      final gap = ahead.points - mine.points;
      return '${_points(gap)} behind ${ahead.player}';
    }
    if (standings.length > 1) {
      final behind = standings[1];
      final gap = mine.points - behind.points;
      return '${_points(gap)} clear of ${behind.player}';
    }
    return null;
  }

  /// "10 rounds to go".
  String get roundsLeft =>
      roundsRemaining == 1 ? '1 round to go' : '$roundsRemaining rounds to go';

  static String _points(int n) => n == 1 ? '1 point' : '$n points';
}

/// The banter to send the group about the season table: who leads and by how
/// much, from the golfer's point of view.
String banterMessage({
  required String groupName,
  required SeasonRace race,
  required String yourName,
}) {
  final standings = race.standings;
  if (standings.length < 2) {
    return "$groupName: who's up for a round? – $yourName";
  }
  final leader = standings.first;
  final gap = leader.points - standings[1].points;
  final points = gap == 1 ? '1 point' : '$gap points';
  if (leader.player == yourName) {
    return "I'm top of the $groupName table by $points. "
        'Come and get me. – $yourName';
  }
  return '${leader.player} leads the $groupName table by $points. '
      'Time someone did something about it. – $yourName';
}

/// A message inviting someone to join [group], ready for the share sheet.
String groupInviteMessage(Group group, String yourName) =>
    'Come and join the ${group.name} on Qaddy. '
    '${group.description ?? 'Rounds, banter and a season to win.'} '
    '– $yourName';
