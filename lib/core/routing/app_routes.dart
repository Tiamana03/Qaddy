/// Route path constants — see `docs/architecture/navigation.md`'s Route
/// Hierarchy.
///
/// The documented public routes (`/`, `/onboarding`, `/login`) are
/// Authentication-adjacent and out of scope for Sprint 1.2 — see the
/// Sprint 1.2 implementation report.
library;

/// Route path constants for Qaddy's Release 1 destinations.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String rounds = '/rounds';
  static const String trips = '/trips';
  static const String tripDetails = '/trips/details';
  static const String tripPlanning = '/trips/planning';
  static const String tripTravel = '/trips/travel';
  static const String tripAccommodation = '/trips/accommodation';
  static const String tripGolf = '/trips/golf';
  static const String tripExpenses = '/trips/expenses';
  static const String tripChat = '/trips/chat';
  static const String tripComplete = '/trips/complete';
  static const String friends = '/friends';
  static const String profile = '/profile';
}
