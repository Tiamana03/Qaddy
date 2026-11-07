/// Qaddy's Settings screen — the golfer's own details, how the app looks, which
/// notifications they want, what is kept on their phone, and the plain facts
/// about Qaddy. Everything here does something.
///
/// See `docs/features/settings-release-candidate.md`. Reached from Profile.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/config/app_info.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/services/local_data.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/theme/theme_mode_controller.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/forms/qaddy_switch_row.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/profile/ui/widgets/edit_profile_sheet.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// Settings (route `/profile/settings`).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final golfer = ref.watch(golferDetailsProvider);
    final sample = ref.watch(sampleOnProvider);
    final mode = ref.watch(themeModeProvider);
    final muted = ref.watch(notificationsProvider.select((s) => s.muted));
    final rounds = ref.watch(roundHistoryProvider).length;

    Future<void> editProfile() => showEditProfileSheet(context, ref);

    Future<void> chooseSample({required bool on}) async {
      if (!on) {
        final sure = await showQaddyConfirm(
          context,
          title: 'Remove the Sample Clubhouse?',
          message:
              'The sample mates, groups, trips, rivalry and season table '
              'disappear. Your own rounds, trips and bag stay. You can bring '
              'it back from here any time.',
          confirmLabel: 'Remove it',
          destructive: true,
        );
        if (!sure) {
          return;
        }
      }
      // The last step starts the app afresh, so every screen shows what is now
      // true.
      ref
        ..read(sampleClubhouseProvider.notifier).choose(enabled: on)
        ..read(friendsProvider.notifier).setSample(on: on)
        ..read(tripsProvider.notifier).setSample(on: on)
        ..invalidate(roundSetupProvider)
        ..invalidate(appRouterProvider);
    }

    Future<void> clearRounds() async {
      final sure = await showQaddyConfirm(
        context,
        title: 'Clear your rounds?',
        message:
            'This deletes the $rounds ${rounds == 1 ? 'round' : 'rounds'} '
            'saved on this phone, along with the statistics and achievements '
            'they built. It cannot be undone.',
        confirmLabel: 'Clear rounds',
        destructive: true,
      );
      if (sure) {
        ref.read(roundsProvider.notifier).clearHistory();
      }
    }

    Future<void> startOver() async {
      final sure = await showQaddyConfirm(
        context,
        title: 'Start over?',
        message:
            'This clears everything Qaddy keeps on this phone — your name, '
            'rounds, trips, bag and settings — and cannot be undone.',
        confirmLabel: 'Start over',
        destructive: true,
      );
      if (!sure || !context.mounted) {
        return;
      }
      await ref.read(localDataProvider).clear();
      if (!context.mounted) {
        return;
      }
      // The seeded world was built around the old name, so a clean start needs
      // the app opened afresh.
      await showQaddyNotice(
        context,
        title: 'Fresh start',
        message:
            'Everything has been cleared. Close Qaddy completely and open '
            'it again to set up from scratch.',
        dismissible: false,
      );
    }

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            QaddyCard(
              onTap: editProfile,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FittedBox(
                      child: QaddyAvatar(name: golfer.firstName),
                    ),
                  ),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          golfer.firstName,
                          style: typography.h2.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          '${handicapPhrase(golfer.handicap)} · '
                          '${golfer.homeCourse ?? 'No home course yet'}',
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Edit',
                    style: typography.body.copyWith(
                      color: colours.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Appearance'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QaddySegmentedControl<ThemeMode>(
                    segments: const <QaddySegment<ThemeMode>>[
                      QaddySegment(
                        value: ThemeMode.system,
                        label: 'Auto',
                        icon: Icons.brightness_auto_outlined,
                      ),
                      QaddySegment(
                        value: ThemeMode.light,
                        label: 'Light',
                        icon: Icons.light_mode_outlined,
                      ),
                      QaddySegment(
                        value: ThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined,
                      ),
                    ],
                    selected: mode,
                    onChanged: (value) {
                      QaddyHaptics.selection();
                      ref.read(themeModeProvider.notifier).choose(value);
                    },
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    mode == ThemeMode.system
                        ? 'Qaddy follows your phone.'
                        : 'Qaddy is always '
                              '${themeModeLabel(mode).toLowerCase()}.',
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Notifications'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final category in NotificationCategory.values)
                    QaddySwitchRow(
                      title: notificationCategoryLabel(category),
                      subtitle: notificationCategoryBlurb(category),
                      value: !muted.contains(category),
                      onChanged: (on) => ref
                          .read(notificationsProvider.notifier)
                          .setEnabled(category, enabled: on),
                    ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'These choose what shows in your Notifications and on the '
                    "bell. Qaddy doesn't send push notifications yet.",
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your account'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.person_outline, color: colours.gold),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Playing as a guest',
                          style: typography.body.copyWith(
                            color: colours.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          'Everything is saved on this phone. Accounts open '
                          'after the soft launch.',
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Sample Clubhouse'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        sample ? 'On' : 'Off',
                        style: typography.h3.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      const SampleBadge(),
                    ],
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    sample
                        ? 'Tom, Ben and the other mates, the Saturday Boys, '
                              'the Melbourne trip and the season table are '
                              'samples, '
                              'here so you can see how Qaddy works. They are '
                              'always labelled Sample and are never your own '
                              'friends. Keep them, edit the trips (yours to '
                              'change), or remove them.'
                        : "You're starting with an empty clubhouse. Bring the "
                              'Sample Clubhouse back to see what Qaddy can do '
                              'with mates, groups and trips.',
                    style: typography.body.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyNavRow(
                    icon: sample
                        ? Icons.visibility_off_outlined
                        : Icons.theaters_outlined,
                    title: sample
                        ? 'Remove the Sample Clubhouse'
                        : 'Bring back the Sample Clubhouse',
                    destructive: sample,
                    onTap: () => chooseSample(on: !sample),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your data'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _savedLine(rounds),
                    style: typography.body.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  if (rounds > 0)
                    QaddyNavRow(
                      icon: Icons.delete_outline,
                      title: 'Clear my rounds',
                      subtitle:
                          'Delete $rounds saved '
                          '${rounds == 1 ? 'round' : 'rounds'}',
                      destructive: true,
                      onTap: clearRounds,
                    ),
                  QaddyNavRow(
                    icon: Icons.restart_alt,
                    title: 'Start over',
                    subtitle: 'Clear everything and set Qaddy up again',
                    destructive: true,
                    onTap: startOver,
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'About'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  QaddyNavRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle: 'Your golf stays on your phone',
                    onTap: () => _showPrivacy(context),
                  ),
                  QaddyNavRow(
                    icon: Icons.info_outline,
                    title: 'About Qaddy',
                    subtitle: 'Version $appVersionLabel',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.lg),
            Center(
              child: Text(
                'Qaddy $appVersion · $appReleaseLabel',
                style: typography.caption.copyWith(color: colours.textTertiary),
              ),
            ),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

Future<void> _showPrivacy(BuildContext context) {
  final theme = Theme.of(context);
  final colours = theme.extension<QaddyColours>()!;
  final spacing = theme.extension<QaddySpacing>()!;
  final typography = theme.extension<QaddyTypography>()!;

  Widget point(String text) => Padding(
    padding: EdgeInsets.only(bottom: spacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.check_circle_outline, size: 20, color: colours.gold),
        SizedBox(width: spacing.md),
        Expanded(
          child: Text(
            text,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
        ),
      ],
    ),
  );

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colours.surface1,
    builder: (sheetContext) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Your golf stays on your phone',
            style: typography.h2.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.lg),
          point(
            'There are no accounts in this release. Your name, handicap, '
            'rounds, trips and bag are saved only on this phone.',
          ),
          point(
            "Nothing is sent to a Qaddy server, and Qaddy doesn't track you "
            'or show ads. Crash reports are off.',
          ),
          point(
            "Sharing an invite, a challenge or a scorecard uses your phone's "
            'share sheet, and goes only where you send it.',
          ),
          point(
            'You are in control: clear your rounds, or start over, any time '
            'in Settings under Your data.',
          ),
          QaddyTertiaryButton(
            label: 'Close',
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showAbout(BuildContext context) {
  final theme = Theme.of(context);
  final colours = theme.extension<QaddyColours>()!;
  final spacing = theme.extension<QaddySpacing>()!;
  final typography = theme.extension<QaddyTypography>()!;

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colours.surface1,
    builder: (sheetContext) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
      child: Column(
        children: <Widget>[
          const QaddyMark(size: 88),
          SizedBox(height: spacing.lg),
          Text('Qaddy', style: typography.h1.copyWith(color: colours.accent)),
          SizedBox(height: spacing.xs),
          Text(
            "The golfer's ecosystem",
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Score your rounds, plan the golf trip and play with your mates — '
            'all in one place.',
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Version $appVersionLabel · $appReleaseLabel',
            style: typography.small.copyWith(color: colours.textTertiary),
          ),
          SizedBox(height: spacing.md),
          QaddyTertiaryButton(
            label: 'Close',
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    ),
  );
}

/// What is kept on the phone, in a sentence.
String _savedLine(int rounds) => rounds == 0
    ? 'Your trips, bag and settings are saved on this phone.'
    : 'On this phone: $rounds ${rounds == 1 ? 'round' : 'rounds'}, your '
          'trips, your bag and your settings.';
