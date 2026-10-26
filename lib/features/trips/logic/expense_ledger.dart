/// The arithmetic behind a trip's Expenses screen: totals, who owes whom, and
/// the next payment a member has to make.
///
/// Pure functions over `TripExpense`s so they can be tested without any UI.
/// Amounts are rounded only for display, never in the sums.
library;

import 'package:qaddy/features/trips/models/trip_expense.dart';

/// Whole-trip totals.
class ExpenseSummary {
  const ExpenseSummary({
    required this.total,
    required this.paid,
    required this.outstanding,
  });

  /// Everything spent.
  final double total;

  /// The part of [total] that is covered (the payers' own shares plus every
  /// share marked paid).
  final double paid;

  /// The part of [total] still owed back to whoever paid up front.
  final double outstanding;

  /// [paid] as a share of [total] (0–1); 0 when nothing has been spent.
  double get paidFraction => total == 0 ? 0 : (paid / total).clamp(0, 1);

  /// Whether every share is settled (and there is something to settle).
  bool get isSettled => total > 0 && outstanding < 0.005;
}

/// A net amount one member owes another.
class TripDebt {
  const TripDebt({required this.from, required this.to, required this.amount});

  /// Who owes.
  final String from;

  /// Who is owed.
  final String to;

  /// How much.
  final double amount;
}

/// The next payment a member has to make.
class UpcomingPayment {
  const UpcomingPayment({
    required this.to,
    required this.amount,
    required this.forExpense,
  });

  /// Who they pay.
  final String to;

  /// How much.
  final double amount;

  /// The expense it is for.
  final String forExpense;
}

/// Totals across [expenses].
ExpenseSummary summariseExpenses(List<TripExpense> expenses) {
  var total = 0.0;
  var paid = 0.0;
  for (final expense in expenses) {
    total += expense.amount;
    paid += expense.paidAmount;
  }
  return ExpenseSummary(total: total, paid: paid, outstanding: total - paid);
}

/// Who owes whom after netting. Opposite debts between the same two members
/// cancel out, so each pair appears at most once. Largest debts first.
List<TripDebt> whoOwesWho(List<TripExpense> expenses) {
  final owed = <(String, String), double>{};
  for (final expense in expenses) {
    for (final member in expense.participants) {
      if (expense.isSettled(member)) {
        continue;
      }
      final share = expense.shareOf(member);
      if (share <= 0) {
        continue;
      }
      owed.update(
        (member, expense.paidBy),
        (sum) => sum + share,
        ifAbsent: () => share,
      );
    }
  }

  final debts = <TripDebt>[];
  final handled = <(String, String)>{};
  for (final entry in owed.entries) {
    final (from, to) = entry.key;
    if (handled.contains((from, to))) {
      continue;
    }
    handled
      ..add((from, to))
      ..add((to, from));
    final net = entry.value - (owed[(to, from)] ?? 0);
    if (net > 0.005) {
      debts.add(TripDebt(from: from, to: to, amount: net));
    } else if (net < -0.005) {
      debts.add(TripDebt(from: to, to: from, amount: -net));
    }
  }
  debts.sort((a, b) => b.amount.compareTo(a.amount));
  return debts;
}

/// The earliest-incurred unsettled share [member] owes someone else, or
/// `null` when they owe nothing.
UpcomingPayment? upcomingPaymentFor(List<TripExpense> expenses, String member) {
  final byDate = [...expenses]..sort((a, b) => a.date.compareTo(b.date));
  for (final expense in byDate) {
    if (expense.isSettled(member) || !expense.participants.contains(member)) {
      continue;
    }
    final share = expense.shareOf(member);
    if (share > 0) {
      return UpcomingPayment(
        to: expense.paidBy,
        amount: share,
        forExpense: expense.title,
      );
    }
  }
  return null;
}

/// "$1,234" — whole dollars with thousands separators; cents only when the
/// amount isn't whole.
String formatMoney(double amount) {
  final negative = amount < 0;
  final absolute = amount.abs();
  final whole = absolute == absolute.roundToDouble();
  final fixed = absolute.toStringAsFixed(whole ? 0 : 2);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  final cents = parts.length > 1 ? '.${parts[1]}' : '';
  return '${negative ? '-' : ''}\$$buffer$cents';
}
