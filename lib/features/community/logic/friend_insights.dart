/// What Friends Home can say about your friends, worked out from what is
/// already known about them — nothing is invented.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/rivalry_record.dart';
import 'package:qaddy/features/groups/models/group.dart';

/// Whether [friend] played within the last two days — the gold ring on their
/// avatar, a quiet "they're out there" signal.
bool playedRecently(Friend friend, DateTime now) =>
    now.difference(friend.lastPlayed) < const Duration(days: 2);

/// The friends who [playedRecently].
List<Friend> recentlyActive(List<Friend> friends, DateTime now) => <Friend>[
  for (final friend in friends)
    if (playedRecently(friend, now)) friend,
];

/// The friend with the lowest handicap (the best golfer), or `null` for an
/// empty list. Ties go to whoever comes first.
Friend? bestHandicap(List<Friend> friends) {
  Friend? best;
  for (final friend in friends) {
    if (best == null || friend.handicap < best.handicap) {
      best = friend;
    }
  }
  return best;
}

/// "Played today", "Played yesterday", "Played 3 days ago", "Played 2 weeks
/// ago" — when [friend] last hit a ball, relative to [now].
String lastPlayedLabel(Friend friend, DateTime now) {
  final days = friend.lastPlayed.calendarDaysUntil(now);
  if (days <= 0) {
    return 'Played today';
  }
  if (days == 1) {
    return 'Played yesterday';
  }
  if (days < 14) {
    return 'Played $days days ago';
  }
  if (days < 60) {
    return 'Played ${(days / 7).round()} weeks ago';
  }
  if (days < 365) {
    return 'Played ${(days / 30).round()} months ago';
  }
  return 'Played over a year ago';
}

/// A handicap as golfers write it: "8", "8.4", "12".
String handicapLabel(double handicap) => handicap == handicap.roundToDouble()
    ? handicap.toStringAsFixed(0)
    : handicap.toStringAsFixed(1);

/// A head-to-head record from the golfer's point of view.
class RivalrySummary {
  const RivalrySummary({
    required this.friendName,
    required this.rounds,
    required this.youWins,
    required this.theirWins,
    required this.draws,
    required this.lastResult,
  });

  /// Builds the summary of [record].
  factory RivalrySummary.of(RivalryRecord record) => RivalrySummary(
    friendName: record.friendName,
    rounds: record.roundsPlayed,
    youWins: record.wins,
    theirWins: record.losses,
    draws: record.draws,
    lastResult: record.lastResult,
  );

  /// The rival.
  final String friendName;

  /// Rounds played against each other.
  final int rounds;

  /// Rounds the golfer won.
  final int youWins;

  /// Rounds the rival won.
  final int theirWins;

  /// Rounds that were halved.
  final int draws;

  /// How the last round ended.
  final String lastResult;

  /// Wins ahead (positive), behind (negative) or level (0).
  int get lead => youWins - theirWins;

  /// The golfer's share of decided rounds (0–1); half when nothing has been
  /// decided yet.
  double get youShare {
    final decided = youWins + theirWins;
    return decided == 0 ? 0.5 : youWins / decided;
  }

  /// "You lead by 1", "Tom leads by 3" or "All square".
  String get headline {
    if (lead == 0) {
      return 'All square';
    }
    final by = lead.abs();
    final margin = by == 1 ? 'by 1' : 'by $by';
    return lead > 0 ? 'You lead $margin' : '$friendName leads $margin';
  }

  /// A message to send the rival, with the record and a nudge to settle it.
  String challengeMessage(String yourName) =>
      '$yourName vs $friendName: $youWins–$theirWins'
      '${draws == 0 ? '' : ' ($draws halved)'} after $rounds rounds. '
      'Last time: $lastResult. '
      '${lead < 0 ? 'Time for me to even it up.' : 'Fancy a rematch?'}';
}

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
