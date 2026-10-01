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
import 'package:qaddy/features/trips/ui/screens/trip_accommodation_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_chat_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_complete_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_details_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_expenses_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_golf_schedule_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_planning_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_travel_screen.dart';
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
                  GoRoute(
                    path: 'details',
                    name: RouteNames.tripDetails,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripDetailsScreen(),
                  ),
                  GoRoute(
                    path: 'planning',
                    name: RouteNames.tripPlanning,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripPlanningScreen(),
                  ),
                  GoRoute(
                    path: 'travel',
                    name: RouteNames.tripTravel,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripTravelScreen(),
                  ),
                  GoRoute(
                    path: 'accommodation',
                    name: RouteNames.tripAccommodation,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripAccommodationScreen(),
                  ),
                  GoRoute(
                    path: 'golf',
                    name: RouteNames.tripGolf,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripGolfScheduleScreen(),
                  ),
                  GoRoute(
                    path: 'expenses',
                    name: RouteNames.tripExpenses,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripExpensesScreen(),
                  ),
                  GoRoute(
                    path: 'chat',
                    name: RouteNames.tripChat,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripChatScreen(),
                  ),
                  GoRoute(
                    path: 'complete',
                    name: RouteNames.tripComplete,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TripCompleteScreen(),
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
