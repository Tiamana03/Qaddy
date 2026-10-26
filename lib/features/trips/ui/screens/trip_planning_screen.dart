/// Qaddy's Planning screen — the trip's day-by-day plan.
///
/// See `docs/features/trips-feature-integration.md`'s "Planning" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Planning (route `/trips/:tripId/planning`).
class TripPlanningScreen extends ConsumerWidget {
  const TripPlanningScreen({required this.tripId, super.key});

  /// The trip being planned.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Planning')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final day in buildTimeline(trip, plan)) ...<Widget>[
              QaddySectionCard(
                title: day.date.toShortWeekdayAndDate(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (day.events.isEmpty)
                      const Text('Nothing planned yet')
                    else
                      for (final (index, event)
                          in day.events.indexed) ...<Widget>[
                        if (index > 0) SizedBox(height: spacing.sm),
                        QaddyInfoRow(
                          label: event.title,
                          value: event.at.toFriendlyTime(),
                        ),
                      ],
                  ],
                ),
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
