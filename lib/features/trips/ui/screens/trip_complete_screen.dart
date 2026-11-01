/// Qaddy's Trip Complete screen — the wrap-up once a trip is over.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Complete"
/// section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_result.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Trip Complete (route `/trips/:tripId/complete`).
class TripCompleteScreen extends ConsumerWidget {
  const TripCompleteScreen({required this.tripId, super.key});

  /// The trip being wrapped up.
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
    final summary = summariseExpenses(plan.expenses);
    final rounds = plan.courses.length;
    final players = trip.playerCount;
    final results = trip.id == melbourneGolfWeekend.id
        ? melbourneGolfWeekendResults
        : const <TripAward>[];

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Complete')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            DetailHeader(
              icon: Icons.emoji_events_outlined,
              title: "That's a wrap",
              subtitle: trip.name,
              facts: <String>[
                trip.startDate.toFriendlyRange(trip.endDate),
                if (plan.courses.isNotEmpty)
                  '$rounds ${rounds == 1 ? 'round' : 'rounds'}',
                '$players ${players == 1 ? 'player' : 'players'}',
              ],
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Trip Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QaddyInfoRow(label: 'Destination', value: trip.destination),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Dates',
                    value: trip.startDate.toFriendlyRange(trip.endDate),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(label: 'Players', value: '${trip.playerCount}'),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Courses Played',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final course in plan.courses)
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
                  for (final (index, award) in results.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(label: award.award, value: award.winner),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Expenses',
              child: QaddyInfoRow(
                label: 'Total Cost',
                value: formatMoney(summary.total),
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
                    onPressed: () {
                      ref.read(tripsProvider.notifier).archiveTrip(tripId);
                      context.go(AppRoutes.trips);
                    },
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
          ]),
        ),
      ),
    );
  }
}
