// Verifies Sprint 1.5's shared scaffold: SafeArea, responsive padding/max
// width, background colour, and its optional AppBar/bottom nav slots.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

Future<void> _pumpAtWidth(
  WidgetTester tester,
  double width,
  Widget child,
) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  await tester.pumpWidget(MaterialApp(theme: QaddyTheme.dark, home: child));
}

void main() {
  testWidgets('renders body content inside a SafeArea', (tester) async {
    await _pumpAtWidth(tester, 400, const QaddyScaffold(body: Text('content')));

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('uses QaddyColours.background for the scaffold', (tester) async {
    await _pumpAtWidth(tester, 400, const QaddyScaffold(body: SizedBox()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final colours = QaddyTheme.dark.extension<QaddyColours>()!;
    expect(scaffold.backgroundColor, colours.background);
  });

  testWidgets('constrains content width only on desktop', (tester) async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox &&
          widget.constraints.maxWidth ==
              QaddyBreakpoints.desktopMaxContentWidth,
    );

    await _pumpAtWidth(
      tester,
      400,
      const QaddyScaffold(body: SizedBox(width: 2000, height: 10)),
    );
    expect(finder, findsNothing);

    await _pumpAtWidth(
      tester,
      1200,
      const QaddyScaffold(body: SizedBox(width: 2000, height: 10)),
    );
    expect(finder, findsOneWidget);
  });

  testWidgets('wires optional appBar and bottomNavigationBar through', (
    tester,
  ) async {
    await _pumpAtWidth(
      tester,
      400,
      QaddyScaffold(
        appBar: AppBar(title: const Text('title')),
        body: const SizedBox(),
        bottomNavigationBar: const Text('bottom nav'),
      ),
    );

    expect(find.text('title'), findsOneWidget);
    expect(find.text('bottom nav'), findsOneWidget);
  });
}
