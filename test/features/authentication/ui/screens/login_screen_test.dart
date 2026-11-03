import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';

import '../../../../support/launch_harness.dart';

Future<LaunchHarness> _pump(WidgetTester tester, {Size? size}) async {
  final h = await pumpLaunch(
    tester,
    initialLocation: AppRoutes.login,
    size: size ?? const Size(400, 800),
  );
  await tester.pumpAndSettle();
  return h;
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('welcomes the golfer back and is upfront about accounts', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(QaddyPasswordField), findsOneWidget);
    expect(find.text('Full Name'), findsNothing);
    expect(
      find.textContaining('Accounts open after the soft launch'),
      findsOneWidget,
    );
  });

  testWidgets('checks the fields before saying anything else', (tester) async {
    await _pump(tester);
    expect(find.text('Enter your email address'), findsNothing);

    await _tap(tester, 'Sign in');

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Accounts open after the soft launch'), findsNothing);
  });

  testWidgets('catches an email that is not one', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'tom');
    await _tap(tester, 'Sign in');

    expect(find.text('That does not look like an email'), findsOneWidget);
  });

  testWidgets('a valid sign-in is told the truth, not waved through', (
    tester,
  ) async {
    final h = await _pump(tester);

    await tester.enterText(find.byType(TextField).at(0), 'tom@club.com');
    await tester.enterText(find.byType(TextField).at(1), 'hunter2!');
    await _tap(tester, 'Sign in');

    expect(find.text('Accounts open after the soft launch'), findsOneWidget);
    expect(
      find.textContaining('Nothing you typed has been sent'),
      findsOneWidget,
    );
    expect(h.location, AppRoutes.login);
    expect(h.container.read(sessionProvider).isGuest, isFalse);
  });

  testWidgets('the sheet offers the guest way in', (tester) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'tom@club.com');
    await tester.enterText(find.byType(TextField).at(1), 'hunter2!');
    await _tap(tester, 'Sign in');

    await tester.tap(find.text('Continue as guest').last);
    await tester.pumpAndSettle();

    expect(h.location, AppRoutes.setup);
    expect(h.container.read(sessionProvider).isGuest, isTrue);
  });

  testWidgets('"Not now" closes the sheet and stays put', (tester) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'tom@club.com');
    await tester.enterText(find.byType(TextField).at(1), 'hunter2!');
    await _tap(tester, 'Sign in');

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Accounts open after the soft launch'), findsNothing);
    expect(h.location, AppRoutes.login);
  });

  testWidgets('Continue as guest works without filling anything in', (
    tester,
  ) async {
    final h = await _pump(tester);

    await _tap(tester, 'Continue as guest');

    expect(h.location, AppRoutes.setup);
    expect(h.container.read(sessionProvider).isGuest, isTrue);
  });

  testWidgets('links to Sign up, and back arrow leaves', (tester) async {
    final h = await _pump(tester);

    await _tap(tester, 'New to Qaddy? Create an account');
    expect(h.location, AppRoutes.signUp);
    expect(find.text('Join Qaddy'), findsOneWidget);
  });

  testWidgets('lays out on a small phone with the keyboard room it needs', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 480));

    expect(tester.takeException(), isNull);
  });
}
