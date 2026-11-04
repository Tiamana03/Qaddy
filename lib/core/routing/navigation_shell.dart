/// The persistent Bottom Navigation shell — see
/// `docs/architecture/navigation.md`.
///
/// Renders whichever branch is active in `navigationShell` plus a
/// `QaddyBottomNav` (the Navigation Library's floating bar), built entirely
/// from the design tokens. Each branch keeps its own navigation stack via
/// `StatefulShellRoute.indexedStack` in `app_router.dart`; this widget does
/// not manage that state itself.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_bottom_nav.dart';

/// Wraps the five Release 1 destinations with a persistent bottom nav bar.
class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.navigationShell, super.key});

  /// The active branch and switching callback, supplied by
  /// `StatefulShellRoute.indexedStack`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: QaddyBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelected: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        // Icons follow the Navigation Library where it depicts a tab (Home,
        // Rounds, Trips, Profile). It does not depict "Friends" (that tab
        // replaced the asset's "Play" tab per navigation.md's Engineering
        // Decision), so a matching outlined/filled people pair is used.
        destinations: const <QaddyNavDestination>[
          QaddyNavDestination(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          QaddyNavDestination(
            label: 'Rounds',
            icon: Icons.flag_outlined,
            activeIcon: Icons.flag,
          ),
          QaddyNavDestination(
            label: 'Trips',
            icon: Icons.work_outline,
            activeIcon: Icons.work,
          ),
          QaddyNavDestination(
            label: 'Friends',
            icon: Icons.people_outline,
            activeIcon: Icons.people,
          ),
          QaddyNavDestination(
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }
}
