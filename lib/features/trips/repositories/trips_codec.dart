/// Turns the trips store into JSON and back, so trips survive the app being
/// closed.
///
/// The format is versioned (`version`). Decoding is forgiving about what a
/// future or older app wrote — missing fields take their defaults, unknown
/// enum names fall back — but a document it cannot understand at all decodes
/// to `null`, and the caller falls back to the seed trips rather than
/// crashing on launch.
library;

import 'dart:convert';

import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

/// The current document format.
const int tripsDocumentVersion = 1;

/// Every trip and its plan, as stored.
class StoredTrips {
  const StoredTrips({required this.trips, required this.plans});

  /// All trips, in creation order.
  final List<Trip> trips;

  /// Each trip's plan, keyed by trip id.
  final Map<String, TripPlan> plans;
}

/// Encodes [trips] and [plans] as a JSON document.
String encodeTrips(List<Trip> trips, Map<String, TripPlan> plans) {
  return jsonEncode(<String, Object?>{
    'version': tripsDocumentVersion,
    'trips': <Object?>[for (final trip in trips) _trip(trip)],
    'plans': <String, Object?>{
      for (final entry in plans.entries) entry.key: _plan(entry.value),
    },
  });
}

/// Decodes a document written by [encodeTrips], or `null` if it is not one
/// this app can read.
StoredTrips? decodeTrips(String source) {
  try {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic> ||
        root['version'] != tripsDocumentVersion) {
      return null;
    }
    final trips = <Trip>[
      for (final json in root['trips'] as List<dynamic>)
        _tripFrom(json as Map<String, dynamic>),
    ];
    final plans = <String, TripPlan>{
      for (final entry in (root['plans'] as Map<String, dynamic>).entries)
        entry.key: _planFrom(entry.value as Map<String, dynamic>),
    };
    return StoredTrips(trips: trips, plans: plans);
  } on Object {
    return null;
  }
}

// ----------------------------------------------------------------- helpers

String _date(DateTime value) => value.toIso8601String();

DateTime _dateFrom(Object? value) => DateTime.parse(value! as String);

DateTime? _optDateFrom(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

T _enumFrom<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

List<String> _strings(Object? value) => <String>[
  for (final item in (value as List<dynamic>? ?? const <dynamic>[]))
    item as String,
];

double? _optDouble(Object? value) => (value as num?)?.toDouble();

List<T> _list<T>(Object? value, T Function(Map<String, dynamic>) from) => <T>[
  for (final item in (value as List<dynamic>? ?? const <dynamic>[]))
    from(item as Map<String, dynamic>),
];

// -------------------------------------------------------------------- trip

Map<String, Object?> _trip(Trip trip) => <String, Object?>{
  'id': trip.id,
  'name': trip.name,
  'destination': trip.destination,
  'country': trip.country,
  'startDate': _date(trip.startDate),
  'endDate': _date(trip.endDate),
  'status': trip.status.name,
  'organiserId': trip.organiserId,
  'playerCount': trip.playerCount,
  'coverImage': trip.coverImage,
  'description': trip.description,
  'visibility': trip.visibility.name,
};

Trip _tripFrom(Map<String, dynamic> json) => Trip(
  id: json['id'] as String,
  name: json['name'] as String,
  destination: json['destination'] as String,
  country: json['country'] as String? ?? '',
  startDate: _dateFrom(json['startDate']),
  endDate: _dateFrom(json['endDate']),
  status: _enumFrom(TripStatus.values, json['status'], TripStatus.planning),
  organiserId: json['organiserId'] as String,
  playerCount: json['playerCount'] as int? ?? 1,
  coverImage: json['coverImage'] as String?,
  description: json['description'] as String?,
  visibility: _enumFrom(
    TripVisibility.values,
    json['visibility'],
    TripVisibility.private,
  ),
);

// -------------------------------------------------------------------- plan

Map<String, Object?> _plan(TripPlan plan) => <String, Object?>{
  'members': <Object?>[
    for (final m in plan.members)
      <String, Object?>{
        'displayName': m.displayName,
        'handicap': m.handicap,
        'role': m.role.name,
        'status': m.status.name,
      },
  ],
  'courses': <Object?>[
    for (final c in plan.courses)
      <String, Object?>{
        'id': c.id,
        'name': c.name,
        'teeTime': _date(c.teeTime),
        'address': c.address,
        'phone': c.phone,
        'website': c.website,
        'courseRating': c.courseRating,
        'slope': c.slope,
        'players': c.players,
        'greenFee': c.greenFee,
        'dressCode': c.dressCode,
        'notes': c.notes,
      },
  ],
  'playingGroups': <Object?>[
    for (final g in plan.playingGroups)
      <String, Object?>{'name': g.name, 'players': g.players},
  ],
  'sideGames': <Object?>[
    for (final g in plan.sideGames)
      <String, Object?>{'name': g.name, 'hole': g.hole},
  ],
  'flights': <Object?>[
    for (final f in plan.flights)
      <String, Object?>{
        'id': f.id,
        'airline': f.airline,
        'flightNumber': f.flightNumber,
        'fromAirport': f.fromAirport,
        'toAirport': f.toAirport,
        'departure': _date(f.departure),
        'arrival': _date(f.arrival),
        'terminal': f.terminal,
        'gate': f.gate,
        'seat': f.seat,
        'boarding': f.boarding == null ? null : _date(f.boarding!),
        'bookingReference': f.bookingReference,
        'checkInStatus': f.checkInStatus.name,
      },
  ],
  'accommodations': <Object?>[
    for (final a in plan.accommodations)
      <String, Object?>{
        'id': a.id,
        'name': a.name,
        'checkIn': _date(a.checkIn),
        'checkOut': _date(a.checkOut),
        'address': a.address,
        'phone': a.phone,
        'website': a.website,
        'bookingNumber': a.bookingNumber,
        'rooms': <Object?>[
          for (final r in a.rooms)
            <String, Object?>{'name': r.name, 'guests': r.guests},
        ],
        'totalCost': a.totalCost,
        'notes': a.notes,
      },
  ],
  'transport': <Object?>[
    for (final t in plan.transport)
      <String, Object?>{
        'id': t.id,
        'type': t.type.name,
        'pickup': _date(t.pickup),
        'from': t.from,
        'to': t.to,
        'driver': t.driver,
        'vehicle': t.vehicle,
        'bookingReference': t.bookingReference,
        'notes': t.notes,
      },
  ],
  'itinerary': <Object?>[
    for (final i in plan.itinerary)
      <String, Object?>{
        'id': i.id,
        'kind': i.kind.name,
        'title': i.title,
        'start': _date(i.start),
        'location': i.location,
        'notes': i.notes,
      },
  ],
  'expenses': <Object?>[
    for (final e in plan.expenses)
      <String, Object?>{
        'id': e.id,
        'title': e.title,
        'category': e.category.name,
        'amount': e.amount,
        'paidBy': e.paidBy,
        'date': _date(e.date),
        'participants': e.participants,
        'splitMode': e.splitMode.name,
        'customShares': e.customShares,
        'settled': e.settled.toList(),
      },
  ],
  'tasks': <Object?>[
    for (final t in plan.tasks)
      <String, Object?>{
        'id': t.id,
        'title': t.title,
        'done': t.done,
        'due': t.due == null ? null : _date(t.due!),
      },
  ],
  'packing': <Object?>[
    for (final p in plan.packing)
      <String, Object?>{'id': p.id, 'label': p.label, 'packed': p.packed},
  ],
  'weather': <Object?>[
    for (final w in plan.weather)
      <String, Object?>{
        'id': w.id,
        'day': w.day,
        'condition': w.condition.name,
        'high': w.high,
        'low': w.low,
      },
  ],
  'messages': <Object?>[
    for (final m in plan.messages)
      <String, Object?>{
        'id': m.id,
        'sender': m.sender,
        'text': m.text,
        'sentAt': _date(m.sentAt),
        'status': m.status.name,
      },
  ],
  'chatSettings': <String, Object?>{
    'muted': plan.chatSettings.muted,
    'readReceipts': plan.chatSettings.readReceipts,
    'typingIndicators': plan.chatSettings.typingIndicators,
  },
  'notes': plan.notes,
  'updates': <Object?>[
    for (final u in plan.updates)
      <String, Object?>{'text': u.text, 'at': _date(u.at)},
  ],
};

TripPlan _planFrom(Map<String, dynamic> json) {
  final settings = json['chatSettings'] as Map<String, dynamic>? ?? const {};

  return TripPlan(
    members: _list(
      json['members'],
      (m) => TripMember(
        displayName: m['displayName'] as String,
        handicap: (m['handicap'] as num).toDouble(),
        role: _enumFrom(TripRole.values, m['role'], TripRole.player),
        status: _enumFrom(
          ParticipantStatus.values,
          m['status'],
          ParticipantStatus.pending,
        ),
      ),
    ),
    courses: _list(
      json['courses'],
      (c) => TripCourse(
        id: c['id'] as String,
        name: c['name'] as String,
        teeTime: _dateFrom(c['teeTime']),
        address: c['address'] as String? ?? '',
        phone: c['phone'] as String? ?? '',
        website: c['website'] as String? ?? '',
        courseRating: _optDouble(c['courseRating']),
        slope: c['slope'] as int?,
        players: _strings(c['players']),
        greenFee: _optDouble(c['greenFee']),
        dressCode: c['dressCode'] as String? ?? '',
        notes: c['notes'] as String? ?? '',
      ),
    ),
    playingGroups: _list(
      json['playingGroups'],
      (g) => TripPlayingGroup(
        name: g['name'] as String,
        players: _strings(g['players']),
      ),
    ),
    sideGames: _list(
      json['sideGames'],
      (g) => TripSideGame(name: g['name'] as String, hole: g['hole'] as int),
    ),
    flights: _list(
      json['flights'],
      (f) => TripFlight(
        id: f['id'] as String,
        airline: f['airline'] as String,
        flightNumber: f['flightNumber'] as String,
        fromAirport: f['fromAirport'] as String,
        toAirport: f['toAirport'] as String,
        departure: _dateFrom(f['departure']),
        arrival: _dateFrom(f['arrival']),
        terminal: f['terminal'] as String? ?? '',
        gate: f['gate'] as String? ?? '',
        seat: f['seat'] as String? ?? '',
        boarding: _optDateFrom(f['boarding']),
        bookingReference: f['bookingReference'] as String? ?? '',
        checkInStatus: _enumFrom(
          FlightCheckInStatus.values,
          f['checkInStatus'],
          FlightCheckInStatus.notOpen,
        ),
      ),
    ),
    accommodations: _list(
      json['accommodations'],
      (a) => TripAccommodation(
        id: a['id'] as String,
        name: a['name'] as String,
        checkIn: _dateFrom(a['checkIn']),
        checkOut: _dateFrom(a['checkOut']),
        address: a['address'] as String? ?? '',
        phone: a['phone'] as String? ?? '',
        website: a['website'] as String? ?? '',
        bookingNumber: a['bookingNumber'] as String? ?? '',
        rooms: _list(
          a['rooms'],
          (r) => TripRoom(
            name: r['name'] as String,
            guests: _strings(r['guests']),
          ),
        ),
        totalCost: _optDouble(a['totalCost']),
        notes: a['notes'] as String? ?? '',
      ),
    ),
    transport: _list(
      json['transport'],
      (t) => TripTransport(
        id: t['id'] as String,
        type: _enumFrom(TransportType.values, t['type'], TransportType.other),
        pickup: _dateFrom(t['pickup']),
        from: t['from'] as String? ?? '',
        to: t['to'] as String? ?? '',
        driver: t['driver'] as String? ?? '',
        vehicle: t['vehicle'] as String? ?? '',
        bookingReference: t['bookingReference'] as String? ?? '',
        notes: t['notes'] as String? ?? '',
      ),
    ),
    itinerary: _list(
      json['itinerary'],
      (i) => TripItineraryItem(
        id: i['id'] as String,
        kind: _enumFrom(ItineraryKind.values, i['kind'], ItineraryKind.other),
        title: i['title'] as String,
        start: _dateFrom(i['start']),
        location: i['location'] as String? ?? '',
        notes: i['notes'] as String? ?? '',
      ),
    ),
    expenses: _list(
      json['expenses'],
      (e) => TripExpense(
        id: e['id'] as String,
        title: e['title'] as String,
        category: _enumFrom(
          ExpenseCategory.values,
          e['category'],
          ExpenseCategory.other,
        ),
        amount: (e['amount'] as num).toDouble(),
        paidBy: e['paidBy'] as String,
        date: _dateFrom(e['date']),
        participants: _strings(e['participants']),
        splitMode: _enumFrom(
          ExpenseSplitMode.values,
          e['splitMode'],
          ExpenseSplitMode.equal,
        ),
        customShares: <String, double>{
          for (final entry
              in (e['customShares'] as Map<String, dynamic>? ??
                      const <String, dynamic>{})
                  .entries)
            entry.key: (entry.value as num).toDouble(),
        },
        settled: _strings(e['settled']).toSet(),
      ),
    ),
    tasks: _list(
      json['tasks'],
      (t) => TripTask(
        id: t['id'] as String,
        title: t['title'] as String,
        done: t['done'] as bool? ?? false,
        due: _optDateFrom(t['due']),
      ),
    ),
    packing: _list(
      json['packing'],
      (p) => PackingItem(
        id: p['id'] as String,
        label: p['label'] as String,
        packed: p['packed'] as bool? ?? false,
      ),
    ),
    weather: _list(
      json['weather'],
      (w) => TripWeatherForecast(
        id: w['id'] as String,
        day: w['day'] as String,
        condition: _enumFrom(
          WeatherCondition.values,
          w['condition'],
          WeatherCondition.sunny,
        ),
        high: w['high'] as int,
        low: w['low'] as int,
      ),
    ),
    messages: _list(
      json['messages'],
      (m) => TripMessage(
        id: m['id'] as String,
        sender: m['sender'] as String,
        text: m['text'] as String,
        sentAt: _dateFrom(m['sentAt']),
        status: _enumFrom(
          MessageStatus.values,
          m['status'],
          MessageStatus.read,
        ),
      ),
    ),
    chatSettings: TripChatSettings(
      muted: settings['muted'] as bool? ?? false,
      readReceipts: settings['readReceipts'] as bool? ?? true,
      typingIndicators: settings['typingIndicators'] as bool? ?? true,
    ),
    notes: json['notes'] as String? ?? '',
    updates: _list(
      json['updates'],
      (u) => TripUpdate(text: u['text'] as String, at: _dateFrom(u['at'])),
    ),
  );
}
