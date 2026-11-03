// Verifies the real app boots through the launch experience: Splash ->
// Introduction -> a way in -> the app, and that a second launch with the same
// storage goes straight in. Unlike the other navigation tests, this one opens
// the app on the splash, as `main` does.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';
import 'package:qaddy/main.dart';

import '../../support/memory_document_storage.dart';

Future<void> _launch(WidgetTester tester, MemoryDocumentStorage storage) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final container = ProviderContainer(
    overrides: <Override>[
      launchLocationProvider.overrideWithValue(AppRoutes.splash),
      sessionStorageProvider.overrideWithValue(storage),
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

void main() {
  testWidgets('first launch: Splash -> Introduction -> guest -> the app', (
    tester,
  ) async {
    final storage = MemoryDocumentStorage();
    await _launch(tester, storage);

    expect(find.text('Score every round'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Tee it up'), findsOneWidget);

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR GAME'), findsOneWidget);
    expect(storage.document, contains('"guest":true'));
  });

  testWidgets('the second launch goes straight into the app', (tester) async {
    final storage = MemoryDocumentStorage();
    await _launch(tester, storage);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    // Close the app and open it again with what it remembered.
    await tester.pumpWidget(const SizedBox.shrink());
    await _launch(tester, storage);

    expect(find.text('Score every round'), findsNothing);
    expect(find.text('YOUR GAME'), findsOneWidget);
  });

  testWidgets('seeing the introduction is enough to skip it next time', (
    tester,
  ) async {
    final storage = MemoryDocumentStorage();
    await _launch(tester, storage);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await _launch(tester, storage);

    expect(find.text('YOUR GAME'), findsOneWidget);
  });
}
