/// The Rounds feature's shared placeholder data.
///
/// See `docs/standards/placeholder-data.md`'s "Upcoming Round" and "Side
/// Games" sections. Search and the Dashboard read [upcomingRound]; the Rounds
/// screens read the course, the players and the side games from here too, so
/// there is one source of truth for the Saturday round.
library;

import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/rounds/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

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

/// Richmond Golf Club's eighteen holes: par, stroke index and metres.
const List<CourseHole> richmondHoles = <CourseHole>[
  CourseHole(number: 1, par: 4, strokeIndex: 11, metres: 352),
  CourseHole(number: 2, par: 5, strokeIndex: 3, metres: 486),
  CourseHole(number: 3, par: 3, strokeIndex: 17, metres: 148),
  CourseHole(number: 4, par: 4, strokeIndex: 7, metres: 371),
  CourseHole(number: 5, par: 4, strokeIndex: 1, metres: 414),
  CourseHole(number: 6, par: 5, strokeIndex: 13, metres: 471),
  CourseHole(number: 7, par: 4, strokeIndex: 9, metres: 364),
  CourseHole(number: 8, par: 3, strokeIndex: 15, metres: 163),
  CourseHole(number: 9, par: 4, strokeIndex: 5, metres: 390),
  CourseHole(number: 10, par: 4, strokeIndex: 10, metres: 360),
  CourseHole(number: 11, par: 5, strokeIndex: 2, metres: 502),
  CourseHole(number: 12, par: 3, strokeIndex: 18, metres: 141),
  CourseHole(number: 13, par: 4, strokeIndex: 6, metres: 384),
  CourseHole(number: 14, par: 4, strokeIndex: 8, metres: 373),
  CourseHole(number: 15, par: 5, strokeIndex: 4, metres: 495),
  CourseHole(number: 16, par: 3, strokeIndex: 16, metres: 158),
  CourseHole(number: 17, par: 4, strokeIndex: 12, metres: 347),
  CourseHole(number: 18, par: 4, strokeIndex: 14, metres: 401),
];

/// The standard par-72 layout every other round is played on: par and stroke
/// index, but no distances, because Qaddy does not know the golfer's course
/// yet and will not guess its length. Replaced by the real course when course
/// search arrives.
const List<CourseHole> standardHoles = <CourseHole>[
  CourseHole(number: 1, par: 4, strokeIndex: 11),
  CourseHole(number: 2, par: 5, strokeIndex: 3),
  CourseHole(number: 3, par: 3, strokeIndex: 17),
  CourseHole(number: 4, par: 4, strokeIndex: 7),
  CourseHole(number: 5, par: 4, strokeIndex: 1),
  CourseHole(number: 6, par: 5, strokeIndex: 13),
  CourseHole(number: 7, par: 4, strokeIndex: 9),
  CourseHole(number: 8, par: 3, strokeIndex: 15),
  CourseHole(number: 9, par: 4, strokeIndex: 5),
  CourseHole(number: 10, par: 4, strokeIndex: 10),
  CourseHole(number: 11, par: 5, strokeIndex: 2),
  CourseHole(number: 12, par: 3, strokeIndex: 18),
  CourseHole(number: 13, par: 4, strokeIndex: 6),
  CourseHole(number: 14, par: 4, strokeIndex: 8),
  CourseHole(number: 15, par: 5, strokeIndex: 4),
  CourseHole(number: 16, par: 3, strokeIndex: 16),
  CourseHole(number: 17, par: 4, strokeIndex: 12),
  CourseHole(number: 18, par: 4, strokeIndex: 14),
];

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
