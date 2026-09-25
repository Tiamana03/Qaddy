/// A Trip's flight information — see
/// `docs/architecture/trip-data-model.md`'s "Flights" section and
/// placeholder-trip-data.md's "Flights" section.
library;

/// One flight booked for the trip.
class TripFlight {
  const TripFlight({
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
  });

  /// The airline name.
  final String airline;

  /// The flight number (e.g. "QF431").
  final String flightNumber;

  /// The departure, as sourced (e.g. "Sydney 8:30 AM").
  final String departure;

  /// The arrival, as sourced (e.g. "Melbourne 10:05 AM").
  final String arrival;
}
