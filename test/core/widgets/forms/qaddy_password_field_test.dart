import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';

void main() {
  testWidgets('obscures by default and reveals when the icon is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Scaffold(body: QaddyPasswordField()),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    final revealedField = tester.widget<TextField>(find.byType(TextField));
    expect(revealedField.obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
