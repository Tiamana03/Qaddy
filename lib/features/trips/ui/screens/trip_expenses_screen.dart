/// Qaddy's Expenses screen — what the trip costs, how much is paid, who owes
/// whom, and every expense so far.
///
/// See `docs/features/trips-feature-integration.md`'s "Expenses" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
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
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final summary = summariseExpenses(plan.expenses);
    final debts = whoOwesWho(plan.expenses);
    final youOwe = debts
        .where((debt) => debt.from == currentUserName)
        .fold<double>(0, (sum, debt) => sum + debt.amount);
    final owedToYou = debts
        .where((debt) => debt.to == currentUserName)
        .fold<double>(0, (sum, debt) => sum + debt.amount);
    final history = <TripExpense>[...plan.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.expenses.slug,
      'new',
    );

    Future<void> markPaid(TripDebt debt) async {
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Mark as paid?',
        message:
            '${debt.from} has paid ${debt.to} ${formatMoney(debt.amount)}. '
            'Their shared expenses will be settled.',
        confirmLabel: 'Mark Paid',
      );
      if (confirmed) {
        QaddyHaptics.success();
        ref
            .read(tripsProvider.notifier)
            .settleDebt(tripId, from: debt.from, to: debt.to);
      }
    }

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Expense',
            onPressed: () => context.push(addRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            if (plan.expenses.isEmpty)
              QaddyEmptyState(
                icon: Icons.payments_outlined,
                title: 'No expenses yet',
                message:
                    'Log the villa, green fees and dinners as they happen — '
                    'Qaddy works out who owes who.',
                actionLabel: 'Add Expense',
                onAction: () => context.push(addRoute),
              )
            else ...<Widget>[
              _CostCard(summary: summary),
              SizedBox(height: spacing.cardGap),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PositionTile(
                      label: 'You owe',
                      amount: youOwe,
                      colour: youOwe > 0
                          ? colours.warning
                          : colours.textPrimary,
                    ),
                  ),
                  SizedBox(width: spacing.cardGap),
                  Expanded(
                    child: _PositionTile(
                      label: 'You are owed',
                      amount: owedToYou,
                      colour: owedToYou > 0
                          ? colours.success
                          : colours.textPrimary,
                    ),
                  ),
                ],
              ),
              const DetailSectionTitle('Who Owes Who'),
              if (debts.isEmpty)
                QaddyCard(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.check_circle_outline, color: colours.success),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Text(
                          'All square — nobody owes anybody.',
                          style: typography.body.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                QaddyCard(
                  child: Column(
                    children: <Widget>[
                      for (final debt in debts)
                        _DebtRow(debt: debt, onMarkPaid: () => markPaid(debt)),
                    ],
                  ),
                ),
              const DetailSectionTitle('Expense History'),
              for (final expense in history) ...<Widget>[
                _ExpenseRow(tripId: tripId, expense: expense),
                SizedBox(height: spacing.sm),
              ],
              SizedBox(height: spacing.md),
              QaddyGoldButton(
                label: 'Add Expense',
                onPressed: () => context.push(addRoute),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.summary});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Trip Cost',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  formatMoney(summary.total),
                  style: typography.h1.copyWith(color: colours.textPrimary),
                ),
              ),
              if (summary.isSettled)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colours.surface2,
                    borderRadius: BorderRadius.circular(radius.large),
                    border: Border.all(color: colours.success),
                  ),
                  child: Text(
                    'All settled',
                    style: typography.small.copyWith(color: colours.success),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Semantics(
            label:
                '${(summary.paidFraction * 100).round()} percent of the trip '
                'cost is paid',
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius.large),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: summary.paidFraction),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: colours.surface2,
                  color: colours.accent,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: FactRow(label: 'Paid', value: formatMoney(summary.paid)),
              ),
            ],
          ),
          FactRow(
            label: 'Outstanding',
            value: formatMoney(summary.outstanding),
          ),
        ],
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({
    required this.label,
    required this.amount,
    required this.colour,
  });

  final String label;
  final double amount;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          Text(
            formatMoney(amount),
            style: typography.h3.copyWith(color: colour),
          ),
        ],
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.debt, required this.onMarkPaid});

  final TripDebt debt;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${debt.from} owes ${debt.to}',
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
                Text(
                  formatMoney(debt.amount),
                  style: typography.h4.copyWith(color: colours.accent),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onMarkPaid,
            child: Text('Mark Paid', semanticsLabel: 'Mark ${debt.from} paid'),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.tripId, required this.expense});

  final String tripId;
  final TripExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final outstanding = expense.outstandingAmount;
    final split = expense.splitMode == ExpenseSplitMode.equal
        ? 'split equally'
        : 'custom split';

    return QaddyCard(
      onTap: () => context.push(
        AppRoutes.tripEditItem(
          tripId,
          TripEditSection.expenses.slug,
          expense.id,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(expense.category.icon, color: colours.accent),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  expense.title,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
                Text(
                  'Paid by ${expense.paidBy} · '
                  '${expense.date.toShortWeekdayAndDate()} · $split',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                formatMoney(expense.amount),
                style: typography.body.copyWith(color: colours.textPrimary),
              ),
              Text(
                outstanding < 0.005
                    ? 'Settled'
                    : '${formatMoney(outstanding)} to pay',
                style: typography.small.copyWith(
                  color: outstanding < 0.005
                      ? colours.success
                      : colours.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
