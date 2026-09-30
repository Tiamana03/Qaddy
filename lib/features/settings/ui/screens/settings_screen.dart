/// Qaddy's Settings screen — a read-only view of preferences that already
/// exist elsewhere.
///
/// See `docs/features/settings-feature-integration.md`. Release 1 is a
/// single screen reached from Profile — see
/// `docs/architecture/settings-engineering-decisions.md`'s "Settings Is
/// Reached From Profile, Not the Bottom Navigation". This feature
/// introduces no new model — see that same document's "Settings
/// Introduces No New Model" — every value below is read from Profile,
/// Notifications or `pubspec.yaml` directly.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/profile/models/placeholder_profile.dart';
import 'package:qaddy/features/profile/models/profile.dart';

/// The application version — sourced from `pubspec.yaml`'s `version` field,
/// per `docs/standards/placeholder-settings-data.md`'s "Application"
/// section. Kept here as a literal rather than read at runtime, since no
/// package for reading `pubspec.yaml` (e.g. `package_info_plus`) exists in
/// this project yet, and adding one for this alone is unjustified.
const String _appVersion = '0.1.0';

/// Settings (route `/profile/settings`).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _PrivacyCard(),
            SizedBox(height: spacing.sectionGap),
            const _NotificationPreferencesCard(),
            SizedBox(height: spacing.sectionGap),
            const _AppearanceCard(),
            SizedBox(height: spacing.sectionGap),
            const _ApplicationCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return QaddySectionCard(
      title: 'Privacy',
      child: QaddyInfoRow(
        label: 'Profile Visibility',
        value: profileVisibilityLabel(profile.profileVisibility),
      ),
    );
  }
}

class _NotificationPreferencesCard extends StatelessWidget {
  const _NotificationPreferencesCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Notification Preferences',
      child: Column(
        children: <Widget>[
          for (final (index, category)
              in NotificationCategory.values.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _PreferenceRow(label: notificationCategoryLabel(category)),
          ],
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
        ),
        const QaddyStatusBadge(
          label: 'Enabled',
          tone: QaddyStatusBadgeTone.success,
        ),
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return const QaddySectionCard(
      title: 'Appearance',
      child: QaddyInfoRow(label: 'Theme', value: 'Dark'),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard();

  @override
  Widget build(BuildContext context) {
    return const QaddySectionCard(
      title: 'Application',
      child: QaddyInfoRow(label: 'App Version', value: _appVersion),
    );
  }
}
