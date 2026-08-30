/// Environment configuration for Qaddy.
///
/// Values are supplied at build/run time via `--dart-define-from-file`,
/// pointing at one of `lib/core/config/env/{dev,staging,prod}.json`
/// (see the `.example` files checked into this folder — the real files
/// hold real project credentials and are gitignored).
///
/// This exists so no feature or `core/` service ever reads an environment
/// variable directly: everything goes through [AppConfig.current], which
/// keeps the actual Supabase project (or any other per-environment secret)
/// swappable without touching call sites. Nothing here assumes a real
/// Supabase project exists yet — [supabaseUrl] and [supabaseAnonKey] default
/// to empty strings, and [AppConfig.isBackendConfigured] lets the app boot
/// and be tested safely before a project is provisioned.
library;

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig._({
    required this.environmentName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.postHogApiKey,
    required this.postHogHost,
  });

  /// Raw value of the `APP_ENV` define. Kept as a plain string on the const
  /// constructor because `String.fromEnvironment` must be invoked in a const
  /// context to pick up `--dart-define` values — [environment] below parses
  /// it into [AppEnvironment] as a regular (non-const) getter instead, since
  /// const expressions can't call arbitrary parsing functions.
  final String environmentName;

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String postHogApiKey;
  final String postHogHost;

  AppEnvironment get environment => switch (environmentName) {
    'prod' => AppEnvironment.prod,
    'staging' => AppEnvironment.staging,
    _ => AppEnvironment.dev,
  };

  bool get isBackendConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get isCrashReportingConfigured => sentryDsn.isNotEmpty;

  bool get isAnalyticsConfigured => postHogApiKey.isNotEmpty;

  static const AppConfig current = AppConfig._(
    environmentName: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    sentryDsn: String.fromEnvironment('SENTRY_DSN'),
    postHogApiKey: String.fromEnvironment('POSTHOG_API_KEY'),
    postHogHost: String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://app.posthog.com',
    ),
  );
}
