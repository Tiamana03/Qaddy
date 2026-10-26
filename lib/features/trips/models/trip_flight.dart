/// A Trip's flights — see `docs/architecture/trip-data-model.md`'s "Flights"
/// section. Release 1 has no flight API; every field is entered or seeded
/// placeholder data.
library;

/// Where the traveller is in the airline's online check-in.
enum FlightCheckInStatus { notOpen, open, checkedIn }

/// One flight booked for the trip.
class TripFlight {
  const TripFlight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.fromAirport,
    required this.toAirport,
    required this.departure,
    required this.arrival,
    this.terminal = '',
    this.gate = '',
    this.seat = '',
    this.boarding,
    this.bookingReference = '',
    this.checkInStatus = FlightCheckInStatus.notOpen,
  });

  /// Unique identifier within the trip.
  final String id;

  /// The airline name.
  final String airline;

  /// The flight number (e.g. "QF431").
  final String flightNumber;

  /// Departure city/airport (e.g. "Sydney").
  final String fromAirport;

  /// Arrival city/airport (e.g. "Melbourne").
  final String toAirport;

  /// Local departure date and time.
  final DateTime departure;

  /// Local arrival date and time.
  final DateTime arrival;

  /// Departure terminal.
  final String terminal;

  /// Departure gate.
  final String gate;

  /// The organiser's seat.
  final String seat;

  /// Boarding time, when known.
  final DateTime? boarding;

  /// The airline's booking reference (PNR).
  final String bookingReference;

  /// Online check-in status.
  final FlightCheckInStatus checkInStatus;

  /// "QF431 · Sydney → Melbourne".
  String get routeLabel => '$fromAirport → $toAirport';

  /// A copy with the given fields replaced.
  TripFlight copyWith({
    String? airline,
    String? flightNumber,
    String? fromAirport,
    String? toAirport,
    DateTime? departure,
    DateTime? arrival,
    String? terminal,
    String? gate,
    String? seat,
    DateTime? boarding,
    bool clearBoarding = false,
    String? bookingReference,
    FlightCheckInStatus? checkInStatus,
  }) {
    return TripFlight(
      id: id,
      airline: airline ?? this.airline,
      flightNumber: flightNumber ?? this.flightNumber,
      fromAirport: fromAirport ?? this.fromAirport,
      toAirport: toAirport ?? this.toAirport,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      terminal: terminal ?? this.terminal,
      gate: gate ?? this.gate,
      seat: seat ?? this.seat,
      boarding: clearBoarding ? null : (boarding ?? this.boarding),
      bookingReference: bookingReference ?? this.bookingReference,
      checkInStatus: checkInStatus ?? this.checkInStatus,
    );
  }
}
