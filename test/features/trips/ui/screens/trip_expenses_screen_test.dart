import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_expenses_screen.dart';

void main() {
  testWidgets('shows budget, shared expenses, payments and balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripExpensesScreen()),
    );

    expect(find.text(r'$4520'), findsOneWidget);
    expect(find.text('Accommodation'), findsOneWidget);
    expect(find.text(r'$2100'), findsOneWidget);
    expect(find.text('Tiamana'), findsOneWidget);
    expect(find.text(r'$600'), findsOneWidget);
    expect(find.text('Outstanding Balance'), findsOneWidget);
    expect(find.text(r'$0'), findsOneWidget);
  });
}
