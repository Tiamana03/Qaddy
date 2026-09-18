import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/responsive/responsive_builder.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/responsive/responsive_max_width.dart';
import 'package:qaddy/core/responsive/responsive_spacing.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';

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
  testWidgets('ResponsiveBuilder falls back mobile -> tablet -> desktop', (
    tester,
  ) async {
    Widget builder() => ResponsiveBuilder(
      mobile: (_) => const Text('mobile'),
      desktop: (_) => const Text('desktop'),
    );

    await _pumpAtWidth(tester, 300, builder());
    expect(find.text('mobile'), findsOneWidget);

    await _pumpAtWidth(tester, 700, builder());
    expect(find.text('mobile'), findsOneWidget, reason: 'no tablet builder');

    await _pumpAtWidth(tester, 1200, builder());
    expect(find.text('desktop'), findsOneWidget);
  });

  testWidgets('ResponsiveMaxWidth constrains and centres only on desktop', (
    tester,
  ) async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox &&
          widget.constraints.maxWidth ==
              QaddyBreakpoints.desktopMaxContentWidth,
    );

    await _pumpAtWidth(
      tester,
      300,
      const ResponsiveMaxWidth(child: SizedBox(width: 2000, height: 10)),
    );
    expect(finder, findsNothing);

    await _pumpAtWidth(
      tester,
      1200,
      const ResponsiveMaxWidth(child: SizedBox(width: 2000, height: 10)),
    );
    expect(finder, findsOneWidget);
  });

  testWidgets('ResponsiveSpacing.vertical renders a SizedBox with height', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400, const ResponsiveSpacing.vertical());
    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, isNotNull);
    expect(box.width, isNull);
  });

  testWidgets('ResponsiveContextExtensions delegate to QaddyBreakpoints', (
    tester,
  ) async {
    late BuildContext capturedContext;
    await _pumpAtWidth(
      tester,
      1200,
      Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    );

    expect(capturedContext.isDesktop, isTrue);
    expect(capturedContext.isMobile, isFalse);
    expect(capturedContext.screenWidth, 1200);
  });
}
