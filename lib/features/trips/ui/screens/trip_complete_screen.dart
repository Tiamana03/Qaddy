/// Qaddy's Trip Complete screen — the end-of-trip experience.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Complete"
/// section ("Displays: Trip Summary, Courses Played, Winners, Photos,
/// Expenses, Memories... Users can archive the trip or return home").
/// Photos/Memories have no placeholder data (see placeholder-trip-data.md's
/// "Photos" section, "Placeholder artwork should be displayed instead"),
/// so a placeholder graphic is shown rather than invented content.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Trip Complete (route `/trips/complete`).
class TripCompleteScreen extends StatelessWidget {
  const TripCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final trip = melbourneGolfWeekend;
    final estimatedTotal =
        '\$${melbourneGolfWeekendEstimatedTotal.toStringAsFixed(0)}';

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Complete')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Trip Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TripInfoRow(label: 'Destination', value: trip.destination),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(
                    label: 'Dates',
                    value:
                        '${trip.startDate.toFriendlyDate()} – '
                        '${trip.endDate.toFriendlyDate()}',
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Players', value: '${trip.playerCount}'),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Courses Played',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final course in melbourneGolfWeekendCourses)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing.xs),
                      child: Text(
                        course.name,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Winners',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, award)
                      in melbourneGolfWeekendResults.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: award.award, value: award.winner),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Expenses',
              child: TripInfoRow(
                label: 'Estimated Total',
                value: estimatedTotal,
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Memories',
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.photo_library_outlined,
                    color: colours.textTertiary,
                    size: spacing.hero,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'Photos from this trip will appear here.',
                    textAlign: TextAlign.center,
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddySecondaryButton(
                    label: 'Archive Trip',
                    onPressed: () => context.go(AppRoutes.trips),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: QaddyPrimaryButton(
                    label: 'Return Home',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
