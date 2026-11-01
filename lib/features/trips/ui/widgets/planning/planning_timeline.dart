/// The Planning screen's daily timeline: one block per day of the trip, with
/// the weather and every flight, tee time, meal and transfer in order.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';

/// The route a timeline event opens: its own page where there is one,
/// otherwise its editor.
String routeForTimelineEvent(String tripId, TimelineEvent event) =>
    switch (event.source) {
      TimelineSource.flight => AppRoutes.tripFlight(tripId, event.sourceId),
      TimelineSource.course => AppRoutes.tripCourse(tripId, event.sourceId),
      TimelineSource.accommodation => AppRoutes.tripAccommodation(tripId),
      TimelineSource.transport => AppRoutes.tripTransport(tripId),
      TimelineSource.itinerary => AppRoutes.tripEditItem(
        tripId,
        TripEditSection.itinerary.slug,
        event.sourceId,
      ),
    };

/// The whole timeline.
class PlanningTimeline extends StatelessWidget {
  const PlanningTimeline({
    required this.tripId,
    required this.days,
    this.next,
    super.key,
  });

  /// The trip the timeline belongs to.
  final String tripId;

  /// The days to draw, in order.
  final List<TimelineDay> days;

  /// The next event still to come, which is highlighted as "NEXT".
  final TimelineEvent? next;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: staggered(<Widget>[
        for (final (index, day) in days.indexed) ...<Widget>[
          if (index > 0) SizedBox(height: spacing.sectionGap),
          _DayBlock(tripId: tripId, day: day, number: index + 1, next: next),
        ],
      ]),
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({
    required this.tripId,
    required this.day,
    required this.number,
    required this.next,
  });

  final String tripId;
  final TimelineDay day;
  final int number;
  final TimelineEvent? next;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final weather = day.weather;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  day.date.toWeekdayAndDate(),
                  style: typography.h3.copyWith(color: colours.textPrimary),
                ),
              ),
            ),
            if (weather != null) ...<Widget>[
              Icon(weather.condition.icon, color: colours.textSecondary),
              SizedBox(width: spacing.xs),
              Text(
                '${weather.highLabel} / ${weather.lowLabel}',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ],
          ],
        ),
        Text(
          'Day $number',
          style: typography.small.copyWith(color: colours.textTertiary),
        ),
        SizedBox(height: spacing.md),
        if (day.events.isEmpty)
          _EmptyDay(tripId: tripId, day: day.date)
        else
          for (final (index, event) in day.events.indexed)
            _EventRow(
              tripId: tripId,
              event: event,
              isLast: index == day.events.length - 1,
              isNext: identical(event, next),
            ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.tripId, required this.day});

  final String tripId;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.medium),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Nothing planned yet',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          QaddyTertiaryButton(
            label: 'Add an activity',
            onPressed: () => context.push(
              AppRoutes.tripEditItem(
                tripId,
                TripEditSection.itinerary.slug,
                'new',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.tripId,
    required this.event,
    required this.isLast,
    required this.isNext,
  });

  final String tripId;
  final TimelineEvent event;
  final bool isLast;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      label:
          '${isNext ? 'Next up: ' : ''}'
          '${event.at.toFriendlyTime()}, ${event.title}'
          '${event.subtitle.isEmpty ? '' : ', ${event.subtitle}'}',
      excludeSemantics: true,
      onTap: () => context.push(routeForTimelineEvent(tripId, event)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: 72,
              child: Padding(
                padding: EdgeInsets.only(top: spacing.sm),
                child: Text(
                  event.at.toFriendlyTime(),
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: spacing.xl,
              child: Column(
                children: <Widget>[
                  SizedBox(height: spacing.md),
                  Container(
                    width: isNext ? 14 : 10,
                    height: isNext ? 14 : 10,
                    decoration: BoxDecoration(
                      color: colours.accent,
                      shape: BoxShape.circle,
                      boxShadow: isNext
                          ? <BoxShadow>[
                              BoxShadow(
                                color: colours.accent.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: colours.border)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Material(
                  color: colours.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius.medium),
                    side: isNext
                        ? BorderSide(color: colours.accent)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(radius.medium),
                    onTap: () =>
                        context.push(routeForTimelineEvent(tripId, event)),
                    child: Padding(
                      padding: EdgeInsets.all(spacing.md),
                      child: Row(
                        children: <Widget>[
                          Icon(event.kind.icon, color: colours.accent),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (isNext)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: spacing.xs,
                                    ),
                                    child: Text(
                                      'NEXT',
                                      style: typography.caption.copyWith(
                                        color: colours.accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                Text(
                                  event.title,
                                  style: typography.body.copyWith(
                                    color: colours.textPrimary,
                                  ),
                                ),
                                if (event.subtitle.isNotEmpty)
                                  Text(
                                    event.subtitle,
                                    style: typography.small.copyWith(
                                      color: colours.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colours.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
