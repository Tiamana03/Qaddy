/// Qaddy's Expenses screen.
///
/// See `docs/features/trips-feature-integration.md`'s "Expenses" section
/// ("Displays: Trip Budget, Shared Expenses, Individual Payments,
/// Outstanding Balances"). Release 1 displays expenses only — no
/// settlement calculations are performed; `outstandingBalance` is a
/// sourced placeholder value (see `trip_expense.dart`).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

String _money(double amount) => '\$${amount.toStringAsFixed(0)}';

/// Expenses (route `/trips/expenses`).
class TripExpensesScreen extends StatelessWidget {
  const TripExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Trip Budget',
              child: TripInfoRow(
                label: 'Estimated Total',
                value: _money(melbourneGolfWeekendEstimatedTotal),
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Shared Expenses',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, item)
                      in melbourneGolfWeekendExpenses.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(label: item.title, value: _money(item.amount)),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Individual Payments',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, payment)
                      in melbourneGolfWeekendPayments.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    TripInfoRow(
                      label: payment.playerName,
                      value: _money(payment.amountPaid),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Outstanding Balance',
              child: TripInfoRow(
                label: 'Balance',
                value: _money(melbourneGolfWeekendOutstandingBalance),
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
