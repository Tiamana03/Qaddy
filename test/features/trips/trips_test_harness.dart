/// Shared setup for Trips widget tests: a themed `MaterialApp` inside a
/// `ProviderScope`, so every screen reads the same in-memory trip store the
/// app does.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/services/share_service.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/main.dart';

/// The id of the one fully seeded trip (Melbourne Golf Weekend).
const melbourneId = 'melbourne-golf-weekend';

/// Pumps [home] with the dark theme and a fresh trip store.
Future<ProviderContainer> pumpTrips(
  WidgetTester tester,
  Widget home, {
  ThemeData? theme,
}) async {
  final container = ProviderContainer(overrides: _platformFakes());
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
  final container = ProviderContainer(overrides: _platformFakes());
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

/// Pumps the real app (real router, real theme) on a tall phone-width
/// screen, then jumps to [location]. Pages opened this way have nothing to
/// pop back to, which exercises the forms' fallback routes; open a screen
/// from the Trips tab instead to test push-and-pop behaviour.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String location = '/trips',
  Size size = const Size(400, 1800),
  List<Override> overrides = const <Override>[],
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;

  final container = ProviderContainer(
    overrides: <Override>[..._platformFakes(), ...overrides],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const QaddyApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

/// Records what the app puts on the clipboard (via the platform channel).
List<String> captureClipboard(WidgetTester tester) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

/// Records the links the app tries to open, and answers whether it could.
class FakeLinkLauncher implements LinkLauncher {
  /// Every link opened, in order.
  final List<Uri> opened = <Uri>[];

  /// What [open] reports. Set to `false` to see the fallback behaviour.
  bool canOpen = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return canOpen;
  }
}

/// Records what the app shares, and answers how the share ended.
class FakeShareService implements ShareService {
  /// Every text shared, in order.
  final List<String> shared = <String>[];

  /// The subject of each share.
  final List<String?> subjects = <String?>[];

  /// What [shareText] reports. Set to [ShareOutcome.unavailable] to see the
  /// fallback behaviour.
  ShareOutcome outcome = ShareOutcome.shared;

  @override
  Future<ShareOutcome> shareText(String text, {String? subject}) async {
    shared.add(text);
    subjects.add(subject);
    return outcome;
  }
}

/// The fake launcher the harness installed.
FakeLinkLauncher launcherOf(ProviderContainer c) =>
    c.read(linkLauncherProvider) as FakeLinkLauncher;

/// The fake share service the harness installed.
FakeShareService shareOf(ProviderContainer c) =>
    c.read(shareServiceProvider) as FakeShareService;

/// The overrides every harness container starts with: recording fakes in
/// place of the real plugins, so no test ever opens a real app.
List<Override> _platformFakes() => <Override>[
  linkLauncherProvider.overrideWithValue(FakeLinkLauncher()),
  shareServiceProvider.overrideWithValue(FakeShareService()),
];
