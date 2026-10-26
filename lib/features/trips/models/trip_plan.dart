/// Everything planned for one trip — the aggregate behind Trip Details,
/// Planning, Travel, Accommodation, Golf, Expenses and Chat.
///
/// See `docs/architecture/trip-data-model.md`. Kept separate from `Trip`
/// (which holds only the summary a list needs) so a freshly created trip
/// can start with an empty plan and fill it in section by section.
library;

import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

/// A to-do on the trip's planning checklist (e.g. "Book rental cars").
class TripTask {
  const TripTask({
    required this.id,
    required this.title,
    this.done = false,
    this.due,
  });

  /// Unique identifier within the trip.
  final String id;

  /// What needs doing.
  final String title;

  /// Whether it has been done.
  final bool done;

  /// When it should be done by, if it has a deadline.
  final DateTime? due;

  /// A copy with the given fields replaced.
  TripTask copyWith({
    String? title,
    bool? done,
    DateTime? due,
    bool clearDue = false,
  }) {
    return TripTask(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      due: clearDue ? null : (due ?? this.due),
    );
  }
}

/// One item on the packing list.
class PackingItem {
  const PackingItem({
    required this.id,
    required this.label,
    this.packed = false,
  });

  /// Unique identifier within the trip.
  final String id;

  /// What to pack.
  final String label;

  /// Whether it's packed.
  final bool packed;

  /// A copy with the given fields replaced.
  PackingItem copyWith({String? label, bool? packed}) {
    return PackingItem(
      id: id,
      label: label ?? this.label,
      packed: packed ?? this.packed,
    );
  }
}

/// A line in the trip's change log, e.g. "Royal Melbourne tee time moved".
class TripUpdate {
  const TripUpdate({required this.text, required this.at});

  /// What changed.
  final String text;

  /// When it changed.
  final DateTime at;
}

/// The complete plan for a trip.
class TripPlan {
  const TripPlan({
    this.members = const <TripMember>[],
    this.courses = const <TripCourse>[],
    this.playingGroups = const <TripPlayingGroup>[],
    this.sideGames = const <TripSideGame>[],
    this.flights = const <TripFlight>[],
    this.accommodations = const <TripAccommodation>[],
    this.transport = const <TripTransport>[],
    this.itinerary = const <TripItineraryItem>[],
    this.expenses = const <TripExpense>[],
    this.tasks = const <TripTask>[],
    this.packing = const <PackingItem>[],
    this.weather = const <TripWeatherForecast>[],
    this.messages = const <TripMessage>[],
    this.chatSettings = const TripChatSettings(),
    this.notes = '',
    this.updates = const <TripUpdate>[],
  });

  /// An empty plan, for a trip with nothing planned yet.
  static const TripPlan empty = TripPlan();

  /// Participants, including pending and declined invitations.
  final List<TripMember> members;

  /// Courses and tee times.
  final List<TripCourse> courses;

  /// Playing groups for the trip's rounds.
  final List<TripPlayingGroup> playingGroups;

  /// Configured side games.
  final List<TripSideGame> sideGames;

  /// Flights.
  final List<TripFlight> flights;

  /// Places the group is staying.
  final List<TripAccommodation> accommodations;

  /// Local transport.
  final List<TripTransport> transport;

  /// User-added timeline entries (dinners, activities…).
  final List<TripItineraryItem> itinerary;

  /// Shared expenses.
  final List<TripExpense> expenses;

  /// The planning checklist.
  final List<TripTask> tasks;

  /// The packing list.
  final List<PackingItem> packing;

  /// Manually entered forecasts.
  final List<TripWeatherForecast> weather;

  /// Chat messages, oldest first.
  final List<TripMessage> messages;

  /// Chat preferences.
  final TripChatSettings chatSettings;

  /// Free-form trip notes.
  final String notes;

  /// Change log, oldest first.
  final List<TripUpdate> updates;

  /// Members who have accepted.
  List<TripMember> get confirmedMembers => <TripMember>[
    for (final member in members)
      if (member.status == ParticipantStatus.confirmed) member,
  ];

  /// Members who have been invited but not yet replied.
  List<TripMember> get pendingMembers => <TripMember>[
    for (final member in members)
      if (member.status == ParticipantStatus.pending) member,
  ];

  /// Share of the planning checklist that is done (0–1), or `null` when
  /// there is no checklist to measure.
  double? get planningProgress {
    if (tasks.isEmpty) {
      return null;
    }
    return tasks.where((task) => task.done).length / tasks.length;
  }

  /// The first checklist task still to do, soonest deadline first (tasks
  /// without a deadline come last, in list order).
  TripTask? get nextTask {
    final open = <TripTask>[
      for (final task in tasks)
        if (!task.done) task,
    ];
    if (open.isEmpty) {
      return null;
    }
    final dated = open.where((task) => task.due != null).toList()
      ..sort((a, b) => a.due!.compareTo(b.due!));
    return dated.isNotEmpty ? dated.first : open.first;
  }

  /// The most recent change-log entry.
  TripUpdate? get latestUpdate => updates.isEmpty ? null : updates.last;

  /// A copy with the given fields replaced.
  TripPlan copyWith({
    List<TripMember>? members,
    List<TripCourse>? courses,
    List<TripPlayingGroup>? playingGroups,
    List<TripSideGame>? sideGames,
    List<TripFlight>? flights,
    List<TripAccommodation>? accommodations,
    List<TripTransport>? transport,
    List<TripItineraryItem>? itinerary,
    List<TripExpense>? expenses,
    List<TripTask>? tasks,
    List<PackingItem>? packing,
    List<TripWeatherForecast>? weather,
    List<TripMessage>? messages,
    TripChatSettings? chatSettings,
    String? notes,
    List<TripUpdate>? updates,
  }) {
    return TripPlan(
      members: members ?? this.members,
      courses: courses ?? this.courses,
      playingGroups: playingGroups ?? this.playingGroups,
      sideGames: sideGames ?? this.sideGames,
      flights: flights ?? this.flights,
      accommodations: accommodations ?? this.accommodations,
      transport: transport ?? this.transport,
      itinerary: itinerary ?? this.itinerary,
      expenses: expenses ?? this.expenses,
      tasks: tasks ?? this.tasks,
      packing: packing ?? this.packing,
      weather: weather ?? this.weather,
      messages: messages ?? this.messages,
      chatSettings: chatSettings ?? this.chatSettings,
      notes: notes ?? this.notes,
      updates: updates ?? this.updates,
    );
  }
}
