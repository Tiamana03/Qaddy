/// Shared setup for the launch-experience tests: the four launch screens on a
/// router of their own, a stand-in for the app, and storage the test can
/// inspect and reuse for a second "launch".
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/screens/golfer_setup_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/login_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/onboarding_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/sign_up_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';

import 'memory_document_storage.dart';

/// What [pumpLaunch] gives back.
class LaunchHarness {
  LaunchHarness(this.container, this.router, this.storage, this.golferStorage);

  final ProviderContainer container;
  final GoRouter router;
  final MemoryDocumentStorage storage;
  final MemoryDocumentStorage golferStorage;

  /// The location the router is at.
  String get location =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
}

/// Pumps the launch screens, starting at [initialLocation]. Pass the same
/// [storage] to a second call to simulate opening the app again. Animations
/// are switched off unless [reduceMotion] is false, so `pumpAndSettle` can
/// finish (the introduction's icons otherwise drift forever).
Future<LaunchHarness> pumpLaunch(
  WidgetTester tester, {
  String initialLocation = AppRoutes.onboarding,
  MemoryDocumentStorage? storage,
  MemoryDocumentStorage? golferStorage,
  bool reduceMotion = true,
  Size size = const Size(400, 800),
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final memory = storage ?? MemoryDocumentStorage();
  final golfer = golferStorage ?? MemoryDocumentStorage();
  // Saving a golfer changes who the app thinks you are; put it back after.
  addTearDown(resetGolferForTests);
  final container = ProviderContainer(
    overrides: <Override>[
      sessionStorageProvider.overrideWithValue(memory),
      golferStorageProvider.overrideWithValue(golfer),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, __) => const GolferSetupScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const Text('The app')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: QaddyTheme.light, routerConfig: router),
    ),
  );
  return LaunchHarness(container, router, memory, golfer);
}
