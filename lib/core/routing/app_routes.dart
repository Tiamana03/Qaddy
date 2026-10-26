/// Route path constants — see `docs/architecture/navigation.md`'s Route
/// Hierarchy.
library;

/// Route path constants for Qaddy's Release 1 destinations.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String rounds = '/rounds';
  static const String trips = '/trips';
  static const String tripCreate = '/trips/create';

  // Trip routes carry the trip's id: `/trips/:tripId/...`. Only the
  // helpers below build them, so no screen hand-assembles a path.
  static String tripDetails(String id) => '/trips/$id';
  static String tripPlanning(String id) => '/trips/$id/planning';
  static String tripFlights(String id) => '/trips/$id/flights';
  static String tripFlight(String id, String flightId) =>
      '/trips/$id/flights/$flightId';
  static String tripAccommodation(String id) => '/trips/$id/accommodation';
  static String tripTransport(String id) => '/trips/$id/transport';
  static String tripGolf(String id) => '/trips/$id/golf';
  static String tripCourse(String id, String courseId) =>
      '/trips/$id/golf/$courseId';
  static String tripExpenses(String id) => '/trips/$id/expenses';
  static String tripChat(String id) => '/trips/$id/chat';
  static String tripComplete(String id) => '/trips/$id/complete';
  static String tripEdit(String id) => '/trips/$id/edit';
  static String tripEditSection(String id, String section) =>
      '/trips/$id/edit/$section';

  /// An item form inside an edit section; [itemId] is `new` to add one.
  static String tripEditItem(String id, String section, String itemId) =>
      '/trips/$id/edit/$section/$itemId';
  static String tripSettings(String id) => '/trips/$id/settings';
  static String tripInvite(String id) => '/trips/$id/invite';
  static String tripExport(String id) => '/trips/$id/export';
  static const String friends = '/friends';
  static const String friendsList = '/friends/list';
  static const String friendProfile = '/friends/profile';
  static const String friendsActivity = '/friends/activity';
  static const String friendRequests = '/friends/requests';
  static const String friendsSearch = '/friends/search';
  static const String friendsGroups = '/friends/groups';
  static const String friendsGroupDetails = '/friends/groups/details';
  static const String friendsRivalries = '/friends/rivalries';
  static const String profile = '/profile';
  static const String profileStatistics = '/profile/statistics';
  static const String profileGolfBag = '/profile/bag';
  static const String profileSettings = '/profile/settings';
  static const String homeNotifications = '/home/notifications';
  static const String homeSearch = '/home/search';
}
