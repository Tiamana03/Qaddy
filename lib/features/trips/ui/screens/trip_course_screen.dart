/// A course's own page: tee time, who is playing, fees, course facts,
/// contact details, a map, photos, the day's weather and how to get there.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_message_bubble.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Course page (route `/trips/:tripId/golf/:courseId`).
class TripCourseScreen extends ConsumerWidget {
  const TripCourseScreen({
    required this.tripId,
    required this.courseId,
    super.key,
  });

  /// The trip the course belongs to.
  final String tripId;

  /// The course to show.
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    TripCourse? course;
    for (final candidate in plan.courses) {
      if (candidate.id == courseId) {
        course = candidate;
      }
    }
    if (course == null) {
      return const TripNotFound();
    }

    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final weather = forecastForDay(plan.weather, course.teeTime);
    final fee = course.greenFee;
    final total = course.totalGreenFees;
    final stay = plan.accommodations.isEmpty ? null : plan.accommodations.first;
    final place = course.address.isEmpty ? course.name : course.address;
    final shownCourse = course;
    void directions() => openLinkOrCopy(
      context,
      ref,
      uri: mapDirectionsUri(destination: place, origin: stay?.address),
      fallback: place,
      label: 'directions to ${shownCourse.name}',
    );
    final headerFacts = <String>[
      course.teeTime.toDayAndTime(),
      if (course.courseRating != null) 'Rating ${course.courseRating}',
      if (course.slope != null) 'Slope ${course.slope}',
    ];

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Course'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit course',
            onPressed: () => context.push(
              AppRoutes.tripEditItem(
                tripId,
                TripEditSection.courses.slug,
                course!.id,
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            DetailHeader(
              // A placeholder for the course's logo.
              icon: Icons.flag_outlined,
              title: course.name,
              subtitle: course.address.isEmpty ? null : course.address,
              facts: headerFacts,
            ),
            const DetailSectionTitle('Tee time'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  FactRow(
                    label: 'Date',
                    value: course.teeTime.toWeekdayAndDate(),
                  ),
                  FactRow(
                    label: 'Tee time',
                    value: course.teeTime.toFriendlyTime(),
                  ),
                  if (weather != null)
                    FactRow(
                      label: 'Forecast',
                      value:
                          '${weather.forecast}, ${weather.highLabel} / '
                          '${weather.lowLabel}',
                    )
                  else
                    const FactRow(label: 'Forecast', value: 'Not added yet'),
                ],
              ),
            ),
            DetailSectionTitle(
              course.players.isEmpty
                  ? 'Players'
                  : 'Players (${course.players.length})',
            ),
            QaddyCard(
              child: course.players.isEmpty
                  ? Text(
                      'No one assigned yet. Edit the course to choose who is '
                      'playing.',
                      style: typography.body.copyWith(
                        color: colours.textSecondary,
                      ),
                    )
                  : Wrap(
                      spacing: spacing.md,
                      runSpacing: spacing.md,
                      children: <Widget>[
                        for (final name in course.players)
                          _PlayerChip(name: name),
                      ],
                    ),
            ),
            if (fee != null) ...<Widget>[
              const DetailSectionTitle('Green fees'),
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    FactRow(label: 'Per player', value: formatMoney(fee)),
                    FactRow(
                      label: 'Players',
                      value: '${course.players.length}',
                    ),
                    FactRow(label: 'Total', value: formatMoney(total ?? 0)),
                  ],
                ),
              ),
            ],
            const DetailSectionTitle('About the Course'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  if (course.courseRating != null)
                    FactRow(
                      label: 'Course rating',
                      value: '${course.courseRating}',
                    ),
                  if (course.slope != null)
                    FactRow(label: 'Slope', value: '${course.slope}'),
                  FactRow(
                    label: 'Dress code',
                    value: course.dressCode.isEmpty
                        ? 'Not specified'
                        : course.dressCode,
                  ),
                  if (course.courseRating == null && course.slope == null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xs),
                      child: Text(
                        'Add the rating and slope by editing the course.',
                        style: typography.small.copyWith(
                          color: colours.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const DetailSectionTitle('Contact'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  if (course.phone.isNotEmpty)
                    ContactRow(kind: ContactKind.phone, value: course.phone),
                  if (course.website.isNotEmpty)
                    ContactRow(
                      kind: ContactKind.website,
                      value: course.website,
                    ),
                  if (course.address.isNotEmpty)
                    ContactRow(
                      kind: ContactKind.address,
                      value: course.address,
                    ),
                  if (course.phone.isEmpty &&
                      course.website.isEmpty &&
                      course.address.isEmpty)
                    Text(
                      'No contact details yet.',
                      style: typography.body.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const DetailSectionTitle('Map & Directions'),
            MapPlaceholder(
              label: course.address.isEmpty ? course.name : course.address,
              onTap: directions,
            ),
            SizedBox(height: spacing.sm),
            if (stay != null)
              Text(
                'Driving from ${stay.name}.',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            SizedBox(height: spacing.sm),
            QaddySecondaryButton(
              label: 'Get directions',
              onPressed: directions,
            ),
            if (course.notes.isNotEmpty) ...<Widget>[
              const DetailSectionTitle('Notes'),
              QaddyCard(
                child: Text(
                  course.notes,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ChatAvatar(name: name),
        SizedBox(width: spacing.sm),
        Text(name, style: typography.body.copyWith(color: colours.textPrimary)),
      ],
    );
  }
}
