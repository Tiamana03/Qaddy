/// The Trips feature's shared placeholder data.
///
/// See `docs/standards/placeholder-trip-data.md`. Per
/// `docs/features/trips-feature-integration.md`'s "Shared Placeholder
/// Data" section, one trip (Melbourne Golf Weekend) is the single shared
/// placeholder trip referenced by every detail screen (Trip Details,
/// Planning, Travel, Accommodation, Golf Schedule, Expenses, Chat,
/// Complete). The other three trips only need the summary fields shown on
/// the Trips list screen.
library;

import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_result.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

// Every organiser is Tiamana — placeholder-trip-data.md's Engineering
// Decisions.
const String _organiser = 'Tiamana';

/// Melbourne Golf Weekend — the shared placeholder trip with full detail
/// data across every Trips screen.
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
);

/// Upcoming trips, ordered by start date — see placeholder-trip-data.md's
/// "UI Rules" ("Trips are ordered by Start Date").
final List<Trip> upcomingTrips = <Trip>[
  melbourneGolfWeekend,
  goldCoastGolfEscape,
];

/// Past (completed) trips, newest first — see placeholder-trip-data.md's
/// "UI Rules" ("Completed Trips appear newest first").
final List<Trip> pastTrips = <Trip>[tasmaniaGolfTour, queenstownGolfAdventure];

/// Melbourne Golf Weekend's participants.
const List<TripMember> melbourneGolfWeekendMembers = <TripMember>[
  TripMember(
    displayName: 'Tiamana',
    handicap: 13.4,
    role: TripRole.organiser,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Ben',
    handicap: 8.6,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Luke',
    handicap: 15.2,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Josh',
    handicap: 11.8,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Nick',
    handicap: 17.3,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Sam',
    handicap: 7.9,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Liam',
    handicap: 19.1,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
  TripMember(
    displayName: 'Jack',
    handicap: 9.8,
    role: TripRole.player,
    status: ParticipantStatus.confirmed,
  ),
];

/// Melbourne Golf Weekend's day-by-day schedule.
const List<TripItineraryEntry> melbourneGolfWeekendItinerary =
    <TripItineraryEntry>[
      TripItineraryEntry(
        date: '28 Nov',
        activity: 'Arrive Melbourne',
        time: '11:30 AM',
      ),
      TripItineraryEntry(date: '28 Nov', activity: 'Check In', time: '2:00 PM'),
      TripItineraryEntry(
        date: '29 Nov',
        activity: 'Golf - Kingston Heath',
        time: '8:10 AM',
      ),
      TripItineraryEntry(
        date: '30 Nov',
        activity: 'Golf - Royal Melbourne',
        time: '8:00 AM',
      ),
      TripItineraryEntry(
        date: '1 Dec',
        activity: 'Golf - Peninsula Kingswood',
        time: '9:20 AM',
      ),
    ];

/// Melbourne Golf Weekend's golf courses.
const List<TripCourse> melbourneGolfWeekendCourses = <TripCourse>[
  TripCourse(name: 'Kingston Heath', teeTime: '8:10 AM'),
  TripCourse(name: 'Royal Melbourne', teeTime: '8:00 AM'),
  TripCourse(name: 'Peninsula Kingswood', teeTime: '9:20 AM'),
];

/// Melbourne Golf Weekend's Round 1 playing groups.
const List<TripPlayingGroup> melbourneGolfWeekendPlayingGroups =
    <TripPlayingGroup>[
      TripPlayingGroup(
        name: 'Group 1',
        players: <String>['Tiamana', 'Ben', 'Luke', 'Josh'],
      ),
      TripPlayingGroup(
        name: 'Group 2',
        players: <String>['Nick', 'Sam', 'Liam', 'Jack'],
      ),
    ];

/// Melbourne Golf Weekend's configured side games.
const List<TripSideGame> melbourneGolfWeekendSideGames = <TripSideGame>[
  TripSideGame(name: 'Longest Drive', hole: 5),
  TripSideGame(name: 'Nearest The Pin', hole: 8),
  TripSideGame(name: 'Longest Putt', hole: 12),
];

/// Melbourne Golf Weekend's accommodation.
const TripAccommodation melbourneGolfWeekendAccommodation = TripAccommodation(
  name: 'RACV Healesville Resort',
  address: '122 Healesville-Kinglake Road, Healesville VIC',
  contact: '(03) 5962 4899',
  checkIn: '28 November',
  checkOut: '1 December',
);

/// Melbourne Golf Weekend's flight.
const TripFlight melbourneGolfWeekendFlight = TripFlight(
  airline: 'Qantas',
  flightNumber: 'QF431',
  departure: 'Sydney 8:30 AM',
  arrival: 'Melbourne 10:05 AM',
);

/// Melbourne Golf Weekend's local transport.
const List<TripTransportLeg> melbourneGolfWeekendTransport = <TripTransportLeg>[
  TripTransportLeg(
    date: '28 Nov',
    type: 'Airport Transfer',
    details: 'Melbourne Airport → RACV Healesville',
    time: '12:15 PM',
  ),
  TripTransportLeg(
    date: '29 Nov',
    type: 'Rental Car',
    details: 'RACV → Kingston Heath',
    time: '7:00 AM',
  ),
  TripTransportLeg(
    date: '30 Nov',
    type: 'Rental Car',
    details: 'RACV → Royal Melbourne',
    time: '6:50 AM',
  ),
  TripTransportLeg(
    date: '1 Dec',
    type: 'Rental Car',
    details: 'RACV → Peninsula Kingswood',
    time: '8:10 AM',
  ),
];

/// Melbourne Golf Weekend's shared expense categories.
const List<TripExpenseItem> melbourneGolfWeekendExpenses = <TripExpenseItem>[
  TripExpenseItem(title: 'Accommodation', amount: 2100),
  TripExpenseItem(title: 'Golf', amount: 1350),
  TripExpenseItem(title: 'Food', amount: 650),
  TripExpenseItem(title: 'Transport', amount: 420),
];

/// Melbourne Golf Weekend's estimated total spend.
const double melbourneGolfWeekendEstimatedTotal = 4520;

/// Melbourne Golf Weekend's individual payments.
const List<TripPayment> melbourneGolfWeekendPayments = <TripPayment>[
  TripPayment(playerName: 'Tiamana', amountPaid: 600),
  TripPayment(playerName: 'Ben', amountPaid: 560),
  TripPayment(playerName: 'Luke', amountPaid: 550),
  TripPayment(playerName: 'Josh', amountPaid: 550),
  TripPayment(playerName: 'Nick', amountPaid: 550),
  TripPayment(playerName: 'Sam', amountPaid: 550),
  TripPayment(playerName: 'Liam', amountPaid: 580),
  TripPayment(playerName: 'Jack', amountPaid: 580),
];

/// Melbourne Golf Weekend's outstanding balance — all expenses are settled.
const double melbourneGolfWeekendOutstandingBalance = 0;

/// Melbourne Golf Weekend's final results.
const List<TripAward> melbourneGolfWeekendResults = <TripAward>[
  TripAward(award: 'Trip Champion', winner: 'Tiamana'),
  TripAward(award: 'Runner Up', winner: 'Ben'),
  TripAward(award: 'Longest Drive', winner: 'Luke'),
  TripAward(award: 'Nearest The Pin', winner: 'Josh'),
];

/// Melbourne Golf Weekend's chat messages.
const List<TripMessage> melbourneGolfWeekendMessages = <TripMessage>[
  TripMessage(
    sender: 'Tiamana',
    message: 'Looking forward to this trip!',
    time: '7:12 PM',
  ),
  TripMessage(sender: 'Ben', message: "Can't wait.", time: '7:18 PM'),
  TripMessage(
    sender: 'Luke',
    message: 'See everyone Saturday morning.',
    time: '7:42 PM',
  ),
];

/// Melbourne Golf Weekend's weather forecast.
const List<TripWeatherForecast> melbourneGolfWeekendWeather =
    <TripWeatherForecast>[
      TripWeatherForecast(
        day: 'Saturday',
        forecast: 'Sunny',
        high: '24°C',
        low: '14°C',
      ),
      TripWeatherForecast(
        day: 'Sunday',
        forecast: 'Partly Cloudy',
        high: '22°C',
        low: '13°C',
      ),
      TripWeatherForecast(
        day: 'Monday',
        forecast: 'Sunny',
        high: '25°C',
        low: '15°C',
      ),
      TripWeatherForecast(
        day: 'Tuesday',
        forecast: 'Showers',
        high: '20°C',
        low: '12°C',
      ),
    ];

/// Trip-wide statistics — see placeholder-trip-data.md's "Trip Statistics".
const int upcomingTripsCount = 2;
const int pastTripsCount = 2;
const int countriesVisitedCount = 2;
