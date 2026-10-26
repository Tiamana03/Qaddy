import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';

Future<void> _pump(
  WidgetTester tester, {
  required ValueChanged<DateTime> onChanged,
  DateTime? value,
  DateTime? firstDate,
}) => tester.pumpWidget(
  MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(
      body: QaddyDateField(
        label: 'End Date',
        value: value,
        firstDate: firstDate,
        onChanged: onChanged,
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the label until a date is chosen', (tester) async {
    await _pump(tester, onChanged: (_) {});

    expect(find.text('End Date'), findsOneWidget);
  });

  testWidgets('shows the chosen date', (tester) async {
    await _pump(tester, value: DateTime(2026, 11, 28), onChanged: (_) {});

    expect(find.text('28 Nov 2026'), findsOneWidget);
  });

  testWidgets('opens on the earliest date when today is before the range', (
    tester,
  ) async {
    final first = DateTime.now().add(const Duration(days: 40));
    DateTime? picked;
    await _pump(tester, firstDate: first, onChanged: (date) => picked = date);

    await tester.tap(find.byType(QaddyDateField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(picked, isNotNull);
    expect(
      picked!.isBefore(DateTime(first.year, first.month, first.day)),
      isFalse,
    );
  });
}
