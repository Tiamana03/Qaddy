/// Edit Trip -> one item of a list section (a flight, a course, an expense…).
/// `itemId` is `new` to add an item.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/accommodation_form.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/activity_task_forms.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/course_form.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/expense_form.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/flight_form.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/transport_form.dart';
import 'package:qaddy/features/trips/ui/screens/edit/forms/weather_packing_forms.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Edit one item (route `/trips/:tripId/edit/:section/:itemId`).
class EditTripItemScreen extends ConsumerStatefulWidget {
  const EditTripItemScreen({
    required this.tripId,
    required this.section,
    required this.itemId,
    super.key,
  });

  /// The trip being edited.
  final String tripId;

  /// The route segment naming the section (see [TripEditSection.slug]).
  final String section;

  /// The item's id, or [newItemId] to add one.
  final String itemId;

  /// The `itemId` that means "add a new item".
  static const String newItemId = 'new';

  @override
  ConsumerState<EditTripItemScreen> createState() => _EditTripItemScreenState();
}

class _EditTripItemScreenState extends ConsumerState<EditTripItemScreen> {
  // The item is looked up once, when the page opens. Looking it up on every
  // rebuild would flash "not found" while the page closes after a delete.
  late final TripPlan _plan = ref.read(tripPlanProvider(widget.tripId));

  @override
  Widget build(BuildContext context) {
    final tripId = widget.tripId;
    final section = widget.section;
    final itemId = widget.itemId;
    final kind = TripEditSection.fromSlug(section);
    if (ref.read(tripProvider(tripId)) == null ||
        kind == null ||
        !kind.isList) {
      return const TripNotFound();
    }
    final plan = _plan;
    final back = AppRoutes.tripEditSection(tripId, section);
    final adding = itemId == EditTripItemScreen.newItemId;

    // A missing item (deleted, or a stale link) shows the not-found state
    // rather than a blank form that would silently add a duplicate.
    T? find<T>(Iterable<T> items, String Function(T) idOf) {
      for (final item in items) {
        if (idOf(item) == itemId) {
          return item;
        }
      }
      return null;
    }

    Widget missing() => const TripNotFound();

    switch (kind) {
      case TripEditSection.flights:
        final flight = adding ? null : find(plan.flights, (f) => f.id);
        return !adding && flight == null
            ? missing()
            : FlightForm(tripId: tripId, fallbackRoute: back, flight: flight);
      case TripEditSection.accommodation:
        final stay = adding ? null : find(plan.accommodations, (s) => s.id);
        return !adding && stay == null
            ? missing()
            : AccommodationForm(
                tripId: tripId,
                fallbackRoute: back,
                stay: stay,
              );
      case TripEditSection.transport:
        final leg = adding ? null : find(plan.transport, (t) => t.id);
        return !adding && leg == null
            ? missing()
            : TransportForm(
                tripId: tripId,
                fallbackRoute: back,
                transport: leg,
              );
      case TripEditSection.courses:
        final course = adding ? null : find(plan.courses, (c) => c.id);
        return !adding && course == null
            ? missing()
            : CourseForm(tripId: tripId, fallbackRoute: back, course: course);
      case TripEditSection.expenses:
        final expense = adding ? null : find(plan.expenses, (e) => e.id);
        return !adding && expense == null
            ? missing()
            : ExpenseForm(
                tripId: tripId,
                fallbackRoute: back,
                expense: expense,
              );
      case TripEditSection.itinerary:
        final activity = adding ? null : find(plan.itinerary, (i) => i.id);
        return !adding && activity == null
            ? missing()
            : ActivityForm(tripId: tripId, fallbackRoute: back, item: activity);
      case TripEditSection.tasks:
        final task = adding ? null : find(plan.tasks, (t) => t.id);
        return !adding && task == null
            ? missing()
            : TaskForm(tripId: tripId, fallbackRoute: back, task: task);
      case TripEditSection.weather:
        final day = adding ? null : find(plan.weather, (d) => d.id);
        return !adding && day == null
            ? missing()
            : WeatherForm(tripId: tripId, fallbackRoute: back, day: day);
      case TripEditSection.packing:
        final item = adding ? null : find(plan.packing, (i) => i.id);
        return !adding && item == null
            ? missing()
            : PackingForm(tripId: tripId, fallbackRoute: back, item: item);
      case TripEditSection.details ||
          TripEditSection.dates ||
          TripEditSection.destination ||
          TripEditSection.players ||
          TripEditSection.notes ||
          TripEditSection.chat:
        return missing();
    }
  }
}
