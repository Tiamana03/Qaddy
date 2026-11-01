import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/rivalry_record.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

final DateTime _now = DateTime(2026, 11, 1, 18);

Friend _friend({String id = 'a', double handicap = 10, DateTime? lastPlayed}) =>
    Friend(
      id: id,
      displayName: id.toUpperCase(),
      initials: id.toUpperCase(),
      handicap: handicap,
      homeClub: 'Club',
      location: 'Town',
      status: FriendStatus.confirmed,
      favourite: false,
      lastPlayed: lastPlayed ?? _now,
      roundsPlayed: 3,
      createdAt: DateTime(2022),
    );

void main() {
  group('playedRecently', () {
    test('is true for today and yesterday, false after that', () {
      expect(playedRecently(_friend(lastPlayed: _now), _now), isTrue);
      expect(
        playedRecently(
          _friend(lastPlayed: _now.subtract(const Duration(days: 1))),
          _now,
        ),
        isTrue,
      );
      expect(
        playedRecently(
          _friend(lastPlayed: _now.subtract(const Duration(days: 3))),
          _now,
        ),
        isFalse,
      );
    });

    test('recentlyActive keeps only those who did', () {
      final list = <Friend>[
        _friend(id: 'x'),
        _friend(id: 'y', lastPlayed: _now.subtract(const Duration(days: 9))),
      ];

      expect(recentlyActive(list, _now).map((f) => f.id), <String>['x']);
    });
  });

  group('bestHandicap', () {
    test('is the lowest handicap', () {
      final best = bestHandicap(<Friend>[
        _friend(handicap: 12),
        _friend(id: 'b', handicap: 5),
        _friend(id: 'c', handicap: 8),
      ]);

      expect(best!.id, 'b');
    });

    test('goes to the first of a tie, and null for nobody', () {
      final tie = bestHandicap(<Friend>[
        _friend(handicap: 5),
        _friend(id: 'b', handicap: 5),
      ]);

      expect(tie!.id, 'a');
      expect(bestHandicap(<Friend>[]), isNull);
    });
  });

  group('lastPlayedLabel', () {
    String label(Duration ago) =>
        lastPlayedLabel(_friend(lastPlayed: _now.subtract(ago)), _now);

    test('speaks in days, then weeks, then months', () {
      expect(label(Duration.zero), 'Played today');
      expect(label(const Duration(days: 1)), 'Played yesterday');
      expect(label(const Duration(days: 4)), 'Played 4 days ago');
      expect(label(const Duration(days: 21)), 'Played 3 weeks ago');
      expect(label(const Duration(days: 90)), 'Played 3 months ago');
      expect(label(const Duration(days: 500)), 'Played over a year ago');
    });
  });

  test('handicapLabel drops a pointless .0', () {
    expect(handicapLabel(8), '8');
    expect(handicapLabel(8.4), '8.4');
    expect(handicapLabel(12), '12');
  });

  group('RivalrySummary', () {
    RivalrySummary summary({int wins = 6, int losses = 5, int draws = 1}) =>
        RivalrySummary.of(
          RivalryRecord(
            friendName: 'Tom',
            roundsPlayed: wins + losses + draws,
            wins: wins,
            losses: losses,
            draws: draws,
            lastResult: 'Won by 2 strokes at Richmond Golf Club',
          ),
        );

    test('says who is ahead and by how much', () {
      expect(summary().headline, 'You lead by 1');
      expect(summary(wins: 4, losses: 7).headline, 'Tom leads by 3');
      expect(summary(wins: 5).headline, 'All square');
    });

    test("works out the golfer's share of decided rounds", () {
      expect(summary().youShare, closeTo(6 / 11, 0.0001));
      expect(summary(wins: 0, losses: 0, draws: 3).youShare, 0.5);
    });

    test('writes a challenge to send to the rival', () {
      final message = summary().challengeMessage('Tiamana');

      expect(
        message,
        contains('Tiamana vs Tom: 6–5 (1 halved) after 12 rounds'),
      );
      expect(message, contains('Won by 2 strokes at Richmond Golf Club'));
      expect(message, endsWith('Fancy a rematch?'));
    });

    test('a golfer who is behind asks to even it up', () {
      final message = summary(
        wins: 3,
        losses: 6,
        draws: 0,
      ).challengeMessage('T');

      expect(message, isNot(contains('halved')));
      expect(message, endsWith('Time for me to even it up.'));
    });
  });

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

  group('messages', () {
    test('an invitation names the friend and the sender', () {
      expect(
        inviteMessage(_friend(id: 'luke'), 'Tiamana'),
        startsWith('Fancy a round, LUKE?'),
      );
      expect(inviteMessage(_friend(), 'Tiamana'), endsWith('– Tiamana'));
    });

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
