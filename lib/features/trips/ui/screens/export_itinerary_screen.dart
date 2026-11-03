/// Export Itinerary — the trip as text to share or copy.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Export Itinerary (route `/trips/:tripId/export`).
class ExportItineraryScreen extends ConsumerWidget {
  const ExportItineraryScreen({required this.tripId, super.key});

  /// The trip being exported.
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
    final text = itineraryText(trip, plan);

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Itinerary copied')));
      }
    }

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Export itinerary')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddyCard(
              child: SelectableText(
                text,
                style: typography.small.copyWith(
                  color: colours.textPrimary,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: spacing.lg),
            QaddyGoldButton(
              label: 'Share itinerary',
              onPressed: () => shareOrCopy(
                context,
                ref,
                text: text,
                subject: '${trip.name} itinerary',
              ),
            ),
            SizedBox(height: spacing.sm),
            QaddySecondaryButton(label: 'Copy as Text', onPressed: copy),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
