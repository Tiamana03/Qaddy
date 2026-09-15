/// Route path constants — see `docs/architecture/navigation.md`'s Route Map.
///
/// Only the five Release 1 authenticated destinations are defined here.
/// The documented public routes (`/`, `/onboarding`, `/login`) are
/// Authentication-adjacent and out of scope for Sprint 1.2 — see the
/// Sprint 1.2 implementation report.
library;

/// Route path constants for Qaddy's five Release 1 destinations.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String rounds = '/rounds';
  static const String trips = '/trips';
  static const String friends = '/friends';
  static const String profile = '/profile';
}
