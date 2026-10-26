/// One-line summaries for the Edit Trip hub, so each row says what is in the
/// section before it is opened.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// "3 flights", "No flights yet" — pluralised and never blank.
String _count(int n, String singular, {String? plural, String? none}) {
  if (n == 0) {
    return none ?? 'No ${plural ?? '${singular}s'} yet';
  }
  return '$n ${n == 1 ? singular : plural ?? '${singular}s'}';
}

/// The summary line for [section] of [trip].
String tripEditSummary(Trip trip, TripPlan plan, TripEditSection section) {
  switch (section) {
    case TripEditSection.details:
      final visibility = trip.visibility == TripVisibility.public
          ? 'Public'
          : 'Private';
      return '${trip.name} · $visibility';
    case TripEditSection.dates:
      return '${trip.startDate.toFriendlyRange(trip.endDate)} · '
          '${_count(trip.durationInDays, 'day')}';
    case TripEditSection.destination:
      return trip.destination;
    case TripEditSection.accommodation:
      return _count(plan.accommodations.length, 'stay');
    case TripEditSection.flights:
      return _count(plan.flights.length, 'flight');
    case TripEditSection.transport:
      return _count(plan.transport.length, 'booking');
    case TripEditSection.courses:
      return _count(plan.courses.length, 'course');
    case TripEditSection.players:
      final going = plan.confirmedMembers.length;
      final invited = plan.pendingMembers.length;
      return invited == 0 ? '$going going' : '$going going · $invited invited';
    case TripEditSection.expenses:
      if (plan.expenses.isEmpty) {
        return 'No expenses yet';
      }
      final total = summariseExpenses(plan.expenses).total;
      return '${_count(plan.expenses.length, 'expense')} · '
          '${formatMoney(total)}';
    case TripEditSection.notes:
      final firstLine = plan.notes.trim().split('\n').first;
      return firstLine.isEmpty ? 'No notes yet' : firstLine;
    case TripEditSection.weather:
      return _count(plan.weather.length, 'day', none: 'No forecast yet');
    case TripEditSection.packing:
      if (plan.packing.isEmpty) {
        return 'Nothing on the list yet';
      }
      final packed = plan.packing.where((item) => item.packed).length;
      return '$packed of ${plan.packing.length} packed';
    case TripEditSection.chat:
      final settings = plan.chatSettings;
      return <String>[
        if (settings.muted) 'Muted',
        'Read receipts ${settings.readReceipts ? 'on' : 'off'}',
        'Typing ${settings.typingIndicators ? 'on' : 'off'}',
      ].join(' · ');
  }
}
