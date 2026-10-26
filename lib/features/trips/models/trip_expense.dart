/// A Trip's shared expenses — see `docs/architecture/trip-data-model.md`'s
/// "Expenses" section.
///
/// Release 1 keeps a simple ledger: each expense has one payer, is shared
/// between some participants (equally or by custom amounts), and each
/// participant's share is either settled or outstanding. There is no payment
/// processing — "mark paid" records that a share has been settled outside the
/// app. See `logic/expense_ledger.dart` for the totals and "who owes who".
library;

import 'package:flutter/material.dart';

/// What an expense was for.
enum ExpenseCategory {
  accommodation('Accommodation', Icons.hotel_outlined),
  golf('Golf', Icons.golf_course_outlined),
  food('Food & Drink', Icons.restaurant_outlined),
  transport('Transport', Icons.directions_car_outlined),
  other('Other', Icons.receipt_long_outlined);

  const ExpenseCategory(this.label, this.icon);

  /// Display name.
  final String label;

  /// Icon shown beside it.
  final IconData icon;
}

/// How an expense is divided.
enum ExpenseSplitMode { equal, custom }

/// One shared expense.
class TripExpense {
  const TripExpense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.participants,
    this.splitMode = ExpenseSplitMode.equal,
    this.customShares = const <String, double>{},
    this.settled = const <String>{},
  });

  /// Unique identifier within the trip.
  final String id;

  /// What it was (e.g. "Green fees").
  final String title;

  /// What kind of expense it was.
  final ExpenseCategory category;

  /// The total amount.
  final double amount;

  /// The member who paid the bill up front.
  final String paidBy;

  /// When it was incurred.
  final DateTime date;

  /// Everyone it is shared between (normally including [paidBy]).
  final List<String> participants;

  /// Whether the cost is divided equally or by custom amounts.
  final ExpenseSplitMode splitMode;

  /// Each participant's amount when [splitMode] is custom.
  final Map<String, double> customShares;

  /// Participants who have already paid their share back to [paidBy].
  final Set<String> settled;

  /// What [member] owes for this expense (0 if they are not part of it).
  double shareOf(String member) {
    if (!participants.contains(member)) {
      return 0;
    }
    return switch (splitMode) {
      ExpenseSplitMode.equal => amount / participants.length,
      ExpenseSplitMode.custom => customShares[member] ?? 0,
    };
  }

  /// Whether [member]'s share needs no further payment — they paid the
  /// bill themselves, or have been marked as having paid their share.
  bool isSettled(String member) => member == paidBy || settled.contains(member);

  /// The part of [amount] that is covered (the payer's own share plus every
  /// share marked paid).
  double get paidAmount => <String>[
    for (final member in participants)
      if (isSettled(member)) member,
  ].fold<double>(0, (sum, member) => sum + shareOf(member));

  /// The part of [amount] still owed to [paidBy].
  double get outstandingAmount => amount - paidAmount;

  /// A copy with the given fields replaced.
  TripExpense copyWith({
    String? title,
    ExpenseCategory? category,
    double? amount,
    String? paidBy,
    DateTime? date,
    List<String>? participants,
    ExpenseSplitMode? splitMode,
    Map<String, double>? customShares,
    Set<String>? settled,
  }) {
    return TripExpense(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      date: date ?? this.date,
      participants: participants ?? this.participants,
      splitMode: splitMode ?? this.splitMode,
      customShares: customShares ?? this.customShares,
      settled: settled ?? this.settled,
    );
  }
}
