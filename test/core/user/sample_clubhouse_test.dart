import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../support/memory_document_storage.dart';

ProviderContainer _container([MemoryDocumentStorage? storage]) {
  final container = ProviderContainer(
    overrides: <Override>[
      if (storage != null) sampleStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(resetSampleClubhouseForTests);
  return container;
}

void main() {
  group('the choice', () {
    test('is on by default, and not yet decided', () {
      final c = _container();

      expect(c.read(sampleClubhouseProvider).enabled, isTrue);
      expect(c.read(sampleClubhouseProvider).decided, isFalse);
      expect(sampleClubhouseOn, isTrue);
    });

    test('is remembered, and switches everything at once', () async {
      final storage = MemoryDocumentStorage();
      final first = _container(storage);
      first.read(sampleClubhouseProvider.notifier).choose(enabled: false);
      await Future<void>.delayed(Duration.zero);
      expect(sampleClubhouseOn, isFalse);

      useSampleClubhouse(on: true);
      final second = _container(storage);

      expect(second.read(sampleClubhouseProvider).enabled, isFalse);
      expect(second.read(sampleClubhouseProvider).decided, isTrue);
      expect(sampleClubhouseOn, isFalse);
    });

    test('an unreadable document means the default', () {
      for (final bad in <String>['{not json', '[]', '"x"']) {
        final c = _container(MemoryDocumentStorage(bad));
        expect(c.read(sampleClubhouseProvider).enabled, isTrue, reason: bad);
      }
    });
  });

  group('every sample list answers to it', () {
    test('there is sample content when it is on', () {
      expect(friends, isNotEmpty);
      expect(friendRequests, isNotEmpty);
      expect(friendActivityFeed, isNotEmpty);
      expect(groups, isNotEmpty);
      expect(upcomingRound.planned, isTrue);
      expect(upcomingRoundInvitees.length, greaterThan(1));
      expect(upcomingRoundSideGames, isNotEmpty);
    });

    test('and none when it is off', () {
      useSampleClubhouse(on: false);
      addTearDown(resetSampleClubhouseForTests);

      expect(friends, isEmpty);
      expect(friendRequests, isEmpty);
      expect(friendActivityFeed, isEmpty);
      expect(groups, isEmpty);
      expect(upcomingRound.planned, isFalse);
      expect(upcomingRoundInvitees, hasLength(1));
      expect(upcomingRoundSideGames, isEmpty);
    });
  });

  group('the sample mates', () {
    test('go and come back with the switch', () {
      final c = _container();
      expect(c.read(friendsProvider).friends, isNotEmpty);

      c.read(friendsProvider.notifier).setSample(on: false);
      expect(c.read(friendsProvider).friends, isEmpty);
      expect(c.read(friendsProvider).requests, isEmpty);

      useSampleClubhouse(on: true);
      c.read(friendsProvider.notifier).setSample(on: true);
      expect(c.read(friendsProvider).friends, isNotEmpty);
    });
  });

  group('the sample trips', () {
    test('a golfer who chose to start empty has no trips', () {
      useSampleClubhouse(on: false);
      final c = _container();

      expect(c.read(tripsProvider).trips, isEmpty);
    });

    test("are removed and restored without touching the golfer's own", () {
      final c = _container();
      final store = c.read(tripsProvider.notifier);
      final mine = store.createTrip(
        NewTripDraft(
          name: 'Barossa',
          destination: 'Barossa Valley',
          startDate: DateTime(2027, 3, 12),
          endDate: DateTime(2027, 3, 14),
        ),
      );
      final sampleCount = seedTrips.length;
      expect(c.read(tripsProvider).trips, hasLength(sampleCount + 1));

      store.setSample(on: false);
      final left = c.read(tripsProvider).trips;
      expect(left.map((t) => t.id), <String>[mine]);
      expect(left.any(TripsController.isSample), isFalse);

      store.setSample(on: true);
      final back = c.read(tripsProvider).trips;
      expect(back, hasLength(sampleCount + 1));
      expect(back.where(TripsController.isSample), hasLength(sampleCount));
      expect(back.map((t) => t.id), contains(mine));
    });

    test('are not added twice', () {
      final c = _container();

      c.read(tripsProvider.notifier).setSample(on: true);

      expect(c.read(tripsProvider).trips, hasLength(seedTrips.length));
    });
  });
}
