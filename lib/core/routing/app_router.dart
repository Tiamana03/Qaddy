/// Qaddy's application router — see `docs/architecture/navigation.md`.
///
/// Sprint 1.2: implements the five-tab Release 1 authenticated shell as a
/// `StatefulShellRoute.indexedStack` — one branch per bottom-nav
/// destination, each preserving its own navigation stack, per
/// navigation.md's "Navigation Shell" and "Navigation State" sections.
///
/// The documented public routes (`/`, `/onboarding`, `/login`) are
/// Authentication-adjacent and out of scope for this sprint — see the
/// Sprint 1.2 implementation report's Engineering Decisions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/routing/navigation_shell.dart';
import 'package:qaddy/core/routing/route_names.dart';
import 'package:qaddy/features/authentication/ui/screens/login_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/onboarding_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/sign_up_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/splash_screen.dart';
import 'package:qaddy/features/community/ui/screens/activity_feed_screen.dart';
import 'package:qaddy/features/community/ui/screens/friend_profile_screen.dart';
import 'package:qaddy/features/community/ui/screens/friend_requests_screen.dart';
import 'package:qaddy/features/community/ui/screens/friends_home_screen.dart';
import 'package:qaddy/features/community/ui/screens/friends_list_screen.dart';
import 'package:qaddy/features/community/ui/screens/rivalries_screen.dart';
import 'package:qaddy/features/community/ui/screens/search_friends_screen.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:qaddy/features/groups/ui/screens/group_details_screen.dart';
import 'package:qaddy/features/groups/ui/screens/groups_screen.dart';
import 'package:qaddy/features/my_bag/ui/screens/golf_bag_screen.dart';
import 'package:qaddy/features/notifications/ui/screens/notifications_screen.dart';
import 'package:qaddy/features/profile/ui/screens/profile_screen.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';
import 'package:qaddy/features/search/ui/screens/search_screen.dart';
import 'package:qaddy/features/settings/ui/screens/settings_screen.dart';
import 'package:qaddy/features/statistics/ui/screens/statistics_screen.dart';
import 'package:qaddy/features/trips/ui/screens/create_trip_screen.dart';
import 'package:qaddy/features/trips/ui/screens/edit/edit_trip_item_screen.dart';
import 'package:qaddy/features/trips/ui/screens/edit/edit_trip_screen.dart';
import 'package:qaddy/features/trips/ui/screens/edit/edit_trip_section_screen.dart';
import 'package:qaddy/features/trips/ui/screens/export_itinerary_screen.dart';
import 'package:qaddy/features/trips/ui/screens/invite_friends_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_accommodation_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_chat_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_complete_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_course_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_details_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_expenses_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_flight_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_flights_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_golf_schedule_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_planning_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_settings_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_transport_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouteNames.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: RouteNames.signUp,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => NavigationShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: RouteNames.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'notifications',
                    name: RouteNames.homeNotifications,
                    builder: (BuildContext context, GoRouterState state) =>
                        const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    name: RouteNames.homeSearch,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.rounds,
                name: RouteNames.rounds,
                builder: (BuildContext context, GoRouterState state) =>
                    const RoundsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.trips,
                name: RouteNames.trips,
                builder: (BuildContext context, GoRouterState state) =>
                    const TripsScreen(),
                routes: <RouteBase>[
                  // `create` must precede `:tripId` or it reads as an id.
                  GoRoute(
                    path: 'create',
                    name: RouteNames.tripCreate,
                    builder: (BuildContext context, GoRouterState state) =>
                        const CreateTripScreen(),
                  ),
                  GoRoute(
                    path: ':tripId',
                    name: RouteNames.tripDetails,
                    builder: (BuildContext context, GoRouterState state) =>
                        TripDetailsScreen(
                          tripId: state.pathParameters['tripId']!,
                        ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'planning',
                        name: RouteNames.tripPlanning,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripPlanningScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'flights',
                        name: RouteNames.tripFlights,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripFlightsScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: ':flightId',
                            name: RouteNames.tripFlight,
                            builder:
                                (BuildContext context, GoRouterState state) =>
                                    TripFlightScreen(
                                      tripId: state.pathParameters['tripId']!,
                                      flightId:
                                          state.pathParameters['flightId']!,
                                    ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'transport',
                        name: RouteNames.tripTransport,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripTransportScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'accommodation',
                        name: RouteNames.tripAccommodation,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripAccommodationScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'golf',
                        name: RouteNames.tripGolf,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripGolfScheduleScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: ':courseId',
                            name: RouteNames.tripCourse,
                            builder:
                                (BuildContext context, GoRouterState state) =>
                                    TripCourseScreen(
                                      tripId: state.pathParameters['tripId']!,
                                      courseId:
                                          state.pathParameters['courseId']!,
                                    ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'expenses',
                        name: RouteNames.tripExpenses,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripExpensesScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'chat',
                        name: RouteNames.tripChat,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripChatScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'complete',
                        name: RouteNames.tripComplete,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripCompleteScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'edit',
                        name: RouteNames.tripEdit,
                        builder: (BuildContext context, GoRouterState state) =>
                            EditTripScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: ':section',
                            name: RouteNames.tripEditSection,
                            builder:
                                (BuildContext context, GoRouterState state) =>
                                    EditTripSectionScreen(
                                      tripId: state.pathParameters['tripId']!,
                                      section: state.pathParameters['section']!,
                                    ),
                            routes: <RouteBase>[
                              GoRoute(
                                path: ':itemId',
                                name: RouteNames.tripEditItem,
                                builder:
                                    (
                                      BuildContext context,
                                      GoRouterState state,
                                    ) => EditTripItemScreen(
                                      tripId: state.pathParameters['tripId']!,
                                      section: state.pathParameters['section']!,
                                      itemId: state.pathParameters['itemId']!,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'settings',
                        name: RouteNames.tripSettings,
                        builder: (BuildContext context, GoRouterState state) =>
                            TripSettingsScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'invite',
                        name: RouteNames.tripInvite,
                        builder: (BuildContext context, GoRouterState state) =>
                            InviteFriendsScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                      GoRoute(
                        path: 'export',
                        name: RouteNames.tripExport,
                        builder: (BuildContext context, GoRouterState state) =>
                            ExportItineraryScreen(
                              tripId: state.pathParameters['tripId']!,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.friends,
                name: RouteNames.friends,
                builder: (BuildContext context, GoRouterState state) =>
                    const FriendsHomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'list',
                    name: RouteNames.friendsList,
                    builder: (BuildContext context, GoRouterState state) =>
                        const FriendsListScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    name: RouteNames.friendProfile,
                    builder: (BuildContext context, GoRouterState state) =>
                        const FriendProfileScreen(),
                  ),
                  GoRoute(
                    path: 'activity',
                    name: RouteNames.friendsActivity,
                    builder: (BuildContext context, GoRouterState state) =>
                        const ActivityFeedScreen(),
                  ),
                  GoRoute(
                    path: 'requests',
                    name: RouteNames.friendRequests,
                    builder: (BuildContext context, GoRouterState state) =>
                        const FriendRequestsScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    name: RouteNames.friendsSearch,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SearchFriendsScreen(),
                  ),
                  GoRoute(
                    path: 'groups',
                    name: RouteNames.friendsGroups,
                    builder: (BuildContext context, GoRouterState state) =>
                        const GroupsScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'details',
                        name: RouteNames.friendsGroupDetails,
                        builder: (BuildContext context, GoRouterState state) =>
                            const GroupDetailsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'rivalries',
                    name: RouteNames.friendsRivalries,
                    builder: (BuildContext context, GoRouterState state) =>
                        const RivalriesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                name: RouteNames.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'statistics',
                    name: RouteNames.profileStatistics,
                    builder: (BuildContext context, GoRouterState state) =>
                        const StatisticsScreen(),
                  ),
                  GoRoute(
                    path: 'bag',
                    name: RouteNames.profileGolfBag,
                    builder: (BuildContext context, GoRouterState state) =>
                        const GolfBagScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: RouteNames.profileSettings,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
