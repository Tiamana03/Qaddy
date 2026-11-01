/// Qaddy's Planning screen — the trip's day-by-day plan, checklist, packing
/// list and bookings in one place.
///
/// See `docs/features/trips-feature-integration.md`'s "Planning" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_lists.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_timeline.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// The views on the Planning screen.
enum PlanningView { timeline, checklist, packing, bookings }

/// Planning (route `/trips/:tripId/planning`).
class TripPlanningScreen extends ConsumerStatefulWidget {
  const TripPlanningScreen({
    required this.tripId,
    this.initialView = PlanningView.timeline,
    super.key,
  });

  /// The trip being planned.
  final String tripId;

  /// The view shown first.
  final PlanningView initialView;

  @override
  ConsumerState<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends ConsumerState<TripPlanningScreen> {
  late PlanningView _view = widget.initialView;

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final now = ref.watch(tripsClockProvider)();
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final controller = ref.read(tripsProvider.notifier);

    final days = buildTimeline(trip, plan);
    final progress = plan.planningProgress;
    final nextTask = plan.nextTask;
    final done = plan.tasks.where((task) => task.done).length;
    final packed = plan.packing.where((item) => item.packed).length;

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Planning'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Activity',
            onPressed: () => context.push(
              AppRoutes.tripEditItem(
                widget.tripId,
                TripEditSection.itinerary.slug,
                'new',
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            QaddyCard(
              child: Row(
                children: <Widget>[
                  PlanningRing(
                    progress: progress ?? 0,
                    label: progress == null
                        ? '—'
                        : '${(progress * 100).round()}%',
                    semanticLabel: progress == null
                        ? 'No planning tasks yet'
                        : 'Planning ${(progress * 100).round()} percent '
                              'complete',
                    size: 72,
                  ),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          plan.tasks.isEmpty
                              ? 'Start planning'
                              : '$done of ${plan.tasks.length} tasks done',
                          style: typography.h4.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          nextTask == null
                              ? (plan.tasks.isEmpty
                                    ? 'Add tasks to track what is left to '
                                          'organise.'
                                    : 'Everything is done. Enjoy the trip!')
                              : 'Next: ${nextTask.title}',
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.lg),
            QaddySegmentedControl<PlanningView>(
              segments: const <QaddySegment<PlanningView>>[
                QaddySegment(value: PlanningView.timeline, label: 'Timeline'),
                QaddySegment(value: PlanningView.checklist, label: 'Tasks'),
                QaddySegment(value: PlanningView.packing, label: 'Packing'),
                QaddySegment(value: PlanningView.bookings, label: 'Bookings'),
              ],
              selected: _view,
              onChanged: (value) => setState(() => _view = value),
            ),
            SizedBox(height: spacing.lg),
            switch (_view) {
              PlanningView.timeline => PlanningTimeline(
                tripId: widget.tripId,
                days: days,
                next: nextTimelineEvent(days, now),
              ),
              PlanningView.checklist => PlanningChecklist(
                tripId: widget.tripId,
                tasks: plan.tasks,
                now: now,
                onToggle: (id) {
                  QaddyHaptics.selection();
                  controller.toggleTask(widget.tripId, id);
                },
              ),
              PlanningView.packing => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (plan.packing.isNotEmpty) ...<Widget>[
                    Text(
                      '$packed of ${plan.packing.length} packed',
                      style: typography.body.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.sm),
                  ],
                  PlanningPacking(
                    tripId: widget.tripId,
                    items: plan.packing,
                    onToggle: (id) {
                      QaddyHaptics.selection();
                      controller.togglePacked(widget.tripId, id);
                    },
                  ),
                ],
              ),
              PlanningView.bookings => PlanningBookings(
                tripId: widget.tripId,
                plan: plan,
              ),
            },
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}
