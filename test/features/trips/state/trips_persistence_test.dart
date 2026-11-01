import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/repositories/trips_storage.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the document in memory, like a device that survives restarts.
class _MemoryStorage implements TripsStorage {
  String? document;
  int writes = 0;

  @override
  String? read() => document;

  @override
  Future<void> write(String value) async {
    document = value;
    writes++;
  }
}

/// A fresh app run on top of [storage].
ProviderContainer _launch(TripsStorage storage) {
  final container = ProviderContainer(
    overrides: [tripsStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  return container;
}

NewTripDraft _draft(String name) => NewTripDraft(
  name: name,
  destination: 'Barossa Valley, Australia',
  startDate: DateTime(2027, 3, 12),
  endDate: DateTime(2027, 3, 14),
);

void main() {
  test('a first launch shows the seed trips and saves nothing yet', () {
    final storage = _MemoryStorage();

    final container = _launch(storage);

    expect(container.read(tripsProvider).trips, hasLength(seedTrips.length));
    expect(storage.writes, 0);
  });

  test('a created trip is there after the app restarts', () {
    final storage = _MemoryStorage();
    final first = _launch(storage);
    final id = first.read(tripsProvider.notifier).createTrip(_draft('Barossa'));

    final second = _launch(storage);

    final restored = second.read(tripsProvider).tripById(id)!;
    expect(restored.name, 'Barossa');
    expect(restored.status, TripStatus.planning);
    expect(second.read(upcomingTripsProvider), contains(restored));
  });

  test('edits, messages and payments survive a restart', () {
    final storage = _MemoryStorage();
    _launch(storage).read(tripsProvider.notifier)
      ..updateTrip(
        melbourneGolfWeekend.id,
        (trip) => trip.copyWith(name: 'Melbourne Boys Trip'),
      )
      ..sendMessage(melbourneGolfWeekend.id, 'See you there')
      ..toggleTask(melbourneGolfWeekend.id, 'task-dinner')
      ..settleDebt(melbourneGolfWeekend.id, from: 'Tiamana', to: 'Ben');

    final second = _launch(storage);
    final plan = second.read(tripPlanProvider(melbourneGolfWeekend.id));

    expect(
      second.read(tripProvider(melbourneGolfWeekend.id))!.name,
      'Melbourne Boys Trip',
    );
    expect(plan.messages.last.text, 'See you there');
    expect(plan.tasks.firstWhere((t) => t.id == 'task-dinner').done, isTrue);
    expect(
      plan.expenses.firstWhere((e) => e.id == 'exp-golf').isSettled('Tiamana'),
      isTrue,
    );
  });

  test('a deleted trip stays deleted', () {
    final storage = _MemoryStorage();
    _launch(
      storage,
    ).read(tripsProvider.notifier).deleteTrip(melbourneGolfWeekend.id);

    final second = _launch(storage);

    expect(second.read(tripProvider(melbourneGolfWeekend.id)), isNull);
    expect(second.read(tripsProvider).trips, hasLength(seedTrips.length - 1));
  });

  test('unreadable saved data falls back to the seed trips', () {
    final storage = _MemoryStorage()..document = '{ this is not valid';

    final container = _launch(storage);

    expect(container.read(tripsProvider).trips, hasLength(seedTrips.length));
  });

  test('every change is saved', () {
    final storage = _MemoryStorage();
    final controller = _launch(storage).read(tripsProvider.notifier)
      ..createTrip(_draft('One'));
    final afterOne = storage.writes;

    controller.createTrip(_draft('Two'));

    expect(afterOne, greaterThan(0));
    expect(storage.writes, greaterThan(afterOne));
  });

  group('on-device storage', () {
    test('keeps the document between launches', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final first = _launch(SharedPreferencesTripsStorage(preferences));
      final id = first
          .read(tripsProvider.notifier)
          .createTrip(_draft('Barossa'));
      // setString completes on a later turn of the event loop.
      await Future<void>.delayed(Duration.zero);

      final again = await SharedPreferences.getInstance();
      final second = _launch(SharedPreferencesTripsStorage(again));

      expect(second.read(tripsProvider).tripById(id)!.name, 'Barossa');
      expect(again.getString(SharedPreferencesTripsStorage.key), isNotNull);
    });

    test('nothing stored reads as null', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();

      expect(SharedPreferencesTripsStorage(preferences).read(), isNull);
    });
  });
}
