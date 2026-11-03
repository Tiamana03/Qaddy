/// The Trips feature's seed placeholder data.
///
/// See `docs/standards/placeholder-trip-data.md`. These are the trips the
/// in-memory store starts with (`state/trips_controller.dart`); everything a
/// golfer then creates or edits lives in that store, not here.
///
/// Melbourne Golf Weekend is the one trip seeded with a complete plan, so
/// every screen has real content to show. The other three trips start with
/// only their summary — their detail sections show empty states inviting the
/// golfer to fill them in, exactly as a trip they had just created would.
///
/// Every contact detail, booking reference, rating and price below is
/// fictional placeholder data (phone numbers use the reserved "555" range
/// and websites use `.example`).
library;

import 'package:qaddy/core/user/current_user.dart' as user;
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_result.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

// Every organiser is the golfer — placeholder-trip-data.md's Engineering
// Decisions. Read lazily, so the seeded trips are built around whoever the
// golfer said they are (see `docs/features/identity.md`).
String get _organiser => user.currentUserName;

String get _organiserDisplay => user.currentUserDisplayName;

/// The signed-in golfer's id — the organiser of every seeded trip and of any
/// trip created in the app.
String get currentUserName => _organiser;

/// Melbourne Golf Weekend — the one trip seeded with a complete plan.
final Trip melbourneGolfWeekend = Trip(
  id: 'melbourne-golf-weekend',
  name: 'Melbourne Golf Weekend',
  destination: 'Melbourne, Australia',
  country: 'Australia',
  startDate: DateTime.utc(2026, 11, 28),
  endDate: DateTime.utc(2026, 12),
  status: TripStatus.confirmed,
  organiserId: _organiser,
  playerCount: 8,
  coverImage: 'fairway',
  description:
      'Three Sandbelt rounds, a winery lunch and a weekend away with the '
      'Saturday Boys.',
);

/// Gold Coast Golf Escape — summary-only upcoming trip.
final Trip goldCoastGolfEscape = Trip(
  id: 'gold-coast-golf-escape',
  name: 'Gold Coast Golf Escape',
  destination: 'Gold Coast, Australia',
  country: 'Australia',
  startDate: DateTime.utc(2027, 1, 12),
  endDate: DateTime.utc(2027, 1, 16),
  status: TripStatus.planning,
  organiserId: _organiser,
  playerCount: 12,
  coverImage: 'coast',
);

/// Tasmania Golf Tour — summary-only past trip.
final Trip tasmaniaGolfTour = Trip(
  id: 'tasmania-golf-tour',
  name: 'Tasmania Golf Tour',
  destination: 'Hobart, Australia',
  country: 'Australia',
  startDate: DateTime.utc(2026, 4, 4),
  endDate: DateTime.utc(2026, 4, 8),
  status: TripStatus.completed,
  organiserId: _organiser,
  playerCount: 8,
  coverImage: 'highlands',
);

/// Queenstown Golf Adventure — summary-only past trip.
final Trip queenstownGolfAdventure = Trip(
  id: 'queenstown-golf-adventure',
  name: 'Queenstown Golf Adventure',
  destination: 'Queenstown, New Zealand',
  country: 'New Zealand',
  startDate: DateTime.utc(2025, 10, 10),
  endDate: DateTime.utc(2025, 10, 15),
  status: TripStatus.completed,
  organiserId: _organiser,
  playerCount: 10,
  coverImage: 'sunset',
);

/// Every seeded trip.
final List<Trip> seedTrips = <Trip>[
  melbourneGolfWeekend,
  goldCoastGolfEscape,
  tasmaniaGolfTour,
  queenstownGolfAdventure,
];

final List<String> _squad = <String>[
  _organiser,
  'Ben',
  'Luke',
  'Josh',
  'Nick',
  'Sam',
  'Liam',
  'Jack',
];

/// Melbourne Golf Weekend's plan.
final TripPlan melbourneGolfWeekendPlan = TripPlan(
  members: <TripMember>[
    TripMember(
      displayName: _organiser,
      handicap: user.currentUserHandicap ?? 0,
      role: TripRole.organiser,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Ben',
      handicap: 12,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Luke',
      handicap: 5,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Josh',
      handicap: 15,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Nick',
      handicap: 10,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Sam',
      handicap: 18,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Liam',
      handicap: 7,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Jack',
      handicap: 22,
      role: TripRole.player,
      status: ParticipantStatus.confirmed,
    ),
    const TripMember(
      displayName: 'Tom',
      handicap: 8,
      role: TripRole.player,
      status: ParticipantStatus.pending,
    ),
  ],
  courses: <TripCourse>[
    TripCourse(
      id: 'kingston-heath',
      name: 'Kingston Heath',
      teeTime: DateTime(2026, 11, 29, 8, 10),
      address: '1 Heath Road, Cheltenham VIC 3192',
      phone: '(03) 5550 0141',
      website: 'www.kingstonheath.example',
      courseRating: 73.8,
      slope: 138,
      players: _squad,
      greenFee: 250,
      dressCode:
          'Collared shirt and tailored shorts or trousers. Soft spikes only.',
      notes:
          'Carts are limited, so book early. Meet in the pro shop 30 minutes '
          'before.',
    ),
    TripCourse(
      id: 'royal-melbourne',
      name: 'Royal Melbourne',
      teeTime: DateTime(2026, 11, 30, 8),
      address: '12 Cheltenham Road, Black Rock VIC 3193',
      phone: '(03) 5550 0182',
      website: 'www.royalmelbourne.example',
      courseRating: 74.5,
      slope: 140,
      players: _squad,
      greenFee: 300,
      dressCode: 'Jacket not required. Collared shirt, no denim.',
      notes: 'Caddies available on request — arrange in the pro shop.',
    ),
    TripCourse(
      id: 'peninsula-kingswood',
      name: 'Peninsula Kingswood',
      teeTime: DateTime(2026, 12, 1, 9, 20),
      address: '450 Country Club Drive, Frankston VIC 3199',
      phone: '(03) 5550 0127',
      website: 'www.peninsulakingswood.example',
      courseRating: 72.6,
      slope: 132,
      players: _squad,
      greenFee: 180,
      dressCode: 'Smart golf attire. Metal spikes not permitted.',
      notes: 'Last round — leave by 3 pm for the airport.',
    ),
  ],
  playingGroups: <TripPlayingGroup>[
    TripPlayingGroup(
      name: 'Group 1',
      players: <String>[_organiser, 'Ben', 'Luke', 'Josh'],
    ),
    const TripPlayingGroup(
      name: 'Group 2',
      players: <String>['Nick', 'Sam', 'Liam', 'Jack'],
    ),
  ],
  sideGames: const <TripSideGame>[
    TripSideGame(name: 'Longest Drive', hole: 5),
    TripSideGame(name: 'Nearest The Pin', hole: 8),
    TripSideGame(name: 'Longest Putt', hole: 12),
  ],
  flights: <TripFlight>[
    TripFlight(
      id: 'qf431',
      airline: 'Qantas',
      flightNumber: 'QF431',
      fromAirport: 'Sydney',
      toAirport: 'Melbourne',
      departure: DateTime(2026, 11, 28, 8, 30),
      arrival: DateTime(2026, 11, 28, 10, 5),
      terminal: 'Terminal 3',
      gate: 'Gate 12',
      seat: '14A',
      boarding: DateTime(2026, 11, 28, 7, 55),
      bookingReference: 'QK7P2M',
    ),
    TripFlight(
      id: 'qf438',
      airline: 'Qantas',
      flightNumber: 'QF438',
      fromAirport: 'Melbourne',
      toAirport: 'Sydney',
      departure: DateTime(2026, 12, 1, 18, 15),
      arrival: DateTime(2026, 12, 1, 19, 50),
      terminal: 'Terminal 1',
      gate: 'Gate 24',
      seat: '14A',
      boarding: DateTime(2026, 12, 1, 17, 40),
      bookingReference: 'QK7P2M',
    ),
  ],
  accommodations: <TripAccommodation>[
    TripAccommodation(
      id: 'racv-healesville',
      name: 'RACV Healesville Resort',
      checkIn: DateTime(2026, 11, 28, 14),
      checkOut: DateTime(2026, 12, 1, 10),
      address: '122 Healesville-Kinglake Road, Healesville VIC',
      phone: '(03) 5550 4899',
      website: 'www.racvhealesville.example',
      bookingNumber: 'RHR-482910',
      rooms: <TripRoom>[
        TripRoom(name: 'Room 101', guests: <String>[_organiser, 'Ben']),
        const TripRoom(name: 'Room 102', guests: <String>['Luke', 'Josh']),
        const TripRoom(name: 'Room 103', guests: <String>['Nick', 'Sam']),
        const TripRoom(name: 'Room 104', guests: <String>['Liam', 'Jack']),
      ],
      totalCost: 3360,
      notes: 'Breakfast included. Late check-out requested for Tuesday.',
    ),
  ],
  transport: <TripTransport>[
    TripTransport(
      id: 'airport-transfer',
      type: TransportType.airportTransfer,
      pickup: DateTime(2026, 11, 28, 12, 15),
      from: 'Melbourne Airport',
      to: 'RACV Healesville',
      driver: 'Daniel (Yarra Valley Shuttles)',
      vehicle: '12-seat minibus',
      bookingReference: 'YVS-30871',
    ),
    TripTransport(
      id: 'car-sat',
      type: TransportType.rentalCar,
      pickup: DateTime(2026, 11, 29, 7),
      from: 'RACV Healesville',
      to: 'Kingston Heath',
      driver: 'Ben',
      vehicle: '2 × Toyota Kluger (7 seat)',
      bookingReference: 'HZ-559201',
    ),
    TripTransport(
      id: 'car-sun',
      type: TransportType.rentalCar,
      pickup: DateTime(2026, 11, 30, 6, 50),
      from: 'RACV Healesville',
      to: 'Royal Melbourne',
      driver: 'Ben',
      vehicle: '2 × Toyota Kluger (7 seat)',
      bookingReference: 'HZ-559201',
    ),
    TripTransport(
      id: 'car-mon',
      type: TransportType.rentalCar,
      pickup: DateTime(2026, 12, 1, 8, 10),
      from: 'RACV Healesville',
      to: 'Peninsula Kingswood',
      driver: 'Luke',
      vehicle: '2 × Toyota Kluger (7 seat)',
      bookingReference: 'HZ-559201',
      notes: 'Return the cars to Melbourne Airport after the round.',
    ),
  ],
  itinerary: <TripItineraryItem>[
    TripItineraryItem(
      id: 'dinner',
      kind: ItineraryKind.food,
      title: 'Team dinner',
      start: DateTime(2026, 11, 29, 19),
      location: 'The Healesville Hotel',
      notes: 'Table booked for 9 under "$_organiserDisplay".',
    ),
    TripItineraryItem(
      id: 'winery',
      kind: ItineraryKind.activity,
      title: 'Yarra Valley winery visit',
      start: DateTime(2026, 11, 30, 16),
      location: 'Yarra Valley',
    ),
  ],
  expenses: <TripExpense>[
    TripExpense(
      id: 'exp-accommodation',
      title: 'RACV Healesville — 3 nights',
      category: ExpenseCategory.accommodation,
      amount: 3360,
      paidBy: _organiser,
      date: DateTime(2026, 10, 2),
      participants: _squad,
      settled: const <String>{'Ben', 'Luke', 'Josh', 'Nick', 'Liam'},
    ),
    TripExpense(
      id: 'exp-golf',
      title: 'Green fees — 3 rounds',
      category: ExpenseCategory.golf,
      amount: 5840,
      paidBy: 'Ben',
      date: DateTime(2026, 10, 9),
      participants: _squad,
      settled: const <String>{'Luke', 'Josh'},
    ),
    TripExpense(
      id: 'exp-food',
      title: 'Dinner deposits',
      category: ExpenseCategory.food,
      amount: 1200,
      paidBy: 'Luke',
      date: DateTime(2026, 10, 15),
      participants: _squad,
    ),
    TripExpense(
      id: 'exp-transport',
      title: 'Cars and airport transfer',
      category: ExpenseCategory.transport,
      amount: 1100,
      paidBy: _organiser,
      date: DateTime(2026, 10, 12),
      participants: _squad,
      settled: const <String>{
        'Ben',
        'Luke',
        'Josh',
        'Nick',
        'Sam',
        'Liam',
        'Jack',
      },
    ),
  ],
  tasks: <TripTask>[
    const TripTask(id: 'task-flights', title: 'Book flights', done: true),
    const TripTask(id: 'task-stay', title: 'Book accommodation', done: true),
    const TripTask(id: 'task-tee', title: 'Lock in tee times', done: true),
    TripTask(
      id: 'task-dinner',
      title: 'Reserve Sunday dinner',
      due: DateTime(2026, 11, 20),
    ),
    TripTask(
      id: 'task-cars',
      title: 'Confirm rental car drivers',
      due: DateTime(2026, 11, 22),
    ),
    const TripTask(id: 'task-pack', title: 'Share the packing list'),
  ],
  packing: const <PackingItem>[
    PackingItem(id: 'pack-clubs', label: 'Clubs and travel bag', packed: true),
    PackingItem(id: 'pack-shoes', label: 'Golf shoes (soft spikes)'),
    PackingItem(id: 'pack-glove', label: 'Gloves and balls'),
    PackingItem(id: 'pack-rain', label: 'Rain jacket'),
    PackingItem(id: 'pack-sun', label: 'Sunscreen and cap'),
    PackingItem(id: 'pack-range', label: 'Rangefinder'),
    PackingItem(id: 'pack-dinner', label: 'Smart casual outfit for dinner'),
    PackingItem(id: 'pack-charger', label: 'Phone charger'),
  ],
  weather: const <TripWeatherForecast>[
    TripWeatherForecast(
      id: 'w-sat',
      day: 'Saturday',
      condition: WeatherCondition.sunny,
      high: 24,
      low: 14,
    ),
    TripWeatherForecast(
      id: 'w-sun',
      day: 'Sunday',
      condition: WeatherCondition.partlyCloudy,
      high: 22,
      low: 13,
    ),
    TripWeatherForecast(
      id: 'w-mon',
      day: 'Monday',
      condition: WeatherCondition.sunny,
      high: 25,
      low: 15,
    ),
    TripWeatherForecast(
      id: 'w-tue',
      day: 'Tuesday',
      condition: WeatherCondition.showers,
      high: 20,
      low: 12,
    ),
  ],
  messages: <TripMessage>[
    TripMessage(
      id: 'm-a',
      sender: 'Ben',
      text: 'Tee times are locked in. 8:10 at Kingston Heath on Sunday ⛳',
      sentAt: DateTime(2026, 10, 22, 18, 5),
    ),
    TripMessage(
      id: 'm-b',
      sender: 'Luke',
      text: 'Legend. Who is driving up to Healesville?',
      sentAt: DateTime(2026, 10, 22, 18, 12),
    ),
    TripMessage(
      id: 'm-c',
      sender: _organiser,
      text: "I've got the hire car booked. Room for four.",
      sentAt: DateTime(2026, 10, 22, 18, 20),
    ),
    TripMessage(
      id: 'm-d',
      sender: 'Josh',
      text: 'Dinner on the Sunday night sorted?',
      sentAt: DateTime(2026, 10, 23, 8, 30),
    ),
    TripMessage(
      id: 'm-e',
      sender: _organiser,
      text: 'Booked under my name for 7pm 🍽️',
      sentAt: DateTime(2026, 10, 23, 8, 41),
    ),
    TripMessage(
      id: 'm1',
      sender: _organiser,
      text: 'Looking forward to this trip!',
      sentAt: DateTime(2026, 10, 24, 19, 12),
    ),
    TripMessage(
      id: 'm2',
      sender: 'Ben',
      text: "Can't wait.",
      sentAt: DateTime(2026, 10, 24, 19, 18),
    ),
    TripMessage(
      id: 'm3',
      sender: 'Luke',
      text: 'See everyone Saturday morning.',
      sentAt: DateTime(2026, 10, 24, 19, 42),
    ),
  ],
  notes:
      'Bring cash for caddies at Royal Melbourne. Dinner reservations are '
      'under $_organiserDisplay.',
  updates: <TripUpdate>[
    TripUpdate(
      text: 'Added the team dinner on Sunday',
      at: DateTime(2026, 10, 22, 18, 5),
    ),
    TripUpdate(
      text: 'Royal Melbourne tee time moved to 8:00 AM',
      at: DateTime(2026, 10, 23, 9, 30),
    ),
  ],
);

/// The plan each seeded trip starts with, keyed by trip id. Trips without an
/// entry start with an empty plan.
final Map<String, TripPlan> seedPlans = <String, TripPlan>{
  melbourneGolfWeekend.id: melbourneGolfWeekendPlan,
};

/// Melbourne Golf Weekend's final results (shown on Trip Complete).
final List<TripAward> melbourneGolfWeekendResults = <TripAward>[
  TripAward(award: 'Trip Champion', winner: _organiser),
  const TripAward(award: 'Runner Up', winner: 'Ben'),
  const TripAward(award: 'Longest Drive', winner: 'Luke'),
  const TripAward(award: 'Nearest The Pin', winner: 'Josh'),
];

/// Trip-wide statistics — see placeholder-trip-data.md's "Trip Statistics".
/// Profile reads these seed counts for its own summary; they describe the
/// seeded trips, not trips created since.
const int upcomingTripsCount = 2;
const int pastTripsCount = 2;
const int countriesVisitedCount = 2;
