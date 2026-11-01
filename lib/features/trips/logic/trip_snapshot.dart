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
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

/// The first round of the trip: where, when, and what the weather will do.
class TripFirstTee {
  const TripFirstTee({
    required this.course,
    required this.time,
    required this.day,
    this.weather,
  });

  /// The course's name.
  final String course;

  /// The tee time, e.g. "8:10 AM".
  final String time;

  /// The day, e.g. "Sun 29 Nov".
  final String day;

  /// The forecast for that day, when one was entered.
  final TripWeatherForecast? weather;
}

/// The very next thing on the trip's timeline: a flight, a tee time, dinner.
class TripUpNext {
  const TripUpNext({
    required this.icon,
    required this.title,
    required this.when,
  });

  /// The kind of event, as an icon.
  final IconData icon;

  /// What it is, e.g. "Qantas QF431".
  final String title;

  /// When, e.g. "Tomorrow, 8:30 AM" or "Sat 28 Nov · 8:30 AM".
  final String when;
}

/// The hero's supporting facts for one trip.
class TripSnapshot {
  const TripSnapshot({
    required this.squad,
    this.firstTee,
    this.upNext,
    this.pendingInvites = 0,
    this.planningProgress,
    this.tasksDone = 0,
    this.tasksTotal = 0,
    this.nextTask,
    this.upcomingPayment,
    this.paymentFor,
    this.budgetProgress,
    this.budgetLabel,
    this.latestMessage,
    this.latestUpdate,
  });

  /// The first round, if any course is planned.
  final TripFirstTee? firstTee;

  /// The next event on the timeline, if the trip has one still to come.
  final TripUpNext? upNext;

  /// Names of the confirmed players ("who's going").
  final List<String> squad;

  /// How many invitations are still waiting for a reply.
  final int pendingInvites;

  /// Share of checklist tasks done (0–1), or `null` with no tasks.
  final double? planningProgress;

  /// Checklist tasks done.
  final int tasksDone;

  /// Checklist tasks in total.
  final int tasksTotal;

  /// The next task to do, if any.
  final String? nextTask;

  /// What the golfer owes next, e.g. "You owe Ben $730".
  final String? upcomingPayment;

  /// What that payment is for, e.g. "Green fees — 3 rounds".
  final String? paymentFor;

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
      firstTee == null &&
      upNext == null &&
      squad.isEmpty &&
      pendingInvites == 0 &&
      planningProgress == null &&
      nextTask == null &&
      upcomingPayment == null &&
      budgetProgress == null &&
      latestMessage == null &&
      latestUpdate == null;
}

/// "Today, 8:30 AM", "Tomorrow, 8:30 AM" or "Sat 28 Nov · 8:30 AM".
String _whenLabel(DateTime at, DateTime now) {
  final today = now.dateOnly;
  if (at.isSameDay(today)) {
    return 'Today, ${at.toFriendlyTime()}';
  }
  if (at.isSameDay(DateTime(today.year, today.month, today.day + 1))) {
    return 'Tomorrow, ${at.toFriendlyTime()}';
  }
  return at.toDayAndTime();
}

/// The snapshot for a trip with the given [plan], as seen by [viewer]
/// (defaults to the signed-in golfer, for "you owe …"). Pass [trip] and [now]
/// to include what is coming up next.
TripSnapshot tripSnapshot(
  TripPlan plan, {
  Trip? trip,
  DateTime? now,
  String? viewer,
}) {
  final courses = [...plan.courses]
    ..sort((a, b) => a.teeTime.compareTo(b.teeTime));
  final summary = summariseExpenses(plan.expenses);
  final payment = upcomingPaymentFor(plan.expenses, viewer ?? currentUserName);
  final nextTask = plan.nextTask;
  final latestMessage = plan.messages.isEmpty ? null : plan.messages.last;
  final next = trip == null || now == null
      ? null
      : nextTimelineEvent(buildTimeline(trip, plan), now);

  return TripSnapshot(
    firstTee: courses.isEmpty
        ? null
        : TripFirstTee(
            course: courses.first.name,
            time: courses.first.teeTime.toFriendlyTime(),
            day: courses.first.teeTime.toShortWeekdayAndDate(),
            weather: forecastForDay(plan.weather, courses.first.teeTime),
          ),
    upNext: next == null
        ? null
        : TripUpNext(
            icon: next.kind.icon,
            title: next.title,
            when: _whenLabel(next.at, now!),
          ),
    squad: <String>[
      for (final member in plan.confirmedMembers) member.displayName,
    ],
    pendingInvites: plan.pendingMembers.length,
    planningProgress: plan.planningProgress,
    tasksDone: plan.tasks.where((task) => task.done).length,
    tasksTotal: plan.tasks.length,
    nextTask: nextTask?.title,
    upcomingPayment: payment == null
        ? null
        : 'You owe ${payment.to} ${formatMoney(payment.amount)}',
    paymentFor: payment?.forExpense,
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
