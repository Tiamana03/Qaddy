/// Qaddy's Golf Schedule screen — courses, tee times, groups and side games.
///
/// See `docs/features/trips-feature-integration.md`'s "Golf Schedule"
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

/// Golf Schedule (route `/trips/:tripId/golf`).
class TripGolfScheduleScreen extends ConsumerWidget {
  const TripGolfScheduleScreen({required this.tripId, super.key});

  /// The trip whose golf is shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Golf Schedule')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Courses & Tee Times',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, course)
                      in plan.courses.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: course.name,
                      value: course.teeTime.toFriendlyTime(),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Playing Groups',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, group)
                      in plan.playingGroups.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: group.name,
                      value: group.players.join(', '),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Side Games',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, game)
                      in plan.sideGames.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(label: game.name, value: 'Hole ${game.hole}'),
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
