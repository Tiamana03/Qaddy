import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_field.dart';

void main() {
  testWidgets('shows a clear button only once text is entered', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: Scaffold(body: QaddySearchField(controller: controller)),
      ),
    );

    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pump();

    expect(find.byTooltip('Clear search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
