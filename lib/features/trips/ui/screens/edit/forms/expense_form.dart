/// Add or edit an expense: who paid, who shares it, and how it is split.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The expense form. Pass [expense] to edit one; omit it to add.
class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({
    required this.tripId,
    required this.fallbackRoute,
    this.expense,
    super.key,
  });

  /// The trip the expense belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The expense being edited, or `null` when adding.
  final TripExpense? expense;

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late ExpenseCategory _category;
  late String _paidBy;
  late DateTime _date;
  late ExpenseSplitMode _mode;
  late Set<String> _participants;
  final Map<String, TextEditingController> _shares =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    final plan = ref.read(tripPlanProvider(widget.tripId));
    final trip = ref.read(tripProvider(widget.tripId))!;
    _title = TextEditingController(text: expense?.title ?? '');
    _amount = TextEditingController(
      text: expense == null ? '' : _plain(expense.amount),
    );
    _category = expense?.category ?? ExpenseCategory.other;
    _paidBy = expense?.paidBy ?? currentUserName;
    _date = expense?.date ?? trip.startDate;
    _mode = expense?.splitMode ?? ExpenseSplitMode.equal;
    _participants = expense == null
        ? <String>{for (final m in plan.confirmedMembers) m.displayName}
        : expense.participants.toSet();
    for (final name in expense?.customShares.keys ?? const <String>[]) {
      _shares[name] = TextEditingController(
        text: _plain(expense!.customShares[name]!),
      );
    }
  }

  static String _plain(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    for (final controller in _shares.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double? get _amountValue => parseAmount(_amount.text);
  bool get _amountOk => (_amountValue ?? 0) > 0;

  TextEditingController _shareField(String name) =>
      _shares.putIfAbsent(name, TextEditingController.new);

  double get _customTotal => <double>[
    for (final name in _participants) parseAmount(_shareField(name).text) ?? 0,
  ].fold<double>(0, (sum, value) => sum + value);

  bool get _splitOk {
    if (_participants.isEmpty) {
      return false;
    }
    if (_mode == ExpenseSplitMode.equal) {
      return true;
    }
    return ((_amountValue ?? 0) - _customTotal).abs() < 0.01;
  }

  bool get _valid => _title.text.trim().isNotEmpty && _amountOk && _splitOk;

  void _save() {
    final plan = ref.read(tripPlanProvider(widget.tripId));
    final order = plan.members.map((m) => m.displayName).toList();
    final participants = <String>[
      for (final name in order)
        if (_participants.contains(name)) name,
    ];
    final built = TripExpense(
      id:
          widget.expense?.id ??
          ref.read(tripsProvider.notifier).newId('expense'),
      title: _title.text.trim(),
      category: _category,
      amount: _amountValue!,
      paidBy: _paidBy,
      date: _date,
      participants: participants,
      splitMode: _mode,
      customShares: _mode == ExpenseSplitMode.custom
          ? <String, double>{
              for (final name in participants)
                name: parseAmount(_shareField(name).text) ?? 0,
            }
          : const <String, double>{},
      // Keep payments already recorded for people who are still sharing it.
      settled: <String>{
        for (final name in widget.expense?.settled ?? const <String>{})
          if (participants.contains(name)) name,
      },
    );
    final existing = widget.expense != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            expenses: existing
                ? <TripExpense>[
                    for (final e in plan.expenses)
                      if (e.id == built.id) built else e,
                  ]
                : <TripExpense>[...plan.expenses, built],
          ),
          log: existing
              ? 'Updated expense: ${built.title}'
              : 'Added expense: ${built.title} '
                    '(${formatMoney(built.amount)})',
        );
  }

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final options = memberChipOptions(plan);
    // Whoever paid is always among the choices, even if no longer going.
    if (!options.any((option) => option.value == _paidBy)) {
      options.add(QaddyChipOption<String>(value: _paidBy, label: _paidBy));
    }
    final people = _participants.length;
    final equalShare = people == 0 ? 0.0 : (_amountValue ?? 0) / people;

    return TripFormPage(
      title: expense == null ? 'Add expense' : 'Edit expense',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _valid,
      onSave: _save,
      onDelete: expense == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    expenses: <TripExpense>[
                      for (final e in plan.expenses)
                        if (e.id != expense.id) e,
                    ],
                  ),
                  log: 'Removed expense: ${expense.title}',
                ),
      deleteTitle: 'Delete this expense?',
      deleteMessage: 'Everyone’s balances will update.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _title,
          label: 'What was it for?',
          hintText: 'Dinner at Rosetta',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          errorText: submitted && _title.text.trim().isEmpty
              ? 'Describe the expense'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        FieldPair(
          left: QaddyTextField(
            controller: _amount,
            label: 'Amount',
            hintText: r'$240',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: submitted && !_amountOk ? 'Enter an amount' : null,
            onChanged: (_) => setState(() {}),
          ),
          right: QaddyDateField(
            label: 'Date',
            value: _date,
            onChanged: (date) => setState(() => _date = date),
          ),
        ),
        const FormLabel('Category'),
        QaddyChipSelector<ExpenseCategory>(
          options: <QaddyChipOption<ExpenseCategory>>[
            for (final category in ExpenseCategory.values)
              QaddyChipOption(
                value: category,
                label: category.label,
                icon: category.icon,
              ),
          ],
          selected: _category,
          onChanged: (value) => setState(() => _category = value),
        ),
        const FormLabel('Paid by'),
        QaddyChipSelector<String>(
          options: options,
          selected: _paidBy,
          onChanged: (value) => setState(() => _paidBy = value),
        ),
        const FormLabel('Split'),
        QaddySegmentedControl<ExpenseSplitMode>(
          segments: const <QaddySegment<ExpenseSplitMode>>[
            QaddySegment(value: ExpenseSplitMode.equal, label: 'Equally'),
            QaddySegment(value: ExpenseSplitMode.custom, label: 'Custom'),
          ],
          selected: _mode,
          onChanged: (value) => setState(() => _mode = value),
        ),
        const FormLabel('Shared between'),
        QaddyMultiChipSelector<String>(
          options: options,
          selected: _participants,
          onChanged: (value) => setState(() => _participants = value),
        ),
        SizedBox(height: spacing.sm),
        if (submitted && _participants.isEmpty)
          Text(
            'Pick at least one person to share it with.',
            style: typography.small.copyWith(color: colours.error),
          )
        else if (_mode == ExpenseSplitMode.equal && people > 0)
          Text(
            '${formatMoney(equalShare)} each',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
        if (_mode == ExpenseSplitMode.custom) ...<Widget>[
          for (final name in options.map((o) => o.value))
            if (_participants.contains(name)) ...<Widget>[
              SizedBox(height: spacing.sm),
              QaddyTextField(
                controller: _shareField(name),
                label: '$name pays',
                hintText: r'$0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          SizedBox(height: spacing.sm),
          Text(
            'Shares add up to ${formatMoney(_customTotal)} of '
            '${formatMoney(_amountValue ?? 0)}',
            style: typography.small.copyWith(
              color: submitted && !_splitOk
                  ? colours.error
                  : colours.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
