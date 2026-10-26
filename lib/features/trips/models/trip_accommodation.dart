/// A Trip's accommodation — see `docs/architecture/trip-data-model.md`'s
/// "Accommodation" section.
library;

/// One room (or villa, cabin…) and who is staying in it.
class TripRoom {
  const TripRoom({required this.name, required this.guests});

  /// The room's label (e.g. "Room 101").
  final String name;

  /// Names of the guests allocated to it.
  final List<String> guests;
}

/// One place the group is staying.
class TripAccommodation {
  const TripAccommodation({
    required this.id,
    required this.name,
    required this.checkIn,
    required this.checkOut,
    this.address = '',
    this.phone = '',
    this.website = '',
    this.bookingNumber = '',
    this.rooms = const <TripRoom>[],
    this.totalCost,
    this.notes = '',
  });

  /// Unique identifier within the trip.
  final String id;

  /// The accommodation's name.
  final String name;

  /// Check-in date and time.
  final DateTime checkIn;

  /// Check-out date and time.
  final DateTime checkOut;

  /// Street address.
  final String address;

  /// Contact phone number.
  final String phone;

  /// Website address.
  final String website;

  /// The booking number.
  final String bookingNumber;

  /// Room allocation.
  final List<TripRoom> rooms;

  /// The total cost for the whole stay, when known.
  final double? totalCost;

  /// Free-form notes.
  final String notes;

  /// Number of nights stayed.
  int get nights => DateTime.utc(
    checkOut.year,
    checkOut.month,
    checkOut.day,
  ).difference(DateTime.utc(checkIn.year, checkIn.month, checkIn.day)).inDays;

  /// Every allocated guest, across all rooms.
  List<String> get guests => <String>[for (final room in rooms) ...room.guests];

  /// The cost split equally between the allocated guests, when both a cost
  /// and at least one guest are known.
  double? get costPerGuest {
    final cost = totalCost;
    if (cost == null || guests.isEmpty) {
      return null;
    }
    return cost / guests.length;
  }

  /// A copy with the given fields replaced.
  TripAccommodation copyWith({
    String? name,
    DateTime? checkIn,
    DateTime? checkOut,
    String? address,
    String? phone,
    String? website,
    String? bookingNumber,
    List<TripRoom>? rooms,
    double? totalCost,
    bool clearCost = false,
    String? notes,
  }) {
    return TripAccommodation(
      id: id,
      name: name ?? this.name,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      rooms: rooms ?? this.rooms,
      totalCost: clearCost ? null : (totalCost ?? this.totalCost),
      notes: notes ?? this.notes,
    );
  }
}
