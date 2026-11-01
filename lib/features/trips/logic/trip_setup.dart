/// The handful of things that turn an empty trip into a real one.
///
/// A trip with nothing in it is a blank page; one with a squad, flights, a
/// place to stay, a course and a plan is a trip. This lists those first steps
/// so the app can say what to do next instead of showing rows of "nothing
/// added yet".
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// One first step, and where to go to do it.
class TripSetupStep {
  const TripSetupStep({
    required this.title,
    required this.detail,
    required this.icon,
    required this.route,
    required this.done,
  });

  /// What to do, e.g. "Invite your squad".
  final String title;

  /// Why it helps.
  final String detail;

  /// A picture for the step.
  final IconData icon;

  /// The page where the step is done.
  final String route;

  /// Whether the trip already has this.
  final bool done;
}

/// The first steps for trip [tripId], with [plan]'s progress against each.
List<TripSetupStep> tripSetupSteps(String tripId, TripPlan plan) {
  String add(TripEditSection section) =>
      AppRoutes.tripEditItem(tripId, section.slug, 'new');

  return <TripSetupStep>[
    TripSetupStep(
      title: 'Invite your squad',
      detail: 'Golf is better with friends',
      icon: Icons.group_add_outlined,
      route: AppRoutes.tripInvite(tripId),
      done: plan.members.length > 1,
    ),
    TripSetupStep(
      title: 'Add your flights',
      detail: 'Times, gates and booking references',
      icon: Icons.flight_takeoff,
      route: add(TripEditSection.flights),
      done: plan.flights.isNotEmpty,
    ),
    TripSetupStep(
      title: 'Add where you are staying',
      detail: 'Check-in, rooms and cost per person',
      icon: Icons.hotel_outlined,
      route: add(TripEditSection.accommodation),
      done: plan.accommodations.isNotEmpty,
    ),
    TripSetupStep(
      title: 'Add a course and tee time',
      detail: 'Players, green fees and dress code',
      icon: Icons.golf_course_outlined,
      route: add(TripEditSection.courses),
      done: plan.courses.isNotEmpty,
    ),
    TripSetupStep(
      title: 'Plan something fun',
      detail: 'A dinner, a winery, a round of pool',
      icon: Icons.restaurant_outlined,
      route: add(TripEditSection.itinerary),
      done: plan.itinerary.isNotEmpty,
    ),
  ];
}
