import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/config/app_config.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/repositories/trips_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  const config = AppConfig.current;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Trips are kept on the device. If storage can't be opened the app still
      // runs; trips just won't survive a restart.
      final overrides = <Override>[];
      try {
        final preferences = await SharedPreferences.getInstance();
        overrides.add(
          tripsStorageProvider.overrideWithValue(
            SharedPreferencesTripsStorage(preferences),
          ),
        );
      } on Object catch (error) {
        debugPrint('Trips storage unavailable: $error');
      }

      if (config.isBackendConfigured) {
        await Supabase.initialize(
          url: config.supabaseUrl,
          publishableKey: config.supabasePublishableKey,
        );
      }
      // When isBackendConfigured is false (no Supabase project provisioned
      // yet, e.g. running M0 locally), the app still boots — features that
      // need a live backend simply aren't reachable until M2 wires auth.

      if (config.isCrashReportingConfigured) {
        await SentryFlutter.init(
          (options) {
            options
              ..dsn = config.sentryDsn
              ..environment = config.environment.name
              ..tracesSampleRate = config.environment == AppEnvironment.prod
                  ? 0.2
                  : 1.0;
          },
          appRunner: () => runApp(
            ProviderScope(overrides: overrides, child: const QaddyApp()),
          ),
        );
      } else {
        runApp(ProviderScope(overrides: overrides, child: const QaddyApp()));
      }
    },
    (error, stackTrace) {
      // Fallback for errors thrown before Sentry (or when crash reporting
      // isn't configured, e.g. local dev without a DSN) — never let an
      // unconfigured backend silently swallow a crash.
      debugPrint('Uncaught error: $error\n$stackTrace');
    },
  );
}

class QaddyApp extends ConsumerWidget {
  const QaddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Qaddy',
      debugShowCheckedModeBanner: false,
      // Qaddy's design-system theme (Sprint 1.1) — see lib/core/theme/ and
      // design/design-tokens/. Dark Mode is Qaddy's primary theme; Light
      // Mode is the optional/secondary theme (colours.md). Both are wired
      // here; `themeMode` is left at its default (ThemeMode.system) so the
      // active theme follows the platform setting rather than forcing one.
      theme: QaddyTheme.light,
      darkTheme: QaddyTheme.dark,
      routerConfig: router,
    );
  }
}
