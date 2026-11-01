/// Shared setup for widget tests: the dark theme inside a
/// `ProviderScope`, with recording fakes in place of the share sheet and link
/// launcher so no test ever opens a real app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/services/share_service.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';

/// Records what the app shares.
class FakeShare implements ShareService {
  /// Every text shared, in order.
  final List<String> shared = <String>[];

  /// What a share reports.
  ShareOutcome outcome = ShareOutcome.shared;

  @override
  Future<ShareOutcome> shareText(String text, {String? subject}) async {
    shared.add(text);
    return outcome;
  }
}

/// Records the links the app tries to open.
class FakeLauncher implements LinkLauncher {
  /// Every link opened, in order.
  final List<Uri> opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

/// A container with the fakes installed (plus any extra [overrides]).
ProviderContainer friendsContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: <Override>[
      shareServiceProvider.overrideWithValue(FakeShare()),
      linkLauncherProvider.overrideWithValue(FakeLauncher()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// The fake share service installed by [friendsContainer].
FakeShare shareOf(ProviderContainer c) =>
    c.read(shareServiceProvider) as FakeShare;

/// Sets the test screen to [size] for the rest of the test.
void useScreen(WidgetTester tester, Size size) {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
}

/// Pumps [home] on its own.
Future<ProviderContainer> pumpFriends(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(400, 2400),
  ThemeData? theme,
  List<Override> overrides = const [],
}) async {
  useScreen(tester, size);
  final container = friendsContainer(overrides: overrides);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: theme ?? QaddyTheme.dark, home: home),
    ),
  );
  return container;
}

/// Pumps a router-driven app so navigation can be asserted.
Future<ProviderContainer> pumpFriendsRouter(
  WidgetTester tester, {
  required String initialLocation,
  required List<RouteBase> routes,
  Size size = const Size(400, 2400),
  List<Override> overrides = const [],
}) async {
  useScreen(tester, size);
  final container = friendsContainer(overrides: overrides);
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    ),
  );
  return container;
}
