import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/config/app_config.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  const config = AppConfig.current;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

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
        await SentryFlutter.init((options) {
          options
            ..dsn = config.sentryDsn
            ..environment = config.environment.name
            ..tracesSampleRate = config.environment == AppEnvironment.prod
                ? 0.2
                : 1.0;
        }, appRunner: () => runApp(const ProviderScope(child: QaddyApp())));
      } else {
        runApp(const ProviderScope(child: QaddyApp()));
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
      // Full design-system theming lands in Milestone 1 — this is a neutral
      // placeholder so the app is usable (and testable) before then.
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routerConfig: router,
    );
  }
}
