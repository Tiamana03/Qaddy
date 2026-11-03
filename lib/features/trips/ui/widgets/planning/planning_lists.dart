/// The Planning screen's checklist (tasks), packing list and bookings views.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// A checkable row: a checkbox, a title (struck through once done), an
/// optional second line and an edit button.
class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.checked,
    required this.onToggle,
    required this.onEdit,
    this.subtitle,
    this.subtitleColour,
  });

  final String title;
  final String? subtitle;
  final Color? subtitleColour;
  final bool checked;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      checked: checked,
      label: title,
      hint: subtitle,
      excludeSemantics: true,
      onTap: onToggle,
      child: InkWell(
        onTap: onToggle,
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Checkbox(value: checked, onChanged: (_) => onToggle()),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: typography.body.copyWith(
                      color: checked
                          ? colours.textTertiary
                          : colours.textPrimary,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: typography.small.copyWith(
                        color: subtitleColour ?? colours.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit $title',
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: colours.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The trip's to-do list.
class PlanningChecklist extends StatelessWidget {
  const PlanningChecklist({
    required this.tripId,
    required this.tasks,
    required this.now,
    required this.onToggle,
    super.key,
  });

  /// The trip the tasks belong to.
  final String tripId;

  /// The tasks, in list order.
  final List<TripTask> tasks;

  /// Today, for flagging overdue tasks.
  final DateTime now;

  /// Called with a task's id when it is ticked or unticked.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.tasks.slug,
      'new',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (tasks.isEmpty)
          QaddyCard(
            child: Text(
              'No tasks yet. Add the things that need doing before you go — '
              'book the dinner, share the tee times, sort the cars.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          )
        else
          QaddyCard(
            child: Column(
              children: <Widget>[
                for (final task in tasks)
                  _CheckRow(
                    title: task.title,
                    checked: task.done,
                    onToggle: () => onToggle(task.id),
                    onEdit: () => context.push(
                      AppRoutes.tripEditItem(
                        tripId,
                        TripEditSection.tasks.slug,
                        task.id,
                      ),
                    ),
                    subtitle: task.due == null
                        ? null
                        : (!task.done &&
                                  task.due!.dateOnly.isBefore(now.dateOnly)
                              ? 'Overdue · ${task.due!.toFriendlyDate()}'
                              : 'Due ${task.due!.toFriendlyDate()}'),
                    subtitleColour:
                        task.due != null &&
                            !task.done &&
                            task.due!.dateOnly.isBefore(now.dateOnly)
                        ? colours.warning
                        : null,
                  ),
              ],
            ),
          ),
        SizedBox(height: spacing.md),
        QaddySecondaryButton(
          label: 'Add task',
          onPressed: () => context.push(addRoute),
        ),
      ],
    );
  }
}

/// The packing list.
class PlanningPacking extends StatelessWidget {
  const PlanningPacking({
    required this.tripId,
    required this.items,
    required this.onToggle,
    super.key,
  });

  /// The trip the items belong to.
  final String tripId;

  /// The items, in list order.
  final List<PackingItem> items;

  /// Called with an item's id when it is packed or unpacked.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.packing.slug,
      'new',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (items.isEmpty)
          QaddyCard(
            child: Text(
              'Nothing on the list yet. Add clubs, rain jacket, '
              'adaptor — whatever you do not want to forget.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          )
        else
          QaddyCard(
            child: Column(
              children: <Widget>[
                for (final item in items)
                  _CheckRow(
                    title: item.label,
                    checked: item.packed,
                    onToggle: () => onToggle(item.id),
                    onEdit: () => context.push(
                      AppRoutes.tripEditItem(
                        tripId,
                        TripEditSection.packing.slug,
                        item.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(height: spacing.md),
        QaddySecondaryButton(
          label: 'Add packing item',
          onPressed: () => context.push(addRoute),
        ),
      ],
    );
  }
}

/// Every booking at a glance, each linking to its page, plus the notes.
class PlanningBookings extends StatelessWidget {
  const PlanningBookings({required this.tripId, required this.plan, super.key});

  /// The trip the bookings belong to.
  final String tripId;

  /// The trip's plan.
  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    String count(int n, String singular, String plural) =>
        n == 0 ? 'None yet' : '$n ${n == 1 ? singular : plural}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        QaddyCard(
          child: Column(
            children: <Widget>[
              QaddyNavRow(
                icon: Icons.flight_takeoff,
                title: 'Flights',
                subtitle: count(plan.flights.length, 'flight', 'flights'),
                onTap: () => context.push(AppRoutes.tripFlights(tripId)),
              ),
              QaddyNavRow(
                icon: Icons.hotel_outlined,
                title: 'Accommodation',
                subtitle: count(plan.accommodations.length, 'stay', 'stays'),
                onTap: () => context.push(AppRoutes.tripAccommodation(tripId)),
              ),
              QaddyNavRow(
                icon: Icons.directions_car_outlined,
                title: 'Transport',
                subtitle: count(plan.transport.length, 'booking', 'bookings'),
                onTap: () => context.push(AppRoutes.tripTransport(tripId)),
              ),
              QaddyNavRow(
                icon: Icons.golf_course_outlined,
                title: 'Golf',
                subtitle: count(plan.courses.length, 'course', 'courses'),
                onTap: () => context.push(AppRoutes.tripGolf(tripId)),
              ),
              QaddyNavRow(
                icon: Icons.payments_outlined,
                title: 'Expenses',
                subtitle: plan.expenses.isEmpty
                    ? 'None yet'
                    : '${formatMoney(summariseExpenses(plan.expenses).total)}'
                          ' total',
                onTap: () => context.push(AppRoutes.tripExpenses(tripId)),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.sectionGap),
        Text(
          'Notes',
          style: typography.h3.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.sm),
        QaddyCard(
          onTap: () => context.push(
            AppRoutes.tripEditSection(tripId, TripEditSection.notes.slug),
          ),
          child: Text(
            plan.notes.trim().isEmpty
                ? 'Add notes — dress codes, bookings, things to remember.'
                : plan.notes,
            style: typography.body.copyWith(
              color: plan.notes.trim().isEmpty
                  ? colours.textSecondary
                  : colours.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
