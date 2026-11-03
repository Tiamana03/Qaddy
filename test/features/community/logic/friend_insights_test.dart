import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/rivalry_record.dart';

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

  group('messages', () {
    test('an invitation names the friend and the sender', () {
      expect(
        inviteMessage(_friend(id: 'luke'), 'Tiamana'),
        startsWith('Fancy a round, LUKE?'),
      );
      expect(inviteMessage(_friend(), 'Tiamana'), endsWith('– Tiamana'));
    });
  });
}
