/// Crash + error reporting, behind an interface for the same reason as
/// `AnalyticsService` — see that file's doc comment.
///
/// Unlike analytics, crash reporting carries no data-residency tension with
/// the founders' stated philosophy, so this is wired to Sentry from
/// Milestone 0 (see `main.dart` for the `SentryFlutter.init` bootstrap).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart' as sentry;

abstract class CrashReportingService {
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  });

  Future<void> setUserContext(String? userId);
}

class SentryCrashReportingService implements CrashReportingService {
  const SentryCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    return sentry.Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: context == null
          ? null
          : (scope) => scope.setContexts('context', {'value': context}),
    );
  }

  @override
  Future<void> setUserContext(String? userId) async {
    await sentry.Sentry.configureScope((scope) {
      scope.setUser(userId == null ? null : sentry.SentryUser(id: userId));
    });
  }
}

class NoopCrashReportingService implements CrashReportingService {
  const NoopCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) async {}

  @override
  Future<void> setUserContext(String? userId) async {}
}

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return const SentryCrashReportingService();
});
