import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

const _melbourne = 'melbourne-golf-weekend';

NewTripDraft _draft({
  String name = 'Barossa Valley Weekend',
  String destination = 'Barossa Valley, Australia',
  List<String> invited = const <String>[],
}) => NewTripDraft(
  name: name,
  destination: destination,
  startDate: DateTime(2027, 3, 12),
  endDate: DateTime(2027, 3, 14),
  invitedFriends: invited,
);

void main() {
  late ProviderContainer container;
  late TripsController controller;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        tripsClockProvider.overrideWithValue(() => DateTime(2026, 10, 26, 9)),
      ],
    );
    addTearDown(container.dispose);
    controller = container.read(tripsProvider.notifier);
  });

  TripsState state() => container.read(tripsProvider);

  group('createTrip', () {
    test('adds a Planning trip organised by the golfer', () {
      final id = controller.createTrip(_draft());

      final trip = state().tripById(id)!;
      expect(trip.name, 'Barossa Valley Weekend');
      expect(trip.country, 'Australia');
      expect(trip.status, TripStatus.planning);
      expect(trip.organiserId, currentUserName);
      expect(trip.playerCount, 1);
      expect(container.read(upcomingTripsProvider), contains(trip));
    });

    test('trims text, keeps an empty description null, and sorts by date', () {
      final id = controller.createTrip(_draft(name: '  Trimmed  '));

      expect(state().tripById(id)!.name, 'Trimmed');
      expect(state().tripById(id)!.description, isNull);
      final upcoming = container.read(upcomingTripsProvider);
      for (var i = 1; i < upcoming.length; i++) {
        expect(
          upcoming[i].startDate.isBefore(upcoming[i - 1].startDate),
          isFalse,
        );
      }
    });

    test('invites friends as pending members with their handicaps', () {
      final id = controller.createTrip(_draft(invited: <String>['Ben']));

      final members = state().planFor(id).members;
      expect(members.map((m) => m.displayName), <String>[
        currentUserName,
        'Ben',
      ]);
      expect(members.last.status, ParticipantStatus.pending);
      expect(members.last.handicap, isNonZero);
    });

    test('gives every new trip a distinct id', () {
      final a = controller.createTrip(_draft());
      final b = controller.createTrip(_draft());

      expect(a, isNot(b));
    });
  });

  group('trip management', () {
    test('duplicate copies the plan but not chat, payments or progress', () {
      final copyId = controller.duplicateTrip(_melbourne)!;

      expect(state().tripById(copyId)!.name, 'Melbourne Golf Weekend (Copy)');
      expect(state().tripById(copyId)!.status, TripStatus.planning);
      final copy = state().planFor(copyId);
      final original = state().planFor(_melbourne);
      expect(copy.courses, hasLength(original.courses.length));
      expect(copy.messages, isEmpty);
      expect(copy.expenses, isEmpty);
      expect(copy.tasks.every((task) => !task.done), isTrue);
      expect(copy.confirmedMembers, hasLength(1));
    });

    test('archive and unarchive move a trip between lists', () {
      controller.archiveTrip(_melbourne);
      expect(
        container.read(archivedTripsProvider).map((t) => t.id),
        contains(_melbourne),
      );
      expect(
        container.read(upcomingTripsProvider).map((t) => t.id),
        isNot(contains(_melbourne)),
      );

      controller.unarchiveTrip(_melbourne);
      expect(
        container.read(upcomingTripsProvider).map((t) => t.id),
        contains(_melbourne),
      );
    });

    test('delete and leave remove the trip and its plan', () {
      controller.deleteTrip(_melbourne);
      expect(state().tripById(_melbourne), isNull);
      expect(state().plans.containsKey(_melbourne), isFalse);

      final id = controller.createTrip(_draft());
      controller.leaveTrip(id);
      expect(state().tripById(id), isNull);
    });

    test('changes to an unknown trip do nothing', () {
      final before = state().trips.length;

      controller
        ..archiveTrip('nope')
        ..deleteTrip('nope')
        ..sendMessage('nope', 'hello');

      expect(state().trips, hasLength(before));
    });

    test('updateTrip can log the change for the hero card', () {
      controller.updateTrip(
        _melbourne,
        (trip) => trip.copyWith(name: 'Melbourne Boys Trip'),
        log: 'Renamed the trip',
      );

      expect(state().tripById(_melbourne)!.name, 'Melbourne Boys Trip');
      expect(
        state().planFor(_melbourne).latestUpdate?.text,
        'Renamed the trip',
      );
    });
  });

  group('players', () {
    test('invite adds pending members once without changing who is going', () {
      final id = controller.createTrip(_draft());

      controller
        ..inviteFriends(id, <String>['Ben', 'Ben'])
        ..inviteFriends(id, <String>['Ben', 'Luke']);

      final members = state().planFor(id).members;
      expect(members.map((m) => m.displayName), <String>[
        currentUserName,
        'Ben',
        'Luke',
      ]);
      expect(state().tripById(id)!.playerCount, 1);
    });
  });

  group('checklists and chat', () {
    test('toggleTask and togglePacked flip the item', () {
      final task = state().planFor(_melbourne).tasks.first;
      final item = state().planFor(_melbourne).packing.first;

      controller
        ..toggleTask(_melbourne, task.id)
        ..togglePacked(_melbourne, item.id);

      expect(state().planFor(_melbourne).tasks.first.done, !task.done);
      expect(state().planFor(_melbourne).packing.first.packed, !item.packed);
    });

    test('sendMessage appends a trimmed message from the golfer', () {
      final before = state().planFor(_melbourne).messages.length;

      final id = controller.sendMessage(_melbourne, '  Tee time sorted  ');

      final messages = state().planFor(_melbourne).messages;
      expect(id, isNotNull);
      expect(messages, hasLength(before + 1));
      expect(messages.last.text, 'Tee time sorted');
      expect(messages.last.sender, currentUserName);
      expect(messages.last.sentAt, DateTime(2026, 10, 26, 9));
    });

    test('sendMessage ignores blank text', () {
      final before = state().planFor(_melbourne).messages.length;

      expect(controller.sendMessage(_melbourne, '   '), isNull);
      expect(state().planFor(_melbourne).messages, hasLength(before));
    });
  });

  group('expenses', () {
    test('setShareSettled marks a share paid and can undo it', () {
      final expense = state()
          .planFor(_melbourne)
          .expenses
          .firstWhere((e) => e.participants.any((p) => !e.isSettled(p)));
      final debtor = expense.participants.firstWhere(
        (p) => !expense.isSettled(p),
      );

      controller.setShareSettled(_melbourne, expense.id, debtor, settled: true);
      expect(_expense(state(), expense.id).isSettled(debtor), isTrue);

      controller.setShareSettled(
        _melbourne,
        expense.id,
        debtor,
        settled: false,
      );
      expect(_expense(state(), expense.id).isSettled(debtor), isFalse);
    });
  });
}

TripExpense _expense(TripsState state, String id) =>
    state.planFor(_melbourne).expenses.firstWhere((e) => e.id == id);
