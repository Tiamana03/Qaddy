import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';

import '../../../../support/launch_harness.dart';

Future<LaunchHarness> _pump(WidgetTester tester) async {
  final h = await pumpLaunch(tester, initialLocation: AppRoutes.signUp);
  await tester.pumpAndSettle();
  return h;
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('invites the golfer to join and is upfront about accounts', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Join Qaddy'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Choose a password'), findsOneWidget);
    expect(
      find.textContaining('Accounts open after the soft launch'),
      findsOneWidget,
    );
  });

  testWidgets('says what is missing, field by field', (tester) async {
    await _pump(tester);

    await _tap(tester, 'Create account');

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Choose a password'), findsWidgets);
  });

  testWidgets('wants a password worth having', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Tom');
    await tester.enterText(find.byType(TextField).at(1), 'tom@club.com');
    await tester.enterText(find.byType(TextField).at(2), 'short');

    await _tap(tester, 'Create account');

    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(find.text('Accounts open after the soft launch'), findsNothing);
  });

  testWidgets('a valid sign-up is told the truth and offered the guest way', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Tom');
    await tester.enterText(find.byType(TextField).at(1), 'tom@club.com');
    await tester.enterText(find.byType(TextField).at(2), 'longenough1');

    await _tap(tester, 'Create account');
    expect(find.text('Accounts open after the soft launch'), findsOneWidget);
    expect(h.container.read(sessionProvider).isGuest, isFalse);

    await tester.tap(find.text('Continue as guest').last);
    await tester.pumpAndSettle();

    expect(h.location, AppRoutes.home);
    expect(h.container.read(sessionProvider).isGuest, isTrue);
  });

  testWidgets('Continue as guest needs no form', (tester) async {
    final h = await _pump(tester);

    await _tap(tester, 'Continue as guest');

    expect(h.location, AppRoutes.home);
  });

  testWidgets('links to Sign in', (tester) async {
    final h = await _pump(tester);

    await _tap(tester, 'Already have an account? Sign in');

    expect(h.location, AppRoutes.login);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
