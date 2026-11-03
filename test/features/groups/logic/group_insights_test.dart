import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

void main() {
  group('groupLine', () {
    Group group({int members = 8, String? season}) => Group(
      id: 'g',
      name: 'G',
      ownerId: 'x',
      memberIds: const <String>[],
      totalMembers: members,
      status: GroupStatus.active,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      totalRounds: 0,
      totalTrips: 0,
      season: season,
    );

    test('prefers the next round', () {
      expect(
        groupLine(group(), nextRound: 'Next round Saturday'),
        'Next round Saturday',
      );
    });

    test('otherwise gives the size and season', () {
      expect(
        groupLine(group(season: '2026 Season')),
        '8 members · 2026 Season',
      );
      expect(groupLine(group(members: 1)), '1 member');
    });
  });

  group('ordinal', () {
    test('words places the way golfers say them', () {
      expect(
        <int>[1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 101, 111].map(ordinal),
        <String>[
          '1st',
          '2nd',
          '3rd',
          '4th',
          '11th',
          '12th',
          '13th',
          '21st',
          '22nd',
          '23rd',
          '101st',
          '111th',
        ],
      );
    });
  });

  group('rallyMessage', () {
    test("a rally says when, where and who's in", () {
      const round = GroupUpcomingRound(
        course: 'Richmond Golf Club',
        date: 'Saturday',
        teeTime: '8:20 AM',
        competition: 'Stableford',
        players: 8,
        sideGames: '',
      );

      expect(
        rallyMessage(groupName: 'Saturday Boys', round: round, yourName: 'T'),
        'Saturday Boys: Saturday at 8:20 AM, Richmond Golf Club '
        "(Stableford). Who's in? – T",
      );
    });
  });

  group('SeasonRace', () {
    SeasonRace race(String you, {int rounds = 10}) => SeasonRace.of(
      const <GroupLeaderboardEntry>[
        GroupLeaderboardEntry(rank: 3, player: 'Nick', points: 105),
        GroupLeaderboardEntry(rank: 1, player: 'Luke', points: 118),
        GroupLeaderboardEntry(rank: 2, player: 'Tom', points: 111),
        GroupLeaderboardEntry(rank: 4, player: 'Ben', points: 101),
        GroupLeaderboardEntry(rank: 5, player: 'Me', points: 100),
      ],
      yourName: you,
      roundsRemaining: rounds,
    );

    test('puts the podium in order, however the table arrives', () {
      expect(race('Me').podium.map((e) => e.player), <String>[
        'Luke',
        'Tom',
        'Nick',
      ]);
    });

    test('says where the golfer stands and who to catch', () {
      final r = race('Me');

      expect(r.headline, "You're 5th");
      expect(r.chase, '1 point behind Ben');
      expect(r.youOnPodium, isFalse);
    });

    test('a leader is told how far clear they are', () {
      final r = race('Luke');

      expect(r.headline, 'You lead the season');
      expect(r.chase, '7 points clear of Tom');
      expect(r.youOnPodium, isTrue);
    });

    test('counts the rounds left', () {
      expect(race('Me').roundsLeft, '10 rounds to go');
      expect(race('Me', rounds: 1).roundsLeft, '1 round to go');
    });

    test('copes with a golfer who is not in the table', () {
      final r = race('Nobody');

      expect(r.headline, 'Season standings');
      expect(r.chase, isNull);
      expect(r.youOnPodium, isFalse);
    });
  });
}
