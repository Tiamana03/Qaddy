import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/authentication/ui/screens/onboarding_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';

void main() {
  testWidgets(
    'shows the Qaddy wordmark, then advances to Onboarding automatically',
    (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.splash,
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
      );

      expect(find.text('Qaddy'), findsOneWidget);
      expect(find.text('Loading your golf world…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Track Every Round'), findsOneWidget);
    },
  );
}
