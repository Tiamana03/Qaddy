// Verifies the real app boots through the launch experience: Splash ->
// Introduction -> guest -> "Who's teeing off?" -> the app, and that a second
// launch with the same storage goes straight in. Unlike the other navigation
// tests, this one opens the app on the splash, as `main` does.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';
import 'package:qaddy/main.dart';

import '../../support/memory_document_storage.dart';

class _Phone {
  final session = MemoryDocumentStorage();
  final golfer = MemoryDocumentStorage();
}

Future<void> _launch(WidgetTester tester, _Phone phone) async {
  // What `main` does first: who the golfer is, before any seeded data is read.
  final stored = phone.golfer.read();
  useGolfer(stored == null ? null : decodeGolfer(stored));
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  addTearDown(resetGolferForTests);
  final container = ProviderContainer(
    overrides: <Override>[
      launchLocationProvider.overrideWithValue(AppRoutes.splash),
      sessionStorageProvider.overrideWithValue(phone.session),
      golferStorageProvider.overrideWithValue(phone.golfer),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const QaddyApp()),
  );
  await tester.pump(
    splashReducedMotionDuration + const Duration(milliseconds: 50),
  );
  await tester.pumpAndSettle();
}

Future<void> _firstRun(WidgetTester tester, _Phone phone) async {
  await _launch(tester, phone);
  expect(find.text('Score every round'), findsOneWidget);

  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  expect(find.text('Tee it up'), findsOneWidget);

  await tester.tap(find.text('Continue as guest'));
  await tester.pumpAndSettle();
  expect(find.text("Who's teeing off?"), findsOneWidget);

  await tester.enterText(find.byType(TextField).at(0), 'Amy');
  await tester.ensureVisible(find.text("Let's play"));
  await tester.tap(find.text("Let's play"));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first launch: Splash -> Introduction -> guest -> name -> app', (
    tester,
  ) async {
    final phone = _Phone();

    await _firstRun(tester, phone);

    expect(find.text('YOUR GAME'), findsOneWidget);
    expect(find.text('Amy'), findsWidgets);
    expect(find.text('Tiamana'), findsNothing);
    expect(phone.session.document, contains('"guest":true'));
    expect(decodeGolfer(phone.golfer.document!)!.firstName, 'Amy');
  });

  testWidgets('the second launch goes straight into the app, as Amy', (
    tester,
  ) async {
    final phone = _Phone();
    await _firstRun(tester, phone);

    // Close the app and open it again with what it remembered.
    await tester.pumpWidget(const SizedBox.shrink());
    await _launch(tester, phone);

    expect(find.text('Score every round'), findsNothing);
    expect(find.text("Who's teeing off?"), findsNothing);
    expect(find.text('YOUR GAME'), findsOneWidget);
    expect(find.text('Amy'), findsWidgets);
  });

  testWidgets('leaving before saying who you are asks again next time', (
    tester,
  ) async {
    final phone = _Phone();
    await _launch(tester, phone);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text("Who's teeing off?"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await _launch(tester, phone);

    expect(find.text('Score every round'), findsNothing);
    expect(find.text("Who's teeing off?"), findsOneWidget);
  });
}
