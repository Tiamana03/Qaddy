import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';

/// Opens the dialog from a button and reports what it resolved to.
Future<bool? Function()> _open(
  WidgetTester tester, {
  bool destructive = false,
  IconData? icon,
}) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: QaddyTheme.dark,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                result = await showQaddyConfirm(
                  context,
                  title: 'Delete this trip?',
                  message: 'It will be gone for good.',
                  confirmLabel: 'Delete trip',
                  destructive: destructive,
                  icon: icon,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => result;
}

BoxDecoration _medallion(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .ancestor(of: find.byType(Icon), matching: find.byType(Container))
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  _noticeMain();
  testWidgets('shows a medallion, the title, the message and both actions', (
    tester,
  ) async {
    await _open(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Delete this trip?'), findsOneWidget);
    expect(find.text('It will be gone for good.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete trip'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
  });

  testWidgets('a routine confirmation is green with a question mark', (
    tester,
  ) async {
    await _open(tester);

    expect(_medallion(tester).color, QaddyColours.dark.secondary);
  });

  testWidgets('a destructive one is the error colour with a bin', (
    tester,
  ) async {
    await _open(tester, destructive: true);

    expect(_medallion(tester).color, QaddyColours.dark.error);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('the icon can be chosen', (tester) async {
    await _open(tester, icon: Icons.logout);

    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('confirming resolves true, Cancel resolves false', (
    tester,
  ) async {
    var result = await _open(tester);
    await tester.tap(find.text('Delete trip'));
    await tester.pumpAndSettle();
    expect(result(), isTrue);

    result = await _open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result(), isFalse);
  });

  testWidgets('dismissing it counts as no', (tester) async {
    final result = await _open(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(result(), isFalse);
  });
}

void _noticeMain() {
  testWidgets('a notice has a medallion, copy and one action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showQaddyNotice(
                context,
                title: 'Saved',
                message: 'Everything is where you left it.',
                actionLabel: 'Okay',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a notice with no action cannot be dismissed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showQaddyNotice(
                context,
                title: 'Fresh start',
                message: 'Close Qaddy and open it again.',
                dismissible: false,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
  });
}
