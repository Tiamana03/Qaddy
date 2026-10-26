import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';

TripExpense _expense({
  String id = 'e',
  double amount = 300,
  String paidBy = 'Ben',
  List<String> participants = const <String>['Ben', 'Luke', 'Josh'],
  Set<String> settled = const <String>{},
  ExpenseSplitMode mode = ExpenseSplitMode.equal,
  Map<String, double> custom = const <String, double>{},
  DateTime? date,
}) => TripExpense(
  id: id,
  title: id,
  category: ExpenseCategory.other,
  amount: amount,
  paidBy: paidBy,
  date: date ?? DateTime(2026, 11),
  participants: participants,
  settled: settled,
  splitMode: mode,
  customShares: custom,
);

void main() {
  group('summariseExpenses', () {
    test('counts the payer and settled shares as paid', () {
      final summary = summariseExpenses(<TripExpense>[
        _expense(settled: const <String>{'Luke'}),
      ]);

      expect(summary.total, 300);
      expect(summary.paid, 200);
      expect(summary.outstanding, 100);
      expect(summary.isSettled, isFalse);
    });

    test('is settled once every share is paid', () {
      final summary = summariseExpenses(<TripExpense>[
        _expense(settled: const <String>{'Luke', 'Josh'}),
      ]);

      expect(summary.isSettled, isTrue);
      expect(summary.paidFraction, 1);
    });

    test('is not settled when nothing has been spent', () {
      expect(summariseExpenses(const <TripExpense>[]).isSettled, isFalse);
      expect(summariseExpenses(const <TripExpense>[]).paidFraction, 0);
    });

    test('matches the seeded Melbourne trip', () {
      final summary = summariseExpenses(melbourneGolfWeekendPlan.expenses);

      expect(summary.total, 11500);
      expect(summary.outstanding, greaterThan(0));
    });
  });

  group('whoOwesWho', () {
    test('lists each unsettled share against the payer', () {
      final debts = whoOwesWho(<TripExpense>[_expense()]);

      expect(debts, hasLength(2));
      expect(debts.every((debt) => debt.to == 'Ben'), isTrue);
      expect(debts.every((debt) => debt.amount == 100), isTrue);
    });

    test('nets opposite debts between the same two members', () {
      final debts = whoOwesWho(<TripExpense>[
        _expense(
          id: 'a',
          amount: 200,
          participants: const <String>['Ben', 'Luke'],
        ),
        _expense(
          id: 'b',
          amount: 60,
          paidBy: 'Luke',
          participants: const <String>['Ben', 'Luke'],
        ),
      ]);

      expect(debts, hasLength(1));
      expect(debts.single.from, 'Luke');
      expect(debts.single.to, 'Ben');
      expect(debts.single.amount, 70);
    });

    test('honours custom splits and skips settled shares', () {
      final debts = whoOwesWho(<TripExpense>[
        _expense(
          mode: ExpenseSplitMode.custom,
          custom: const <String, double>{'Ben': 100, 'Luke': 50, 'Josh': 150},
          settled: const <String>{'Josh'},
        ),
      ]);

      expect(debts, hasLength(1));
      expect(debts.single.from, 'Luke');
      expect(debts.single.amount, 50);
    });

    test('is empty when everything is settled', () {
      final debts = whoOwesWho(<TripExpense>[
        _expense(settled: const <String>{'Luke', 'Josh'}),
      ]);

      expect(debts, isEmpty);
    });
  });

  group('upcomingPaymentFor', () {
    test('is the earliest unsettled share the member owes', () {
      final payment = upcomingPaymentFor(<TripExpense>[
        _expense(id: 'later', date: DateTime(2026, 11, 20)),
        _expense(id: 'sooner', date: DateTime(2026, 11, 2)),
      ], 'Luke');

      expect(payment!.forExpense, 'sooner');
      expect(payment.to, 'Ben');
      expect(payment.amount, 100);
    });

    test('is null for the payer and for a member who has paid', () {
      final expenses = <TripExpense>[
        _expense(settled: const <String>{'Luke'}),
      ];

      expect(upcomingPaymentFor(expenses, 'Ben'), isNull);
      expect(upcomingPaymentFor(expenses, 'Luke'), isNull);
    });
  });

  group('formatMoney', () {
    test('uses thousands separators and drops whole cents', () {
      expect(formatMoney(11500), r'$11,500');
      expect(formatMoney(0), r'$0');
      expect(formatMoney(12.5), r'$12.50');
      expect(formatMoney(-40), r'-$40');
    });
  });
}
