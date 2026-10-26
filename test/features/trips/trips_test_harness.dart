/// Shared setup for Trips widget tests: a themed `MaterialApp` inside a
/// `ProviderScope`, so every screen reads the same in-memory trip store the
/// app does.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';

/// The id of the one fully seeded trip (Melbourne Golf Weekend).
const melbourneId = 'melbourne-golf-weekend';

/// Pumps [home] with the dark theme and a fresh trip store.
Future<ProviderContainer> pumpTrips(
  WidgetTester tester,
  Widget home, {
  ThemeData? theme,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: theme ?? QaddyTheme.dark, home: home),
    ),
  );
  return container;
}

/// Pumps a router-driven app so navigation can be asserted. [routes] are
/// registered as given; the app opens at [initialLocation].
Future<ProviderContainer> pumpTripsRouter(
  WidgetTester tester, {
  required String initialLocation,
  required List<RouteBase> routes,
  ThemeData? theme,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: theme ?? QaddyTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  return container;
}
