/// Qaddy's Golf Schedule screen — every course on the trip as a tee-time
/// card, then playing groups and side games.
///
/// See `docs/features/trips-feature-integration.md`'s "Golf Schedule"
/// section. Each course opens its own page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Golf Schedule (route `/trips/:tripId/golf`).
class TripGolfScheduleScreen extends ConsumerWidget {
  const TripGolfScheduleScreen({required this.tripId, super.key});

  /// The trip whose golf is shown.
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

    final courses = <TripCourse>[...plan.courses]
      ..sort((a, b) => a.teeTime.compareTo(b.teeTime));
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.courses.slug,
      'new',
    );

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Golf Schedule'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add course',
            onPressed: () => context.push(addRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            if (courses.isNotEmpty) ...<Widget>[
              DetailHeader(
                icon: Icons.golf_course_outlined,
                title: 'The golf',
                subtitle: trip.name,
                facts: <String>[
                  _rounds(courses.length),
                  '${trip.playerCount} players',
                  'First tee ${courses.first.teeTime.toFriendlyTime()}',
                ],
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            if (courses.isEmpty)
              QaddyEmptyState(
                icon: Icons.golf_course_outlined,
                title: 'No courses yet',
                message:
                    'Add the courses you are playing and their tee times — '
                    'each one gets its own page.',
                actionLabel: 'Add course',
                onAction: () => context.push(addRoute),
              )
            else
              for (final (index, course) in courses.indexed) ...<Widget>[
                if (index == 0 ||
                    !courses[index - 1].teeTime.isSameDay(course.teeTime))
                  Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : spacing.lg,
                      bottom: spacing.sm,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        course.teeTime.toWeekdayAndDate(),
                        style: typography.h3.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                    ),
                  ),
                _CourseCard(
                  tripId: tripId,
                  course: course,
                  weather: forecastForDay(plan.weather, course.teeTime),
                ),
                SizedBox(height: spacing.cardGap),
              ],
            if (plan.playingGroups.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Playing groups'),
              SizedBox(height: spacing.md),
              QaddyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final (index, group)
                        in plan.playingGroups.indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.lg),
                      Text(
                        group.name,
                        style: typography.h4.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Wrap(
                        spacing: spacing.md,
                        runSpacing: spacing.sm,
                        children: <Widget>[
                          for (final player in group.players)
                            _PlayerPill(name: player),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (plan.sideGames.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Side games'),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: <Widget>[
                  for (final game in plan.sideGames)
                    _SideGamePill(name: game.name, hole: game.hole),
                ],
              ),
            ],
            if (courses.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySecondaryButton(
                label: 'Add course',
                icon: Icons.add,
                onPressed: () => context.push(addRoute),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.tripId,
    required this.course,
    required this.weather,
  });

  final String tripId;
  final TripCourse course;
  final TripWeatherForecast? weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final count = course.players.length;
    final fee = course.greenFee;
    final facts = <String>[
      '$count ${count == 1 ? 'player' : 'players'}',
      if (fee != null) '${formatMoney(fee)} pp',
    ];

    return QaddyCard(
      onTap: () => context.push(AppRoutes.tripCourse(tripId, course.id)),
      child: Row(
        children: <Widget>[
          Container(
            width: spacing.hero + spacing.md,
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            decoration: BoxDecoration(
              color: colours.surface2,
              borderRadius: BorderRadius.circular(radius.medium),
            ),
            child: Column(
              children: <Widget>[
                Icon(Icons.golf_course_outlined, color: colours.accent),
                SizedBox(height: spacing.xs),
                Text(
                  course.teeTime.toFriendlyTime(),
                  textAlign: TextAlign.center,
                  style: typography.small.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  course.name,
                  style: typography.h4.copyWith(color: colours.textPrimary),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  facts.join(' · '),
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (weather != null) ...<Widget>[
            Column(
              children: <Widget>[
                Icon(weather!.condition.icon, color: colours.textSecondary),
                Text(
                  weather!.highLabel,
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(width: spacing.sm),
          ],
          Icon(Icons.chevron_right, color: colours.textTertiary),
        ],
      ),
    );
  }
}

/// One player in a playing group: a face and a name.
class _PlayerPill extends StatelessWidget {
  const _PlayerPill({required this.name});

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
        SizedBox(
          width: 28,
          height: 28,
          child: FittedBox(child: QaddyAvatar(name: name)),
        ),
        SizedBox(width: spacing.xs),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(color: colours.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// A side game and the hole it is played on.
class _SideGamePill extends StatelessWidget {
  const _SideGamePill({required this.name, required this.hole});

  final String name;
  final int hole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colours.surface1,
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.flag_outlined, size: 16, color: colours.gold),
          SizedBox(width: spacing.xs),
          Flexible(
            child: Text(
              '$name · Hole $hole',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.small.copyWith(color: colours.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

String _rounds(int count) => '$count ${count == 1 ? 'round' : 'rounds'}';
