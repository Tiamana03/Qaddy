import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/profile/ui/screens/profile_screen.dart';

void main() {
  testWidgets('shows the header, summary and every placeholder section', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const ProfileScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);

    // Header + Details.
    expect(find.text('Tiamana'), findsOneWidget);
    // Appears twice: Details' Favourite Course row and the Favourite
    // Courses list (which also includes it).
    expect(find.text('Royal Queensland Golf Club'), findsNWidgets(2));
    expect(find.text('Queensland, Australia'), findsOneWidget);
    expect(find.text('1 Jan 2024'), findsOneWidget);

    // Profile Summary counts, computed from the other features' own
    // placeholder data.
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('4'), findsWidgets);
    expect(find.text('Trips'), findsOneWidget);

    // Playing Statistics.
    expect(find.text('Playing Statistics'), findsOneWidget);
    expect(find.text('83'), findsOneWidget);

    // Current Season — read from Saturday Boys' own leaderboard.
    expect(find.text('Current Season'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsOneWidget);
    expect(find.text('5th'), findsOneWidget);

    // Personal Bests, Achievement Showcase, Favourites, Equipment, Activity.
    expect(find.text('312m'), findsOneWidget);
    expect(find.text('Birdie Hunter'), findsOneWidget);
    expect(find.text('TaylorMade Qi35'), findsOneWidget);
    expect(find.text('Completed Richmond Golf Club'), findsOneWidget);
  });

  testWidgets('Favourite Playing Partners reuses real Friend objects', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const ProfileScreen()),
    );

    expect(find.text('Favourite Playing Partners'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Luke'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Nick'), findsOneWidget);
  });
}
