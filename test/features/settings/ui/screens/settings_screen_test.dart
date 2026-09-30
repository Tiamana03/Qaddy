import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/settings/ui/screens/settings_screen.dart';

void main() {
  testWidgets(
    'shows privacy, notification preferences, appearance and application',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: QaddyTheme.dark, home: const SettingsScreen()),
      );

      expect(find.byType(QaddyScaffold), findsOneWidget);

      // Privacy — derived from Profile, not a hardcoded duplicate.
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Profile Visibility'), findsOneWidget);
      expect(find.text('Friends Only'), findsOneWidget);

      // Notification Preferences — reused from Notifications' own category
      // enum, not a second hardcoded list.
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Round Reminders'), findsOneWidget);
      expect(find.text('Friend Activity'), findsOneWidget);
      expect(find.text('Trip Updates'), findsOneWidget);
      expect(find.text('System Updates'), findsOneWidget);
      expect(find.text('Enabled'), findsNWidgets(4));

      // Appearance.
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Application.
      expect(find.text('Application'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('0.1.0'), findsOneWidget);
    },
  );
}
