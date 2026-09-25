/// Qaddy's Golf Schedule screen.
///
/// See `docs/features/trips-feature-integration.md`'s "Golf Schedule"
/// section ("Displays: Courses, Tee Times, Playing Groups, Side Games").
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Golf Schedule (route `/trips/golf`).
class TripGolfScheduleScreen extends StatelessWidget {
  const TripGolfScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      in melbourneGolfWeekendCourses.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: course.name, value: course.teeTime),
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
                      in melbourneGolfWeekendPlayingGroups.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(
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
                      in melbourneGolfWeekendSideGames.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: game.name, value: 'Hole ${game.hole}'),
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
