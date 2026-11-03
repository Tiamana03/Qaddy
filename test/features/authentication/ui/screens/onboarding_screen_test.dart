import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';

import '../../../../support/launch_harness.dart';

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pages through the pitches to the way in', (tester) async {
    await pumpLaunch(tester);

    expect(find.text('Score every round'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await _next(tester);
    expect(find.text('Plan the golf trip'), findsOneWidget);

    await _next(tester);
    expect(find.text('Play with your mates'), findsOneWidget);

    await _next(tester);
    expect(find.text('Tee it up'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('Skip jumps to the way in', (tester) async {
    await pumpLaunch(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Tee it up'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
  });

  testWidgets('says plainly that accounts are not open yet', (tester) async {
    await pumpLaunch(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Accounts open after the soft launch'),
      findsOneWidget,
    );
  });

  testWidgets('reaching the way in remembers the introduction was seen', (
    tester,
  ) async {
    final h = await pumpLaunch(tester);
    expect(h.container.read(sessionProvider).onboardingComplete, isFalse);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(h.container.read(sessionProvider).onboardingComplete, isTrue);
    expect(h.container.read(sessionProvider).isGuest, isFalse);
    expect(h.storage.document, contains('"onboardingComplete":true'));
  });

  testWidgets('Continue as guest goes into the app as a guest', (tester) async {
    final h = await pumpLaunch(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(h.location, AppRoutes.home);
    expect(h.container.read(sessionProvider).isGuest, isTrue);
  });

  testWidgets('Sign in and Create an account open their screens', (
    tester,
  ) async {
    final h = await pumpLaunch(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(h.location, AppRoutes.login);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(h.location, AppRoutes.onboarding);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(h.location, AppRoutes.signUp);
  });

  testWidgets('lays out on a small phone and a tablet', (tester) async {
    await pumpLaunch(tester, size: const Size(320, 568));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await pumpLaunch(tester, size: const Size(820, 1180));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('animated, it is still fine to swipe through', (tester) async {
    await pumpLaunch(tester, reduceMotion: false);

    await tester.drag(find.text('Score every round'), const Offset(-400, 0));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Plan the golf trip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
