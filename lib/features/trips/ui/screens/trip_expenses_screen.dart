/// Qaddy's Expenses screen — what the trip costs and who owes what.
///
/// See `docs/features/trips-feature-integration.md`'s "Expenses" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Expenses (route `/trips/:tripId/expenses`).
class TripExpensesScreen extends ConsumerWidget {
  const TripExpensesScreen({required this.tripId, super.key});

  /// The trip whose expenses are shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final summary = summariseExpenses(plan.expenses);
    final debts = whoOwesWho(plan.expenses);
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Trip Cost',
              child: Column(
                children: <Widget>[
                  QaddyInfoRow(
                    label: 'Total',
                    value: formatMoney(summary.total),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(label: 'Paid', value: formatMoney(summary.paid)),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Outstanding',
                    value: formatMoney(summary.outstanding),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Expenses',
              child: Column(
                children: <Widget>[
                  for (final (index, expense)
                      in plan.expenses.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: expense.title,
                      value: formatMoney(expense.amount),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Who Owes Who',
              child: Column(
                children: <Widget>[
                  for (final (index, debt) in debts.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: '${debt.from} → ${debt.to}',
                      value: formatMoney(debt.amount),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
