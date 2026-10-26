/// Plain-text exports of a trip: the itinerary a golfer can paste into a
/// message or print, and the invite link they can share.
///
/// A real PDF needs a document-generation dependency (see technical debt);
/// until then the text is the export.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/logic/trip_timeline.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// The placeholder invite link for [trip]. The host is reserved
/// (`.example`) so it can never point at a real site; it becomes the real
/// deep link once Qaddy has a backend.
String tripInviteLink(Trip trip) => 'https://qaddy.example/join/${trip.id}';

/// The whole trip as readable text: header, players, a day-by-day schedule
/// with the weather, money and notes.
String itineraryText(Trip trip, TripPlan plan) {
  final out = StringBuffer()
    ..writeln(trip.name.toUpperCase())
    ..writeln(
      '${trip.destination} · ${trip.startDate.toFriendlyRange(trip.endDate)} · '
      '${trip.durationInDays} ${trip.durationInDays == 1 ? 'day' : 'days'}',
    );

  final going = plan.confirmedMembers.map((m) => m.displayName).toList();
  if (going.isNotEmpty) {
    out.writeln('Players: ${going.join(', ')}');
  }

  final days = buildTimeline(trip, plan);
  if (days.any((day) => day.events.isNotEmpty)) {
    out
      ..writeln()
      ..writeln('SCHEDULE');
    for (final day in days) {
      if (day.events.isEmpty) {
        continue;
      }
      final weather = day.weather;
      out.writeln(
        '${day.date.toWeekdayAndDate()}'
        '${weather == null ? '' : ' — ${weather.forecast}, '
                  '${weather.highLabel}/${weather.lowLabel}'}',
      );
      for (final event in day.events) {
        out.write('  ${event.at.toFriendlyTime()}  ${event.title}');
        if (event.subtitle.isNotEmpty) {
          out.write(' (${event.subtitle})');
        }
        out.writeln();
      }
    }
  }

  if (plan.flights.isNotEmpty) {
    out
      ..writeln()
      ..writeln('FLIGHTS');
    for (final flight in plan.flights) {
      out.write(
        '  ${flight.airline} ${flight.flightNumber} · ${flight.routeLabel}',
      );
      if (flight.bookingReference.isNotEmpty) {
        out.write(' · Ref ${flight.bookingReference}');
      }
      out.writeln();
    }
  }

  if (plan.accommodations.isNotEmpty) {
    out
      ..writeln()
      ..writeln('ACCOMMODATION');
    for (final stay in plan.accommodations) {
      out.writeln(
        '  ${stay.name} · ${stay.checkIn.toFriendlyRange(stay.checkOut)}',
      );
      if (stay.address.isNotEmpty) {
        out.writeln('  ${stay.address}');
      }
      if (stay.bookingNumber.isNotEmpty) {
        out.writeln('  Booking ${stay.bookingNumber}');
      }
    }
  }

  if (plan.expenses.isNotEmpty) {
    final summary = summariseExpenses(plan.expenses);
    out
      ..writeln()
      ..writeln('MONEY')
      ..writeln(
        '  Total ${formatMoney(summary.total)} · '
        'paid ${formatMoney(summary.paid)} · '
        'outstanding ${formatMoney(summary.outstanding)}',
      );
  }

  if (plan.notes.trim().isNotEmpty) {
    out
      ..writeln()
      ..writeln('NOTES')
      ..writeln(plan.notes.trim());
  }

  return out.toString().trimRight();
}
