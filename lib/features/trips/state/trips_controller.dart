/// The store behind every Trips screen.
///
/// Release 1 has no backend (`AppConfig.isBackendConfigured` is false), so
/// trips live on the device: the controller loads them when the app starts and
/// saves after every change (see `TripsStorage`). Every screen reads through
/// the providers below and changes data only through [TripsController], which
/// is the one seam Release 2 swaps for a Supabase-backed repository — screens
/// never touch storage themselves.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/repositories/trips_codec.dart';
import 'package:qaddy/features/trips/repositories/trips_storage.dart';

/// What the Create Trip form collects.
class NewTripDraft {
  const NewTripDraft({
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.visibility = TripVisibility.private,
    this.coverImage,
    this.invitedFriends = const <String>[],
  });

  /// The trip's name.
  final String name;

  /// "City, Country" — the part after the last comma becomes the country.
  final String destination;

  /// First day.
  final DateTime startDate;

  /// Last day.
  final DateTime endDate;

  /// Optional description.
  final String description;

  /// Who can discover the trip.
  final TripVisibility visibility;

  /// A cover preset id (see `trip_cover.dart`).
  final String? coverImage;

  /// Names of the friends to invite.
  final List<String> invitedFriends;
}

/// Every trip and its plan.
class TripsState {
  const TripsState({required this.trips, required this.plans});

  /// All trips, in creation order.
  final List<Trip> trips;

  /// Each trip's plan, keyed by trip id. Trips without an entry have an
  /// empty plan.
  final Map<String, TripPlan> plans;

  /// The trip with [id], or `null`.
  Trip? tripById(String id) {
    for (final trip in trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }

  /// The plan for [id] (empty when nothing has been planned).
  TripPlan planFor(String id) => plans[id] ?? TripPlan.empty;
}

/// The country in a "City, Country" destination (the text after the last
/// comma), or empty when there is no comma.
String countryFromDestination(String destination) {
  final commaAt = destination.lastIndexOf(',');
  return commaAt == -1 ? '' : destination.substring(commaAt + 1).trim();
}

/// The clock the store stamps change-log entries and messages with. Tests
/// override it.
final tripsClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The trips store.
final tripsProvider = NotifierProvider<TripsController, TripsState>(
  TripsController.new,
);

/// One trip, or `null` if it no longer exists.
final tripProvider = Provider.family<Trip?, String>(
  (ref, id) => ref.watch(tripsProvider.select((state) => state.tripById(id))),
);

/// One trip's plan.
final tripPlanProvider = Provider.family<TripPlan, String>(
  (ref, id) => ref.watch(tripsProvider.select((state) => state.planFor(id))),
);

/// Upcoming trips, soonest first.
final upcomingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider.select((state) => state.trips));
  return <Trip>[
    for (final trip in trips)
      if (trip.isUpcoming) trip,
  ]..sort((a, b) => a.startDate.compareTo(b.startDate));
});

/// Completed trips, newest first.
final pastTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider.select((state) => state.trips));
  return <Trip>[
    for (final trip in trips)
      if (trip.status == TripStatus.completed) trip,
  ]..sort((a, b) => b.endDate.compareTo(a.endDate));
});

/// Archived trips, newest first.
final archivedTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider.select((state) => state.trips));
  return <Trip>[
    for (final trip in trips)
      if (trip.status == TripStatus.archived) trip,
  ]..sort((a, b) => b.endDate.compareTo(a.endDate));
});

/// Reads and changes the trips store.
class TripsController extends Notifier<TripsState> {
  int _sequence = 0;

  DateTime get _now => ref.read(tripsClockProvider)();

  @override
  TripsState build() {
    final storage = ref.read(tripsStorageProvider);
    // Save after every change from here on (the starting state is not a
    // change, so seeds are only stored once the golfer does something).
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(storage.write(encodeTrips(next.trips, next.plans)));
    });

    final stored = storage.read();
    final restored = stored == null ? null : decodeTrips(stored);
    if (restored != null) {
      return TripsState(trips: restored.trips, plans: restored.plans);
    }
    return TripsState(
      trips: List<Trip>.of(seedTrips),
      plans: Map<String, TripPlan>.of(seedPlans),
    );
  }

  /// A fresh id with the given prefix, unique within this app run.
  String newId(String prefix) =>
      '$prefix-${_now.microsecondsSinceEpoch}-${_sequence++}';

  // ---------------------------------------------------------------- trips

  /// Creates a trip from [draft] and returns its id. The trip starts in
  /// Planning with the golfer as organiser, invited friends as pending
  /// members, and an otherwise empty plan.
  String createTrip(NewTripDraft draft) {
    final id = newId('trip');
    final country = countryFromDestination(draft.destination);
    final description = draft.description.trim();

    final trip = Trip(
      id: id,
      name: draft.name.trim(),
      destination: draft.destination.trim(),
      country: country,
      startDate: draft.startDate,
      endDate: draft.endDate,
      status: TripStatus.planning,
      organiserId: currentUserName,
      playerCount: 1,
      coverImage: draft.coverImage,
      description: description.isEmpty ? null : description,
      visibility: draft.visibility,
    );

    final members = <TripMember>[
      TripMember(
        displayName: currentUserName,
        handicap: ref.read(golferDetailsProvider).handicap ?? 0,
        role: TripRole.organiser,
        status: ParticipantStatus.confirmed,
      ),
      for (final name in draft.invitedFriends)
        TripMember(
          displayName: name,
          handicap: _handicapOf(name),
          role: TripRole.player,
          status: ParticipantStatus.pending,
        ),
    ];

    state = TripsState(
      trips: <Trip>[...state.trips, trip],
      plans: <String, TripPlan>{
        ...state.plans,
        id: TripPlan(members: members),
      },
    );
    return id;
  }

  /// Applies [change] to the trip with [id]. When [log] is given it is
  /// recorded in the trip's change log.
  void updateTrip(String id, Trip Function(Trip trip) change, {String? log}) {
    final trip = state.tripById(id);
    if (trip == null) {
      return;
    }
    final updated = change(trip);
    state = TripsState(
      trips: <Trip>[
        for (final existing in state.trips)
          if (existing.id == id) updated else existing,
      ],
      plans: state.plans,
    );
    if (log != null) {
      _appendLog(id, log);
    }
  }

  /// Copies a trip (its plan, minus chat and payments) as a new Planning
  /// trip named "name (Copy)" and returns the copy's id, or `null` if the
  /// source doesn't exist.
  String? duplicateTrip(String id) {
    final source = state.tripById(id);
    if (source == null) {
      return null;
    }
    final copyId = newId('trip');
    final plan = state.planFor(id);
    final copy = source.copyWith(
      id: copyId,
      name: '${source.name} (Copy)',
      status: TripStatus.planning,
    );
    final copiedPlan = plan.copyWith(
      messages: const <TripMessage>[],
      updates: const <TripUpdate>[],
      expenses: const [],
      members: <TripMember>[
        for (final member in plan.members)
          member.copyWith(
            status: member.role == TripRole.organiser
                ? ParticipantStatus.confirmed
                : ParticipantStatus.pending,
          ),
      ],
      tasks: <TripTask>[
        for (final task in plan.tasks) task.copyWith(done: false),
      ],
      packing: <PackingItem>[
        for (final item in plan.packing) item.copyWith(packed: false),
      ],
    );
    state = TripsState(
      trips: <Trip>[...state.trips, copy],
      plans: <String, TripPlan>{...state.plans, copyId: copiedPlan},
    );
    _syncPlayerCount(copyId);
    return copyId;
  }

  /// Moves a trip out of the Upcoming/Past lists into Archived.
  void archiveTrip(String id) =>
      updateTrip(id, (trip) => trip.copyWith(status: TripStatus.archived));

  /// Brings an archived trip back: Completed if its dates have passed,
  /// otherwise Planning.
  void unarchiveTrip(String id) {
    final today = _now;
    updateTrip(
      id,
      (trip) => trip.copyWith(
        status:
            trip.endDate.isBefore(DateTime(today.year, today.month, today.day))
            ? TripStatus.completed
            : TripStatus.planning,
      ),
    );
  }

  /// Marks a trip finished.
  void completeTrip(String id) =>
      updateTrip(id, (trip) => trip.copyWith(status: TripStatus.completed));

  /// Permanently removes a trip and its plan.
  void deleteTrip(String id) {
    state = TripsState(
      trips: <Trip>[
        for (final trip in state.trips)
          if (trip.id != id) trip,
      ],
      plans: <String, TripPlan>{
        for (final entry in state.plans.entries)
          if (entry.key != id) entry.key: entry.value,
      },
    );
  }

  /// Removes the trip from the golfer's list. The trip carries on for the
  /// other members; with no backend there are no other accounts, so the store
  /// simply drops it (with a backend this becomes a membership change, and an
  /// organiser leaving would hand the role to another confirmed player).
  void leaveTrip(String id) => deleteTrip(id);

  // ---------------------------------------------------------------- plans

  /// Applies [change] to the plan of trip [id]. When [log] is given it is
  /// recorded in the trip's change log.
  void updatePlan(
    String id,
    TripPlan Function(TripPlan plan) change, {
    String? log,
  }) {
    if (state.tripById(id) == null) {
      return;
    }
    state = TripsState(
      trips: state.trips,
      plans: <String, TripPlan>{...state.plans, id: change(state.planFor(id))},
    );
    if (log != null) {
      _appendLog(id, log);
    }
  }

  /// Replaces a trip's members and keeps `Trip.playerCount` in step.
  void setMembers(String id, List<TripMember> members, {String? log}) {
    updatePlan(id, (plan) => plan.copyWith(members: members), log: log);
    _syncPlayerCount(id);
  }

  /// Takes [name] off the trip. The organiser can't be removed.
  void removeMember(String id, String name) {
    final plan = state.planFor(id);
    final member = plan.members.where((m) => m.displayName == name);
    if (member.isEmpty || member.first.role == TripRole.organiser) {
      return;
    }
    setMembers(id, <TripMember>[
      for (final m in plan.members)
        if (m.displayName != name) m,
    ], log: 'Removed $name');
  }

  /// Invites [names] (as pending members) who aren't already on the trip.
  void inviteFriends(String id, List<String> names) {
    final plan = state.planFor(id);
    final existing = plan.members.map((member) => member.displayName).toSet();
    final seen = <String>{};
    final fresh = <TripMember>[
      for (final name in names)
        if (!existing.contains(name) && seen.add(name))
          TripMember(
            displayName: name,
            handicap: _handicapOf(name),
            role: TripRole.player,
            status: ParticipantStatus.pending,
          ),
    ];
    if (fresh.isEmpty) {
      return;
    }
    setMembers(
      id,
      <TripMember>[...plan.members, ...fresh],
      log: fresh.length == 1
          ? 'Invited ${fresh.first.displayName}'
          : 'Invited ${fresh.length} friends',
    );
  }

  /// Flips a checklist task.
  void toggleTask(String id, String taskId) => updatePlan(
    id,
    (plan) => plan.copyWith(
      tasks: <TripTask>[
        for (final task in plan.tasks)
          if (task.id == taskId) task.copyWith(done: !task.done) else task,
      ],
    ),
  );

  /// Flips a packing-list item.
  void togglePacked(String id, String itemId) => updatePlan(
    id,
    (plan) => plan.copyWith(
      packing: <PackingItem>[
        for (final item in plan.packing)
          if (item.id == itemId) item.copyWith(packed: !item.packed) else item,
      ],
    ),
  );

  /// Records that [member] has paid their share of expense [expenseId] (or
  /// undoes it when [settled] is false).
  void setShareSettled(
    String id,
    String expenseId,
    String member, {
    required bool settled,
  }) => updatePlan(
    id,
    (plan) => plan.copyWith(
      expenses: <TripExpense>[
        for (final expense in plan.expenses)
          if (expense.id == expenseId)
            expense.copyWith(
              settled: settled
                  ? <String>{...expense.settled, member}
                  : (<String>{...expense.settled}..remove(member)),
            )
          else
            expense,
      ],
    ),
    log: settled ? '$member paid their share' : null,
  );

  /// Records that [from] has paid [to] what they owe: every unsettled share
  /// [from] owes [to] is marked paid, and so is every share [to] owed [from]
  /// (the two cancel out in "who owes who").
  void settleDebt(String id, {required String from, required String to}) {
    bool owes(TripExpense e, String debtor, String creditor) =>
        e.paidBy == creditor &&
        e.participants.contains(debtor) &&
        !e.isSettled(debtor);

    updatePlan(
      id,
      (plan) => plan.copyWith(
        expenses: <TripExpense>[
          for (final expense in plan.expenses)
            if (owes(expense, from, to))
              expense.copyWith(settled: <String>{...expense.settled, from})
            else if (owes(expense, to, from))
              expense.copyWith(settled: <String>{...expense.settled, to})
            else
              expense,
        ],
      ),
      log: '$from paid $to',
    );
  }

  // ----------------------------------------------------------------- chat

  /// Sends [text] from the golfer and returns the new message's id (or
  /// `null` for blank text).
  String? sendMessage(String id, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.tripById(id) == null) {
      return null;
    }
    final message = TripMessage(
      id: newId('msg'),
      sender: currentUserName,
      text: trimmed,
      sentAt: _now,
      status: MessageStatus.sent,
    );
    updatePlan(
      id,
      (plan) =>
          plan.copyWith(messages: <TripMessage>[...plan.messages, message]),
    );
    return message.id;
  }

  /// Advances a message's delivery state (placeholder read receipts).
  void setMessageStatus(String id, String messageId, MessageStatus status) =>
      updatePlan(
        id,
        (plan) => plan.copyWith(
          messages: <TripMessage>[
            for (final message in plan.messages)
              if (message.id == messageId)
                message.copyWith(status: status)
              else
                message,
          ],
        ),
      );

  // -------------------------------------------------------------- helpers

  void _appendLog(String id, String text) {
    final plan = state.planFor(id);
    state = TripsState(
      trips: state.trips,
      plans: <String, TripPlan>{
        ...state.plans,
        id: plan.copyWith(
          updates: <TripUpdate>[
            ...plan.updates,
            TripUpdate(text: text, at: _now),
          ],
        ),
      },
    );
  }

  void _syncPlayerCount(String id) {
    final plan = state.planFor(id);
    if (plan.members.isEmpty) {
      return;
    }
    updateTrip(
      id,
      (trip) => trip.copyWith(playerCount: plan.confirmedMembers.length),
    );
  }

  double _handicapOf(String name) {
    for (final friend in friends) {
      if (friend.displayName == name) {
        return friend.handicap;
      }
    }
    return 0;
  }
}
