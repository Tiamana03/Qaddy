/// The Rounds feature's shared placeholder data.
///
/// See `docs/standards/placeholder-data.md`'s "Upcoming Round" and "Side
/// Games" sections. Search and the Dashboard read [upcomingRound]; the Rounds
/// screens read the course, the players and the side games from here too, so
/// there is one source of truth for the Saturday round.
library;

import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/courses/data/sample_course_data.dart';
import 'package:qaddy/features/courses/data/standard_layout.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

export 'package:qaddy/features/courses/data/sample_course_data.dart'
    show richmondHoles;
export 'package:qaddy/features/courses/data/standard_layout.dart'
    show standardHoles;

/// The single Release 1 upcoming round — see placeholder-data.md's
/// "Upcoming Round".
class UpcomingRound {
  const UpcomingRound({
    required this.course,
    required this.date,
    required this.teeTime,
    required this.players,
    required this.weather,
    required this.format,
    required this.holes,
    this.planned = true,
  });

  /// The course being played.
  final String course;

  /// The round's date, as sourced (e.g. "Saturday").
  final String date;

  /// The scheduled tee time, as sourced (e.g. "8:20 AM").
  final String teeTime;

  /// How many players are confirmed/pending.
  final int players;

  /// The forecast conditions, as sourced (e.g. "21°C Sunny").
  final String weather;

  /// The scoring format.
  final String format;

  /// Number of holes.
  final int holes;

  /// Whether this round is planned for a day and time (the sample round) or
  /// is just a round the golfer can start now.
  final bool planned;
}

/// Richmond Golf Club, Saturday 8:20 AM — the shared placeholder round.
const UpcomingRound _sampleRound = UpcomingRound(
  course: 'Richmond Golf Club',
  date: 'Saturday',
  teeTime: '8:20 AM',
  players: 8,
  weather: '21°C Sunny',
  format: 'Stableford',
  holes: 18,
);

/// The round to play next: Saturday's sample round while the Sample Clubhouse
/// is on; otherwise no plan at all, just a round the golfer can start, at
/// their home course.
UpcomingRound get upcomingRound => sampleClubhouseOn
    ? _sampleRound
    : UpcomingRound(
        course: currentUserHomeCourse ?? 'Your course',
        date: '',
        teeTime: '',
        players: 1,
        weather: '',
        format: 'Stableford',
        holes: 18,
        planned: false,
      );

/// The holes the next round is played on: the sample course's while the Sample
/// Clubhouse round is planned, the standard layout otherwise.
List<CourseHole> get upcomingRoundHoles =>
    upcomingRound.planned ? richmondHoles : standardHoles;

/// A golfer invited to the round, and whether they have said yes yet.
class RoundInvitee {
  const RoundInvitee({required this.player, this.confirmed = true});

  /// Who is invited.
  final RoundPlayer player;

  /// Whether they have confirmed (Josh has not).
  final bool confirmed;
}

/// Everyone invited to Saturday's round — see placeholder-data.md's "Friends"
/// table (8 entries, matching the round's player count). The golfer is first.
final List<RoundInvitee> _sampleInvitees = <RoundInvitee>[
  RoundInvitee(
    player: RoundPlayer(
      name: currentUserName,
      handicap: currentUserHandicap ?? 0,
    ),
  ),
  const RoundInvitee(player: RoundPlayer(name: 'Tom', handicap: 8)),
  const RoundInvitee(player: RoundPlayer(name: 'Ben', handicap: 12)),
  const RoundInvitee(player: RoundPlayer(name: 'Luke', handicap: 5)),
  const RoundInvitee(
    player: RoundPlayer(name: 'Josh', handicap: 15),
    confirmed: false,
  ),
  const RoundInvitee(player: RoundPlayer(name: 'Nick', handicap: 10)),
  const RoundInvitee(player: RoundPlayer(name: 'Sam', handicap: 18)),
  const RoundInvitee(player: RoundPlayer(name: 'Liam', handicap: 7)),
];

/// Who can be asked to the next round: the golfer, and — while the Sample
/// Clubhouse is on — the sample mates. The golfer is always first.
List<RoundInvitee> get upcomingRoundInvitees =>
    sampleClubhouseOn ? _sampleInvitees : <RoundInvitee>[_sampleInvitees.first];

/// A side game played on one hole.
class SideGame {
  const SideGame({required this.name, required this.hole});

  /// What it is, e.g. "Longest Drive".
  final String name;

  /// The hole it is played on (1–18).
  final int hole;
}

/// Saturday's side games — see placeholder-data.md's "Side Games".
const List<SideGame> _sampleSideGames = <SideGame>[
  SideGame(name: 'Longest Drive', hole: 5),
  SideGame(name: 'Nearest the Pin', hole: 12),
  SideGame(name: 'Drive & Chip', hole: 16),
];

/// The sample round's side games (none without the Sample Clubhouse).
List<SideGame> get upcomingRoundSideGames =>
    sampleClubhouseOn ? _sampleSideGames : const <SideGame>[];
