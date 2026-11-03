/// The parts of a trip the Edit Trip hub lets the golfer change.
library;

import 'package:flutter/material.dart';

/// One editable part of a trip. The [slug] is the route segment
/// (`/trips/:tripId/edit/:slug`).
enum TripEditSection {
  details('details', 'Trip Details', Icons.tune),
  dates('dates', 'Dates', Icons.calendar_month_outlined),
  destination('destination', 'Destination', Icons.place_outlined),
  accommodation('accommodation', 'Accommodation', Icons.hotel_outlined),
  flights('flights', 'Flights', Icons.flight_takeoff),
  transport('transport', 'Transport', Icons.directions_car_outlined),
  courses('courses', 'Courses & Tee Times', Icons.golf_course_outlined),
  players('players', 'Players', Icons.group_outlined),
  expenses('expenses', 'Expenses', Icons.payments_outlined),
  itinerary('itinerary', 'Activities & Dining', Icons.restaurant_outlined),
  tasks('tasks', 'Checklist', Icons.checklist),
  notes('notes', 'Notes', Icons.sticky_note_2_outlined),
  weather('weather', 'Weather', Icons.wb_sunny_outlined),
  packing('packing', 'Packing list', Icons.luggage_outlined),
  chat('chat', 'Chat Settings', Icons.chat_bubble_outline);

  const TripEditSection(this.slug, this.label, this.icon);

  /// The route segment.
  final String slug;

  /// What the section is called.
  final String label;

  /// The section's icon.
  final IconData icon;

  /// Whether the section is a list of items (each edited on its own page)
  /// rather than a single form.
  bool get isList => switch (this) {
    accommodation ||
    flights ||
    transport ||
    courses ||
    expenses ||
    itinerary ||
    tasks ||
    weather ||
    packing => true,
    _ => false,
  };

  /// The section for a route [slug], or `null` if there is none.
  static TripEditSection? fromSlug(String slug) {
    for (final section in values) {
      if (section.slug == slug) {
        return section;
      }
    }
    return null;
  }
}
