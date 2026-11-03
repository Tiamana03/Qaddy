import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/my_bag/logic/bag_insights.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/models/placeholder_my_bag.dart';

BagClub _club(
  String name,
  double? carry, {
  ClubFamily family = ClubFamily.iron,
  int confidence = 0,
}) => BagClub(
  id: name,
  name: name,
  family: family,
  model: 'Model',
  carryMetres: carry,
  confidence: confidence,
);

void main() {
  group('gapKind', () {
    test('reads a gap by how much of the course it leaves uncovered', () {
      expect(gapKind(10), GapKind.tight);
      expect(gapKind(18), GapKind.tight);
      expect(gapKind(19), GapKind.watch);
      expect(gapKind(25), GapKind.watch);
      expect(gapKind(26), GapKind.hole);
    });
  });

  group('ordering and gaps', () {
    final bag = <BagClub>[
      _club('Short', 100),
      _club('Putter', null, family: ClubFamily.putter),
      _club('Long', 200),
      _club('Mid', 150),
    ];

    test(
      'orders the clubs by carry, longest first, leaving out the putter',
      () {
        expect(carryClubs(bag).map((c) => c.name), <String>[
          'Long',
          'Mid',
          'Short',
        ]);
      },
    );

    test('equal carries keep the bag order', () {
      final tied = <BagClub>[_club('A', 150), _club('B', 150)];

      expect(carryClubs(tied).map((c) => c.name), <String>['A', 'B']);
    });

    test('measures the gap between each club and the next down', () {
      final gaps = gapsOf(bag);

      expect(gaps.map((g) => g.metres), <double>[50, 50]);
      expect(gaps.first.longer.name, 'Long');
      expect(gaps.first.shorter.name, 'Mid');
      expect(gaps.every((g) => g.kind == GapKind.hole), isTrue);
    });

    test('finds the widest gap, the longer end first on a tie', () {
      final widest = widestGap(bag)!;

      expect(widest.longer.name, 'Long');
    });

    test('has no gaps with fewer than two carries', () {
      expect(gapsOf(<BagClub>[_club('Solo', 100)]), isEmpty);
      expect(widestGap(<BagClub>[]), isNull);
    });
  });

  group('counting and picking', () {
    test('the ball is not a club', () {
      final bag = <BagClub>[
        _club('A', 100),
        _club('Ball', null, family: ClubFamily.ball),
      ];

      expect(clubCount(bag), 1);
    });

    test('the longest club', () {
      expect(longestClub(seedBagClubs)!.name, 'Driver');
      expect(longestClub(<BagClub>[]), isNull);
    });

    test('the go-to club is the most trusted, the first on a tie', () {
      final bag = <BagClub>[
        _club('A', 100, confidence: 3),
        _club('B', 120, confidence: 5),
        _club('C', 140, confidence: 5),
      ];

      expect(goToClub(bag)!.name, 'B');
    });

    test('there is no go-to club until one is rated, and never the ball', () {
      expect(goToClub(<BagClub>[_club('A', 100)]), isNull);
      expect(
        goToClub(<BagClub>[
          _club('Ball', null, family: ClubFamily.ball, confidence: 5),
        ]),
        isNull,
      );
    });
  });

  group('gappingStory', () {
    test('praises a bag with no wide gap', () {
      final bag = <BagClub>[
        _club('7i', 145),
        _club('8i', 135),
        _club('9i', 125),
      ];

      expect(
        gappingStory(bag),
        'Beautifully gapped: every club is within 10m of the next.',
      );
    });

    test('keeps an eye on a gap that is getting wide', () {
      final bag = <BagClub>[_club('Hybrid', 190), _club('5 iron', 168)];

      expect(
        gappingStory(bag),
        'Nicely spread. Keep an eye on the 22m gap between your Hybrid and '
        '5 iron.',
      );
    });

    test('points out a hole in the bag', () {
      final bag = <BagClub>[_club('Driver', 235), _club('5 iron', 165)];

      expect(
        gappingStory(bag),
        'A 70m hole between your Driver and 5 iron: worth a look.',
      );
    });

    test('says what is missing when there is nothing to compare', () {
      expect(gappingStory(<BagClub>[]), contains('appears here'));
    });

    test('the starting bag is nicely spread, not perfect', () {
      expect(gappingStory(seedBagClubs), startsWith('Nicely spread.'));
    });
  });

  test('confidence has words', () {
    expect(confidenceLabel(0), 'Not rated');
    expect(confidenceLabel(1), 'Shaky');
    expect(confidenceLabel(3), 'Reliable');
    expect(confidenceLabel(5), 'Go-to');
  });
}
