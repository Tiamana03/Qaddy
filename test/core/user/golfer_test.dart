import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

import '../../support/memory_document_storage.dart';

ProviderContainer _container(MemoryDocumentStorage storage) {
  final container = ProviderContainer(
    overrides: <Override>[
      golferStorageProvider.overrideWithValue(storage),
      golferClockProvider.overrideWithValue(() => DateTime(2026, 11, 20)),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(resetGolferForTests);
  return container;
}

void main() {
  group('a handicap as typed', () {
    test('reads ordinary numbers, commas and a plus', () {
      expect(parseHandicap('12'), 12);
      expect(parseHandicap(' 8.4 '), 8.4);
      expect(parseHandicap('8,4'), 8.4);
      expect(parseHandicap('+2'), -2);
      expect(parseHandicap('lots'), isNull);
      expect(parseHandicap(''), isNull);
    });

    test('is optional, but must be in range when given', () {
      expect(validateHandicapText(''), isNull);
      expect(validateHandicapText('  '), isNull);
      expect(validateHandicapText('0'), isNull);
      expect(validateHandicapText('54'), isNull);
      expect(validateHandicapText('+3'), isNull);
      expect(validateHandicapText('55'), 'Handicaps run from -10 to 54');
      expect(validateHandicapText('+11'), 'Handicaps run from -10 to 54');
      expect(validateHandicapText('x'), 'Enter a number like 12 or 8.4');
    });
  });

  test('a first name is required and not absurdly long', () {
    expect(validateFirstName(''), isNotNull);
    expect(validateFirstName('   '), isNotNull);
    expect(validateFirstName('Sam'), isNull);
    expect(validateFirstName('x' * 41), 'That is a long name');
  });

  group('the document', () {
    test('round-trips, with and without the optional parts', () {
      final full = GolferProfile(
        firstName: 'Amy',
        handicap: 8.4,
        homeCourse: 'Royal Melbourne',
        joinedAt: DateTime(2026, 11, 20),
      );
      final bare = GolferProfile(
        firstName: 'Sam',
        joinedAt: DateTime(2026, 11, 20),
      );

      final a = decodeGolfer(encodeGolfer(full))!;
      final b = decodeGolfer(encodeGolfer(bare))!;

      expect(a.firstName, 'Amy');
      expect(a.handicap, 8.4);
      expect(a.homeCourse, 'Royal Melbourne');
      expect(b.handicap, isNull);
      expect(b.homeCourse, isNull);
    });

    test('an unreadable one means the golfer is asked again', () {
      for (final bad in <String>[
        '{not json',
        '[]',
        '{"firstName": "", "joinedAt": "2026-11-20T00:00:00.000"}',
        '{"firstName": "Sam"}',
      ]) {
        expect(decodeGolfer(bad), isNull, reason: bad);
      }
    });
  });

  group('who the app thinks the golfer is', () {
    test('is the placeholder golfer until told otherwise', () {
      resetGolferForTests();

      expect(currentUserName, 'Tiamana');
      expect(currentUserDisplayName, 'Tiamana');
      expect(currentUserHandicap, 8.4);
    });

    test('becomes the golfer, handicap and all', () {
      addTearDown(resetGolferForTests);

      useGolfer(
        GolferProfile(
          firstName: ' Amy ',
          handicap: 12,
          joinedAt: DateTime(2026),
        ),
      );

      expect(currentUserName, 'Amy');
      expect(currentUserDisplayName, 'Amy');
      expect(currentUserHandicap, 12);
    });

    test('a golfer who gave no handicap has none', () {
      addTearDown(resetGolferForTests);

      useGolfer(GolferProfile(firstName: 'Amy', joinedAt: DateTime(2026)));

      expect(currentUserHandicap, isNull);
    });

    test("a golfer who shares a seeded friend's name stays distinct", () {
      expect(golferIdFor('Tom'), isNot('Tom'));
      expect(golferIdFor('tom'), isNot('tom'));
      expect(golferIdFor('Tom').trim(), isNot(isEmpty));
      // ...but still reads as the same name.
      expect(
        golferIdFor('Tom').replaceAll(RegExp(r'\p{Cf}', unicode: true), ''),
        'Tom',
      );
      expect(golferIdFor('Amy'), 'Amy');
    });

    test('every seeded friend is on the reserved list', () {
      final seeded = <String>{
        for (final friend in friends) friend.displayName.toLowerCase(),
      };

      expect(reservedGolferNames, containsAll(seeded));
    });
  });

  group('the store', () {
    test('starts empty and remembers the golfer', () async {
      final storage = MemoryDocumentStorage();
      final first = _container(storage);
      expect(first.read(golferProvider), isNull);

      first
          .read(golferProvider.notifier)
          .save(firstName: 'Amy', handicap: 8.4, homeCourse: 'Royal');
      await Future<void>.delayed(Duration.zero);

      final second = _container(storage);
      final golfer = second.read(golferProvider)!;
      expect(golfer.firstName, 'Amy');
      expect(golfer.handicap, 8.4);
      expect(golfer.joinedAt, DateTime(2026, 11, 20));
      expect(currentUserDisplayName, 'Amy');
    });

    test('the name, once set, stays; the rest can change', () {
      final c = _container(MemoryDocumentStorage());
      c.read(golferProvider.notifier)
        ..save(firstName: 'Amy', handicap: 8.4, homeCourse: 'Royal')
        ..save(firstName: 'Zoe', handicap: 6, homeCourse: '  ');

      final golfer = c.read(golferProvider)!;
      expect(golfer.firstName, 'Amy');
      expect(golfer.handicap, 6);
      expect(golfer.homeCourse, isNull);
      expect(golfer.joinedAt, DateTime(2026, 11, 20));
    });

    test('a blank name saves nothing, and a handicap is kept in range', () {
      final c = _container(MemoryDocumentStorage());
      c.read(golferProvider.notifier).save(firstName: '   ');
      expect(c.read(golferProvider), isNull);

      c.read(golferProvider.notifier).save(firstName: 'Amy', handicap: 99);
      expect(c.read(golferProvider)!.handicap, maxHandicap);
    });

    test('screens always have someone to show', () {
      final c = _container(MemoryDocumentStorage());

      expect(c.read(golferDetailsProvider).firstName, 'Tiamana');

      c.read(golferProvider.notifier).save(firstName: 'Amy');

      expect(c.read(golferDetailsProvider).firstName, 'Amy');
      expect(c.read(golferNameProvider), 'Amy');
    });
  });
}
