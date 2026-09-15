/// The persistent Bottom Navigation shell — see
/// `docs/architecture/navigation.md`.
///
/// Renders whichever branch is active in `navigationShell` plus a
/// `BottomNavigationBar` styled entirely from `QaddyColours`/
/// `QaddyTypography` (Sprint 1.1) — no hardcoded colours or type styles.
/// Each branch keeps its own navigation stack via
/// `StatefulShellRoute.indexedStack` in `app_router.dart`; this widget does
/// not manage that state itself.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Wraps the five Release 1 destinations with a persistent bottom nav bar.
class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.navigationShell, super.key});

  /// The active branch and switching callback, supplied by
  /// `StatefulShellRoute.indexedStack`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        backgroundColor: colours.surface1,
        selectedItemColor: colours.primary,
        unselectedItemColor: colours.textTertiary,
        selectedLabelStyle: typography.navigation,
        unselectedLabelStyle: typography.navigation,
        // Icons follow the Navigation Library asset where it depicts a tab
        // (Home, Rounds, Trips, Profile). It doesn't depict "Friends" —
        // that tab replaced the asset's "Play" tab per navigation.md's
        // Engineering Decision — so `Icons.people` is a standard,
        // non-token Material choice; see the Sprint 1.2 report.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Rounds'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Trips',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
