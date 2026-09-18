import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';

void main() {
  testWidgets('boundaries resolve to exactly one breakpoint', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;

    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    tester.view.physicalSize = const Size(599, 800);
    await tester.pump();
    expect(QaddyBreakpoints.isMobile(capturedContext), isTrue);
    expect(QaddyBreakpoints.isTablet(capturedContext), isFalse);
    expect(QaddyBreakpoints.isDesktop(capturedContext), isFalse);

    tester.view.physicalSize = const Size(600, 800);
    await tester.pump();
    expect(QaddyBreakpoints.isMobile(capturedContext), isFalse);
    expect(QaddyBreakpoints.isTablet(capturedContext), isTrue);

    tester.view.physicalSize = const Size(1023, 800);
    await tester.pump();
    expect(QaddyBreakpoints.isTablet(capturedContext), isTrue);
    expect(QaddyBreakpoints.isDesktop(capturedContext), isFalse);

    tester.view.physicalSize = const Size(1024, 800);
    await tester.pump();
    expect(QaddyBreakpoints.isTablet(capturedContext), isFalse);
    expect(QaddyBreakpoints.isDesktop(capturedContext), isTrue);
  });
}
