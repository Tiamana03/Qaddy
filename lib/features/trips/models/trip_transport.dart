/// A Trip's local transport — see `docs/architecture/trip-data-model.md`'s
/// "Transport" section.
library;

import 'package:flutter/material.dart';

/// The kind of transport booked.
enum TransportType {
  rentalCar('Rental Car', Icons.directions_car_outlined),
  airportTransfer('Airport Transfer', Icons.airport_shuttle_outlined),
  rideShare('Uber', Icons.local_taxi_outlined),
  taxi('Taxi', Icons.local_taxi_outlined),
  parking('Parking', Icons.local_parking_outlined),
  other('Other', Icons.commute_outlined);

  const TransportType(this.label, this.icon);

  /// Display name.
  final String label;

  /// Icon shown beside it.
  final IconData icon;
}

/// One leg of local transport.
class TripTransport {
  const TripTransport({
    required this.id,
    required this.type,
    required this.pickup,
    this.from = '',
    this.to = '',
    this.driver = '',
    this.vehicle = '',
    this.bookingReference = '',
    this.notes = '',
  });

  /// Unique identifier within the trip.
  final String id;

  /// What kind of transport it is.
  final TransportType type;

  /// Pickup (or start) date and time.
  final DateTime pickup;

  /// Where it starts.
  final String from;

  /// Where it goes.
  final String to;

  /// The driver's name, if one is assigned.
  final String driver;

  /// The vehicle (make, model, plate…).
  final String vehicle;

  /// The booking reference.
  final String bookingReference;

  /// Free-form notes.
  final String notes;

  /// "Melbourne Airport → RACV Healesville", or whichever ends are known.
  String get routeLabel {
    if (from.isNotEmpty && to.isNotEmpty) {
      return '$from → $to';
    }
    return from.isNotEmpty ? from : to;
  }

  /// A copy with the given fields replaced.
  TripTransport copyWith({
    TransportType? type,
    DateTime? pickup,
    String? from,
    String? to,
    String? driver,
    String? vehicle,
    String? bookingReference,
    String? notes,
  }) {
    return TripTransport(
      id: id,
      type: type ?? this.type,
      pickup: pickup ?? this.pickup,
      from: from ?? this.from,
      to: to ?? this.to,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
      bookingReference: bookingReference ?? this.bookingReference,
      notes: notes ?? this.notes,
    );
  }
}
