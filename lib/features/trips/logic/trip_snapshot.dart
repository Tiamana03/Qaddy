/// What the Trips hero can say about a trip beyond its name and dates.
///
/// Everything here is read from the trip's own plan (courses, weather,
/// expenses, members, tasks, chat) — nothing is invented, and a section the
/// golfer hasn't filled in simply doesn't appear. A brand-new trip therefore
/// yields an empty snapshot, and the hero shows only its countdown and dates.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// One labelled fact on the hero, e.g. "First tee — Kingston Heath · 8:10 AM".
class TripHighlight {
  const TripHighlight({
    required this.icon,
    required this.label,
    required this.value,
    this.wide = false,
    this.isCourse = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Whether the fact needs a full row (long values) rather than half of one.
  final bool wide;

  /// Whether the fact is about a course, so its icon is drawn as a course
  /// logo placeholder (a flag on a disc).
  final bool isCourse;
}

/// The hero's supporting facts for one trip.
class TripSnapshot {
  const TripSnapshot({
    required this.highlights,
    required this.squad,
    this.pendingInvites = 0,
    this.planningProgress,
    this.nextTask,
    this.upcomingPayment,
    this.budgetProgress,
    this.budgetLabel,
    this.latestMessage,
    this.latestUpdate,
  });

  /// Short facts: first tee time and the forecast.
  final List<TripHighlight> highlights;

  /// Names of the confirmed players ("who's going").
  final List<String> squad;

  /// How many invitations are still waiting for a reply.
  final int pendingInvites;

  /// Share of checklist tasks done (0–1), or `null` with no tasks.
  final double? planningProgress;

  /// The next task to do, if any.
  final String? nextTask;

  /// What the golfer owes next, e.g. "You owe Ben $730 · Green fees".
  final String? upcomingPayment;

  /// Share of the trip's cost that is paid (0–1), or `null` with no expenses.
  final double? budgetProgress;

  /// A line for the budget bar, e.g. "52% paid · $5,540 to go".
  final String? budgetLabel;

  /// The most recent chat message, as "Sender: message".
  final String? latestMessage;

  /// The most recent change to the trip's plan, e.g. "Added flight QF431".
  final String? latestUpdate;

  /// Whether there is anything to show.
  bool get isEmpty =>
      highlights.isEmpty &&
      squad.isEmpty &&
      pendingInvites == 0 &&
      planningProgress == null &&
      nextTask == null &&
      upcomingPayment == null &&
      budgetProgress == null &&
      latestMessage == null &&
      latestUpdate == null;
}

/// The snapshot for a trip with the given [plan], as seen by [viewer]
/// (defaults to the signed-in golfer, for "you owe …").
TripSnapshot tripSnapshot(TripPlan plan, {String? viewer}) {
  final courses = [...plan.courses]
    ..sort((a, b) => a.teeTime.compareTo(b.teeTime));
  final summary = summariseExpenses(plan.expenses);
  final payment = upcomingPaymentFor(plan.expenses, viewer ?? currentUserName);
  final nextTask = plan.nextTask;
  final latestMessage = plan.messages.isEmpty ? null : plan.messages.last;

  return TripSnapshot(
    highlights: <TripHighlight>[
      if (courses.isNotEmpty)
        TripHighlight(
          icon: Icons.flag_outlined,
          label: 'First tee',
          value:
              '${courses.first.name} · '
              '${courses.first.teeTime.toFriendlyTime()}',
          wide: true,
          isCourse: true,
        ),
      if (plan.weather.isNotEmpty)
        TripHighlight(
          icon: plan.weather.first.condition.icon,
          label: '${plan.weather.first.day} forecast',
          value:
              '${plan.weather.first.forecast}, ${plan.weather.first.highLabel}',
          wide: true,
        ),
    ],
    squad: <String>[
      for (final member in plan.confirmedMembers) member.displayName,
    ],
    pendingInvites: plan.pendingMembers.length,
    planningProgress: plan.planningProgress,
    nextTask: nextTask?.title,
    upcomingPayment: payment == null
        ? null
        : 'You owe ${payment.to} ${formatMoney(payment.amount)} · '
              '${payment.forExpense}',
    budgetProgress: plan.expenses.isEmpty ? null : summary.paidFraction,
    budgetLabel: plan.expenses.isEmpty
        ? null
        : summary.isSettled
        ? 'All settled'
        : '${(summary.paidFraction * 100).round()}% paid · '
              '${formatMoney(summary.outstanding)} to go',
    latestMessage: latestMessage == null
        ? null
        : '${latestMessage.sender}: ${latestMessage.text}',
    latestUpdate: plan.latestUpdate?.text,
  );
}
