/// A Trip's itinerary items — see `docs/architecture/trip-data-model.md`'s
/// "Itinerary" section.
///
/// Only things that have no record of their own live here (a dinner booking,
/// a winery visit). Flights, check-ins, tee times and transport already have
/// their own records, and the planning timeline merges all of them — see
/// `logic/trip_timeline.dart`.
library;

import 'package:flutter/material.dart';

/// What an itinerary entry is, for grouping and iconography.
enum ItineraryKind {
  golf('Golf', Icons.golf_course_outlined),
  food('Food & Drink', Icons.restaurant_outlined),
  activity('Activity', Icons.local_activity_outlined),
  flight('Flight', Icons.flight_outlined),
  lodging('Accommodation', Icons.hotel_outlined),
  transport('Transport', Icons.directions_car_outlined),
  other('Other', Icons.event_note_outlined);

  const ItineraryKind(this.label, this.icon);

  /// Display name.
  final String label;

  /// Icon shown beside it.
  final IconData icon;
}

/// One user-added entry on the trip's timeline.
class TripItineraryItem {
  const TripItineraryItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.start,
    this.location = '',
    this.notes = '',
  });

  /// Unique identifier within the trip.
  final String id;

  /// What kind of entry it is.
  final ItineraryKind kind;

  /// What's happening (e.g. "Team dinner").
  final String title;

  /// When it starts (local date and time).
  final DateTime start;

  /// Where it happens.
  final String location;

  /// Free-form notes.
  final String notes;

  /// A copy with the given fields replaced.
  TripItineraryItem copyWith({
    ItineraryKind? kind,
    String? title,
    DateTime? start,
    String? location,
    String? notes,
  }) {
    return TripItineraryItem(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      start: start ?? this.start,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}
