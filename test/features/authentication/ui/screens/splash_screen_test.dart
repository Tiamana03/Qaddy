import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/authentication/models/session.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';

import '../../../../support/launch_harness.dart';
import '../../../../support/memory_document_storage.dart';

void main() {
  testWidgets('shows the mark, the name and the promise', (tester) async {
    await pumpLaunch(
      tester,
      initialLocation: AppRoutes.splash,
      reduceMotion: false,
    );
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('Qaddy'), findsOneWidget);
    expect(find.text("The golfer's ecosystem"), findsOneWidget);
    expect(find.bySemanticsLabel('Qaddy'), findsWidgets);

    // Let the splash finish so no timer is left running.
    await tester.pump(splashDuration);
  });

  testWidgets('a first-time golfer goes on to the introduction', (
    tester,
  ) async {
    final h = await pumpLaunch(
      tester,
      initialLocation: AppRoutes.splash,
      reduceMotion: false,
    );

    await tester.pump(splashDuration + const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 500));

    expect(h.location, AppRoutes.onboarding);
    expect(find.text('Score every round'), findsOneWidget);
  });

  testWidgets('a returning golfer goes straight into the app', (tester) async {
    final storage = MemoryDocumentStorage(
      encodeSession(const AuthSession(onboardingComplete: true, isGuest: true)),
    );
    final h = await pumpLaunch(
      tester,
      initialLocation: AppRoutes.splash,
      storage: storage,
      reduceMotion: false,
    );

    await tester.pump(splashDuration + const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 500));

    expect(h.location, AppRoutes.home);
    expect(find.text('The app'), findsOneWidget);
  });

  testWidgets('with reduced motion the splash is brief', (tester) async {
    final h = await pumpLaunch(tester, initialLocation: AppRoutes.splash);

    await tester.pump(
      splashReducedMotionDuration + const Duration(milliseconds: 50),
    );
    await tester.pumpAndSettle();

    expect(h.location, AppRoutes.onboarding);
  });

  testWidgets('leaving early cancels the wait cleanly', (tester) async {
    await pumpLaunch(tester, initialLocation: AppRoutes.splash);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(tester.takeException(), isNull);
  });
}
