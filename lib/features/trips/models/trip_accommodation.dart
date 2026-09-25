/// A Trip's accommodation — see `docs/architecture/trip-data-model.md`'s
/// "Accommodation" section and placeholder-trip-data.md's "Accommodation"
/// section.
library;

/// Where the trip's participants are staying.
class TripAccommodation {
  const TripAccommodation({
    required this.name,
    required this.address,
    required this.contact,
    required this.checkIn,
    required this.checkOut,
  });

  /// The accommodation's name.
  final String name;

  /// The accommodation's address.
  final String address;

  /// A contact phone number.
  final String contact;

  /// The check-in date, as sourced (e.g. "28 November").
  final String checkIn;

  /// The check-out date, as sourced (e.g. "1 December").
  final String checkOut;
}
