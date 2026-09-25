/// Qaddy's Trip Planning screen — the complete itinerary at a glance.
///
/// See `docs/features/trips-feature-integration.md`'s "Planning" section
/// ("Displays: Flights, Accommodation, Transport, Courses, Tee Times...
/// Allows users to review the complete itinerary").
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Trip Planning (route `/trips/planning`).
class TripPlanningScreen extends StatelessWidget {
  const TripPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Planning')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Itinerary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, entry)
                      in melbourneGolfWeekendItinerary.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(
                      label: '${entry.date} · ${entry.activity}',
                      value: entry.time,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Flights',
              child: TripInfoRow(
                label:
                    '${melbourneGolfWeekendFlight.airline} '
                    '${melbourneGolfWeekendFlight.flightNumber}',
                value: melbourneGolfWeekendFlight.departure,
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Accommodation',
              child: TripInfoRow(
                label: melbourneGolfWeekendAccommodation.name,
                value: melbourneGolfWeekendAccommodation.checkIn,
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Transport',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, leg)
                      in melbourneGolfWeekendTransport.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: leg.type, value: leg.time),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Courses & Tee Times',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, course)
                      in melbourneGolfWeekendCourses.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: course.name, value: course.teeTime),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
