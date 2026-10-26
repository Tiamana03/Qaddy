/// Qaddy's Accommodation screen — where the group is staying.
///
/// See `docs/features/trips-feature-integration.md`'s "Accommodation"
/// section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Accommodation (route `/trips/:tripId/accommodation`).
class TripAccommodationScreen extends ConsumerWidget {
  const TripAccommodationScreen({required this.tripId, super.key});

  /// The trip whose accommodation is shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Accommodation')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final stay in plan.accommodations) ...<Widget>[
              QaddySectionCard(
                title: stay.name,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    QaddyInfoRow(
                      label: 'Check In',
                      value: stay.checkIn.toShortWeekdayAndDate(),
                    ),
                    SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: 'Check Out',
                      value: stay.checkOut.toShortWeekdayAndDate(),
                    ),
                    SizedBox(height: spacing.sm),
                    QaddyInfoRow(label: 'Address', value: stay.address),
                    SizedBox(height: spacing.sm),
                    QaddyInfoRow(label: 'Contact', value: stay.phone),
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
