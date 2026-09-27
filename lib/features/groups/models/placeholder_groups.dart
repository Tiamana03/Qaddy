/// The Groups feature's shared placeholder data.
///
/// See `docs/standards/placeholder-group-data.md`. Per
/// `docs/architecture/friends-engineering-decisions.md`'s "Shared
/// Placeholder Subjects", **Saturday Boys** is the single shared
/// placeholder group with full detail data (Group Details) — the other
/// three groups only need the summary fields shown on the Groups list.
library;

import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

/// Saturday Boys — the shared placeholder group with full detail data.
final Group saturdayBoys = Group(
  id: 'saturday-boys',
  name: 'Saturday Boys',
  ownerId: 'Tiamana',
  memberIds: const <String>[
    'Tiamana',
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
const List<GroupMember> saturdayBoysMembers = <GroupMember>[
  GroupMember(name: 'Tiamana', handicap: 8.4),
  GroupMember(name: 'Tom', handicap: 8),
  GroupMember(name: 'Ben', handicap: 12),
  GroupMember(name: 'Luke', handicap: 5),
  GroupMember(name: 'Josh', handicap: 15),
  GroupMember(name: 'Nick', handicap: 10),
  GroupMember(name: 'Sam', handicap: 18),
  GroupMember(name: 'Liam', handicap: 7),
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
const List<GroupLeaderboardEntry> saturdayBoysLeaderboard =
    <GroupLeaderboardEntry>[
      GroupLeaderboardEntry(rank: 1, player: 'Luke', points: 118),
      GroupLeaderboardEntry(rank: 2, player: 'Tom', points: 111),
      GroupLeaderboardEntry(rank: 3, player: 'Nick', points: 105),
      GroupLeaderboardEntry(rank: 4, player: 'Ben', points: 101),
      GroupLeaderboardEntry(rank: 5, player: 'Tiamana', points: 97),
      GroupLeaderboardEntry(rank: 6, player: 'Liam', points: 93),
      GroupLeaderboardEntry(rank: 7, player: 'Josh', points: 89),
      GroupLeaderboardEntry(rank: 8, player: 'Sam', points: 84),
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
