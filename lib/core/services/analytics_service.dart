/// Product analytics, behind an interface so no feature ever imports a
/// vendor SDK directly (the same "replaceable provider" pattern used for
/// course data — see `features/rounds/repositories/course_repository.dart`
/// once it lands in Milestone 5).
///
/// Per the Founder's Blueprint's Analytics Philosophy — "collect only data
/// that improves the golfer's experience... avoid vanity metrics... privacy
/// and trust come first" — this ships bound to [NoopAnalyticsService] until
/// a launch-geography / data-residency decision is made for the PostHog
/// binding. Swapping the binding is a one-line change in
/// `analytics_providers.dart`; no call site changes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AnalyticsService {
  Future<void> track(String event, {Map<String, Object?>? properties});

  Future<void> identify(String userId, {Map<String, Object?>? traits});

  Future<void> reset();
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> track(String event, {Map<String, Object?>? properties}) async {}

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {}

  @override
  Future<void> reset() async {}
}

/// Bind this once a PostHog project + hosting region has actually been
/// decided. Left unimplemented deliberately rather than guessed at.
class PostHogAnalyticsService implements AnalyticsService {
  const PostHogAnalyticsService();

  @override
  Future<void> track(String event, {Map<String, Object?>? properties}) {
    throw UnimplementedError(
      'PostHogAnalyticsService is not wired yet — see AppConfig.isAnalyticsConfigured '
      'and analytics_providers.dart. Requires a launch-geography/data-residency '
      'decision before going live (see the Release One roadmap, M0).',
    );
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) {
    throw UnimplementedError('See track() above.');
  }

  @override
  Future<void> reset() {
    throw UnimplementedError('See track() above.');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  // Swap to PostHogAnalyticsService() once AppConfig.current.isAnalyticsConfigured
  // and the hosting-region decision is made. Nothing outside this file changes.
  return const NoopAnalyticsService();
});
