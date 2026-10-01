// Verifies the real app router wires Authentication's four screens
// together: Splash -> Onboarding -> Login <-> Sign Up -> Dashboard. Unlike
// every other navigation test, nothing in the shipped UI links to these
// screens by design (see authentication-engineering-decisions.md's "This
// Flow Is Not the App's Boot Sequence"), so this test pre-navigates the
// real router to `/` before the first pump, rather than tapping an icon to
// get there.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets(
    'Splash -> Onboarding -> Login -> Sign Up -> Login -> Dashboard',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appRouterProvider).go(AppRoutes.splash);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const QaddyApp(),
        ),
      );
      await tester.pump();

      expect(find.text('Loading your golf world…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Track Every Round'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to continue'), findsOneWidget);

      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);

      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to continue'), findsOneWidget);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Good Morning,'), findsOneWidget);
    },
  );
}
