/// Edit Trip — the hub from which every part of a trip can be changed, in the
/// spirit of editing an event in Apple Calendar: one list of sections, each
/// opening its own focused editor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_edit_summary.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Edit Trip (route `/trips/:tripId/edit`).
class EditTripScreen extends ConsumerWidget {
  const EditTripScreen({required this.tripId, super.key});

  /// The trip being edited.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Row(
              children: <Widget>[
                TripCoverTile(presetId: trip.coverImage, size: spacing.hero),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        trip.name,
                        style: typography.h3.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                      Text(
                        trip.destination,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  for (final section in TripEditSection.values)
                    QaddyNavRow(
                      icon: section.icon,
                      title: section.label,
                      subtitle: tripEditSummary(trip, plan, section),
                      onTap: () => context.push(
                        AppRoutes.tripEditSection(tripId, section.slug),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyCard(
              child: QaddyNavRow(
                icon: Icons.settings_outlined,
                title: 'Trip Settings',
                subtitle: 'Share, duplicate, archive or delete this trip',
                onTap: () => context.push(AppRoutes.tripSettings(tripId)),
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
