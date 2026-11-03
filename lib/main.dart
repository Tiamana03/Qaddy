import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/config/app_config.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/core/services/local_data.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/theme/theme_mode_controller.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/my_bag/state/bag_controller.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/rounds/repositories/rounds_storage.dart';
import 'package:qaddy/features/trips/repositories/trips_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  const config = AppConfig.current;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Trips, rounds and the golf bag are kept on the device. If storage
      // can't be opened the app still runs; they just won't survive a restart.
      // The app opens on the splash, which sends golfers to the introduction
      // the first time and straight into the app after that.
      final overrides = <Override>[
        launchLocationProvider.overrideWithValue(AppRoutes.splash),
      ];
      try {
        final preferences = await SharedPreferences.getInstance();
        // Who the golfer is must be known before any seeded data is read.
        final storedGolfer = preferences.getString(golferStorageKey);
        useGolfer(storedGolfer == null ? null : decodeGolfer(storedGolfer));
        overrides.addAll(<Override>[
          tripsStorageProvider.overrideWithValue(
            SharedPreferencesTripsStorage(preferences),
          ),
          roundsStorageProvider.overrideWithValue(
            SharedPreferencesRoundsStorage(preferences),
          ),
          bagStorageProvider.overrideWithValue(
            SharedPreferencesDocumentStorage(preferences, 'qaddy.bag.v1'),
          ),
          sessionStorageProvider.overrideWithValue(
            SharedPreferencesDocumentStorage(preferences, sessionStorageKey),
          ),
          golferStorageProvider.overrideWithValue(
            SharedPreferencesDocumentStorage(preferences, golferStorageKey),
          ),
          themeStorageProvider.overrideWithValue(
            SharedPreferencesDocumentStorage(preferences, themeStorageKey),
          ),
          notificationsStorageProvider.overrideWithValue(
            SharedPreferencesDocumentStorage(
              preferences,
              notificationsStorageKey,
            ),
          ),
          localDataProvider.overrideWithValue(
            SharedPreferencesLocalData(preferences),
          ),
        ]);
      } on Object catch (error) {
        debugPrint('Storage unavailable: $error');
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
    final themeMode = ref.watch(themeModeProvider);

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
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
