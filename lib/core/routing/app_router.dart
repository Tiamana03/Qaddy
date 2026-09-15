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
import 'package:qaddy/features/community/ui/screens/community_screen.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:qaddy/features/profile/ui/screens/profile_screen.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.friends,
                name: RouteNames.friends,
                builder: (BuildContext context, GoRouterState state) =>
                    const CommunityScreen(),
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
