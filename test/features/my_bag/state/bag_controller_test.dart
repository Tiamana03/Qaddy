import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/models/placeholder_my_bag.dart';
import 'package:qaddy/features/my_bag/repositories/bag_codec.dart';
import 'package:qaddy/features/my_bag/state/bag_controller.dart';

/// Remembers the document so a second store can "restart" from it.
class _MemoryStorage implements DocumentStorage {
  String? document;

  @override
  String? read() => document;

  @override
  Future<void> write(String document) async => this.document = document;
}

ProviderContainer _container([DocumentStorage? storage]) {
  final container = ProviderContainer(
    overrides: <Override>[
      if (storage != null) bagStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

BagClub _club(ProviderContainer c, String id) =>
    c.read(bagProvider).firstWhere((club) => club.id == id);

void main() {
  group('the bag as it starts', () {
    test('is the seed bag', () {
      final c = _container();

      expect(c.read(bagProvider), hasLength(seedBagClubs.length));
      expect(_club(c, '7-iron').carryMetres, 145);
    });

    test('has a driver, a putter and a ball, and keeps to 14 clubs', () {
      final names = seedBagClubs.map((club) => club.id).toList();

      expect(names, containsAll(<String>['driver', 'putter', 'ball']));
      expect(
        seedBagClubs.where((club) => club.family != ClubFamily.ball),
        hasLength(lessThanOrEqualTo(14)),
      );
    });
  });

  group('editing', () {
    test('changes only what is given, on only that club', () {
      final c = _container();

      c.read(bagProvider.notifier).update('7-iron', carryMetres: 150);

      expect(_club(c, '7-iron').carryMetres, 150);
      expect(_club(c, '7-iron').model, 'TaylorMade P790');
      expect(_club(c, '8-iron').carryMetres, 135);
    });

    test('a new model is trimmed, and a blank one is ignored', () {
      final c = _container();

      c.read(bagProvider.notifier).update('driver', model: '  Ping G430  ');
      expect(_club(c, 'driver').model, 'Ping G430');

      c.read(bagProvider.notifier).update('driver', model: '   ');
      expect(_club(c, 'driver').model, 'Ping G430');
    });

    test('a carry stays within a believable range', () {
      final c = _container();

      c.read(bagProvider.notifier).update('driver', carryMetres: 900);
      expect(_club(c, 'driver').carryMetres, maxCarryMetres);

      c.read(bagProvider.notifier).update('driver', carryMetres: 3);
      expect(_club(c, 'driver').carryMetres, minCarryMetres);
    });

    test('a putter or a ball never gets a carry', () {
      final c = _container();

      c.read(bagProvider.notifier).update('putter', carryMetres: 100);

      expect(_club(c, 'putter').carryMetres, isNull);
    });

    test('notes can be written, trimmed, cleared and are kept short', () {
      final c = _container();
      final bag = c.read(bagProvider.notifier)
        ..update('7-iron', note: '  Smooth.  ');
      expect(_club(c, '7-iron').note, 'Smooth.');

      bag.update('7-iron', note: '');
      expect(_club(c, '7-iron').note, '');
      expect(_club(c, '7-iron').hasNote, isFalse);

      bag.update('7-iron', note: 'x' * 500);
      expect(_club(c, '7-iron').note, hasLength(maxNoteLength));
    });

    test('confidence stays between 0 and 5', () {
      final c = _container();

      c.read(bagProvider.notifier).update('driver', confidence: 9);
      expect(_club(c, 'driver').confidence, 5);

      c.read(bagProvider.notifier).update('driver', confidence: -2);
      expect(_club(c, 'driver').confidence, 0);
    });

    test('an unknown club is ignored', () {
      final c = _container();

      c.read(bagProvider.notifier).update('mashie', carryMetres: 100);

      expect(c.read(bagProvider), hasLength(seedBagClubs.length));
    });
  });

  group('saving', () {
    test('edits survive a restart', () async {
      final storage = _MemoryStorage();
      final first = _container(storage);
      first
          .read(bagProvider.notifier)
          .update(
            '7-iron',
            carryMetres: 152,
            note: 'Plays 5 m longer downhill',
            confidence: 4,
            model: 'Mizuno JPX',
          );
      await Future<void>.delayed(Duration.zero);

      final second = _container(storage);

      expect(_club(second, '7-iron').carryMetres, 152);
      expect(_club(second, '7-iron').note, 'Plays 5 m longer downhill');
      expect(_club(second, '7-iron').confidence, 4);
      expect(_club(second, '7-iron').model, 'Mizuno JPX');
      // Untouched clubs are as they started.
      expect(_club(second, 'driver').carryMetres, 235);
    });

    test('the starting bag is not saved until something changes', () async {
      final storage = _MemoryStorage();

      _container(storage).read(bagProvider);
      await Future<void>.delayed(Duration.zero);

      expect(storage.document, isNull);
    });

    test('an unreadable document starts the bag as new', () {
      final c = _container(_MemoryStorage()..document = '{not json');

      expect(_club(c, '7-iron').carryMetres, 145);
    });

    test('a club added to the starting bag later still appears', () {
      final storage = _MemoryStorage()
        ..document = encodeBag(
          seedBagClubs.where((club) => club.id != '3-wood').toList(),
        );

      final c = _container(storage);

      expect(c.read(bagProvider).any((club) => club.id == '3-wood'), isTrue);
    });
  });
}
