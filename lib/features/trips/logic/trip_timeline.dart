/// Builds the Planning screen's day-by-day timeline.
///
/// A trip's plan is stored as separate records (flights, stays, tee times,
/// transport, user-added itinerary items). The timeline merges them, groups
/// them by calendar day, attaches that day's forecast, and includes every day
/// of the trip even when nothing is planned for it.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';

/// Which record a timeline event came from, so it can open its own page.
enum TimelineSource { flight, accommodation, course, transport, itinerary }

/// One entry on a day.
class TimelineEvent {
  const TimelineEvent({
    required this.source,
    required this.sourceId,
    required this.kind,
    required this.title,
    required this.at,
    this.subtitle = '',
  });

  /// The kind of record it came from.
  final TimelineSource source;

  /// That record's id.
  final String sourceId;

  /// How to group/iconify it.
  final ItineraryKind kind;

  /// Headline.
  final String title;

  /// When it happens.
  final DateTime at;

  /// Supporting line (route, location…).
  final String subtitle;
}

/// One calendar day of the trip.
class TimelineDay {
  const TimelineDay({required this.date, required this.events, this.weather});

  /// The day (midnight, local).
  final DateTime date;

  /// Everything happening, earliest first.
  final List<TimelineEvent> events;

  /// That day's forecast, if one was entered.
  final TripWeatherForecast? weather;
}

/// The merged, day-grouped timeline for [trip] and its [plan].
List<TimelineDay> buildTimeline(Trip trip, TripPlan plan) {
  final events = <TimelineEvent>[
    for (final flight in plan.flights)
      TimelineEvent(
        source: TimelineSource.flight,
        sourceId: flight.id,
        kind: ItineraryKind.flight,
        title: '${flight.airline} ${flight.flightNumber}',
        at: flight.departure,
        subtitle:
            '${flight.routeLabel} · arrives ${flight.arrival.toFriendlyTime()}',
      ),
    for (final stay in plan.accommodations) ...<TimelineEvent>[
      TimelineEvent(
        source: TimelineSource.accommodation,
        sourceId: stay.id,
        kind: ItineraryKind.lodging,
        title: 'Check in · ${stay.name}',
        at: stay.checkIn,
        subtitle: stay.address,
      ),
      TimelineEvent(
        source: TimelineSource.accommodation,
        sourceId: stay.id,
        kind: ItineraryKind.lodging,
        title: 'Check out · ${stay.name}',
        at: stay.checkOut,
      ),
    ],
    for (final course in plan.courses)
      TimelineEvent(
        source: TimelineSource.course,
        sourceId: course.id,
        kind: ItineraryKind.golf,
        title: 'Golf · ${course.name}',
        at: course.teeTime,
        subtitle: course.players.isEmpty
            ? 'Tee time'
            : 'Tee time · ${course.players.length} players',
      ),
    for (final leg in plan.transport)
      TimelineEvent(
        source: TimelineSource.transport,
        sourceId: leg.id,
        kind: ItineraryKind.transport,
        title: leg.type.label,
        at: leg.pickup,
        subtitle: leg.routeLabel,
      ),
    for (final item in plan.itinerary)
      TimelineEvent(
        source: TimelineSource.itinerary,
        sourceId: item.id,
        kind: item.kind,
        title: item.title,
        at: item.start,
        subtitle: item.location,
      ),
  ];

  final byDay = <DateTime, List<TimelineEvent>>{};
  for (final event in events) {
    byDay.putIfAbsent(event.at.dateOnly, () => <TimelineEvent>[]).add(event);
  }

  final days = <DateTime>{...byDay.keys};
  final lastDay = trip.endDate.dateOnly;
  for (
    var day = trip.startDate.dateOnly;
    !day.isAfter(lastDay);
    day = DateTime(day.year, day.month, day.day + 1)
  ) {
    days.add(day);
  }

  final ordered = days.toList()..sort();
  return <TimelineDay>[
    for (final day in ordered)
      TimelineDay(
        date: day,
        events: (byDay[day] ?? <TimelineEvent>[])
          ..sort((a, b) => a.at.compareTo(b.at)),
        weather: forecastForDay(plan.weather, day),
      ),
  ];
}

/// The forecast whose day name matches [day]'s weekday, if one was entered.
TripWeatherForecast? forecastForDay(
  List<TripWeatherForecast> forecasts,
  DateTime day,
) {
  for (final forecast in forecasts) {
    if (forecast.day.toLowerCase() == day.weekdayName.toLowerCase()) {
      return forecast;
    }
  }
  return null;
}

/// The first event at or after [now], across all [days], or `null` when
/// everything is in the past (or nothing is planned).
TimelineEvent? nextTimelineEvent(List<TimelineDay> days, DateTime now) {
  TimelineEvent? best;
  for (final day in days) {
    for (final event in day.events) {
      if (event.at.isBefore(now)) {
        continue;
      }
      if (best == null || event.at.isBefore(best.at)) {
        best = event;
      }
    }
  }
  return best;
}
