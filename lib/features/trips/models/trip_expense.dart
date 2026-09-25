/// A Trip's shared expenses — see `docs/architecture/trip-data-model.md`'s
/// "Expenses" section and placeholder-trip-data.md's "Expenses" and
/// "Individual Payments" sections.
///
/// Release 1 displays expenses only — no automatic settlement calculations
/// are performed; `outstandingBalance` is a sourced placeholder value, not
/// a derived one.
library;

/// One shared expense category (e.g. "Accommodation", "$2,100").
class TripExpenseItem {
  const TripExpenseItem({required this.title, required this.amount});

  /// The expense category.
  final String title;

  /// The amount spent.
  final double amount;
}

/// One participant's contribution toward the trip's shared expenses.
class TripPayment {
  const TripPayment({required this.playerName, required this.amountPaid});

  /// The paying player's name.
  final String playerName;

  /// The amount they've paid.
  final double amountPaid;
}
