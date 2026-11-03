/// The Groups feature's shared placeholder data.
///
/// See `docs/standards/placeholder-group-data.md`. Per
/// `docs/architecture/friends-engineering-decisions.md`'s "Shared
/// Placeholder Subjects", **Saturday Boys** is the single shared
/// placeholder group with full detail data (Group Details) — the other
/// three groups only need the summary fields shown on the Groups list.
library;

import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

/// Saturday Boys — the shared placeholder group with full detail data.
final Group saturdayBoys = Group(
  id: 'saturday-boys',
  name: 'Saturday Boys',
  ownerId: currentUserName,
  memberIds: <String>[
    currentUserName,
    'Tom',
    'Ben',
    'Luke',
    'Josh',
    'Nick',
    'Sam',
    'Liam',
  ],
  totalMembers: 8,
  status: GroupStatus.active,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  totalRounds: 18,
  totalTrips: 0,
  description: 'Saturday mornings at Richmond. The banter is compulsory.',
  homeCourse: 'Richmond Golf Club',
  competitionFormat: 'Stableford',
  season: '2026 Season',
);

final Group _wednesdayWarriors = Group(
  id: 'wednesday-warriors',
  name: 'Wednesday Warriors',
  ownerId: 'Luke',
  memberIds: const <String>[],
  totalMembers: 6,
  status: GroupStatus.active,
  createdAt: DateTime(2025, 7),
  updatedAt: DateTime(2025, 7),
  totalRounds: 0,
  totalTrips: 0,
  description: 'Midweek rounds and long lunches.',
  season: '2026 Season',
);

final Group _fridaySocialClub = Group(
  id: 'friday-social-club',
  name: 'Friday Social Club',
  ownerId: 'Ben',
  memberIds: const <String>[],
  totalMembers: 12,
  status: GroupStatus.active,
  createdAt: DateTime(2023, 3),
  updatedAt: DateTime(2023, 3),
  totalRounds: 0,
  totalTrips: 0,
  description: 'Nine holes, a cold one and a Summer Cup to win.',
  season: 'Summer Cup',
);

final Group _familyGolfDays = Group(
  id: 'family-golf-days',
  name: 'Family Golf Days',
  ownerId: 'Tom',
  memberIds: const <String>[],
  totalMembers: 5,
  status: GroupStatus.active,
  createdAt: DateTime(2024, 9),
  updatedAt: DateTime(2024, 9),
  totalRounds: 0,
  totalTrips: 0,
  description: 'Three generations, one fairway.',
  season: 'Casual',
);

/// Every placeholder group — see placeholder-group-data.md's "Groups" table.
final List<Group> groups = <Group>[
  saturdayBoys,
  _wednesdayWarriors,
  _fridaySocialClub,
  _familyGolfDays,
];

/// Saturday Boys' named members with handicaps — see
/// placeholder-group-data.md's "Saturday Boys > Members" table.
final List<GroupMember> saturdayBoysMembers = <GroupMember>[
  GroupMember(name: currentUserName, handicap: currentUserHandicap ?? 0),
  const GroupMember(name: 'Tom', handicap: 8),
  const GroupMember(name: 'Ben', handicap: 12),
  const GroupMember(name: 'Luke', handicap: 5),
  const GroupMember(name: 'Josh', handicap: 15),
  const GroupMember(name: 'Nick', handicap: 10),
  const GroupMember(name: 'Sam', handicap: 18),
  const GroupMember(name: 'Liam', handicap: 7),
];

/// Saturday Boys' current season summary.
const GroupSeasonSummary saturdayBoysSeasonSummary = GroupSeasonSummary(
  season: '2026 Season',
  roundsCompleted: 8,
  roundsRemaining: 10,
  leader: 'Luke',
  averageAttendance: 7.5,
);

/// Saturday Boys' season leaderboard.
final List<GroupLeaderboardEntry> saturdayBoysLeaderboard =
    <GroupLeaderboardEntry>[
      const GroupLeaderboardEntry(rank: 1, player: 'Luke', points: 118),
      const GroupLeaderboardEntry(rank: 2, player: 'Tom', points: 111),
      const GroupLeaderboardEntry(rank: 3, player: 'Nick', points: 105),
      const GroupLeaderboardEntry(rank: 4, player: 'Ben', points: 101),
      GroupLeaderboardEntry(rank: 5, player: currentUserName, points: 97),
      const GroupLeaderboardEntry(rank: 6, player: 'Liam', points: 93),
      const GroupLeaderboardEntry(rank: 7, player: 'Josh', points: 89),
      const GroupLeaderboardEntry(rank: 8, player: 'Sam', points: 84),
    ];

/// Saturday Boys' upcoming group round.
const GroupUpcomingRound saturdayBoysUpcomingRound = GroupUpcomingRound(
  course: 'Richmond Golf Club',
  date: 'Saturday',
  teeTime: '8:20 AM',
  competition: 'Stableford',
  players: 8,
  sideGames: 'Longest Drive, Nearest the Pin',
);

// Group detail data is keyed by group id. Release 1 has full detail for
// Saturday Boys only (see the file header); every other group answers with an
// empty list or `null`, and the screens say so kindly instead of inventing it.

/// The named members of [group] with their handicaps.
List<GroupMember> membersOf(Group group) =>
    group.id == saturdayBoys.id ? saturdayBoysMembers : const <GroupMember>[];

/// [group]'s season standings, best first.
List<GroupLeaderboardEntry> leaderboardOf(Group group) =>
    group.id == saturdayBoys.id
    ? saturdayBoysLeaderboard
    : const <GroupLeaderboardEntry>[];

/// [group]'s season summary, or `null` when there is none.
GroupSeasonSummary? seasonSummaryOf(Group group) =>
    group.id == saturdayBoys.id ? saturdayBoysSeasonSummary : null;

/// [group]'s next round, or `null` when none is planned.
GroupUpcomingRound? upcomingRoundOf(Group group) =>
    group.id == saturdayBoys.id ? saturdayBoysUpcomingRound : null;

/// The group with [id], or `null`.
Group? groupById(String id) {
  for (final group in groups) {
    if (group.id == id) {
      return group;
    }
  }
  return null;
}
