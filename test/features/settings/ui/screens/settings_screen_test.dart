import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/config/app_info.dart';
import 'package:qaddy/core/services/local_data.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/theme/theme_mode_controller.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/settings/ui/screens/settings_screen.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../../../support/app_test_harness.dart';
import '../../../../support/memory_document_storage.dart';
import '../../../../support/played_rounds.dart';

class _RecordingLocalData implements LocalData {
  int cleared = 0;

  @override
  Future<void> clear() async => cleared++;
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  ProviderContainer? container,
  Size size = const Size(400, 3200),
  ThemeData? theme,
  List<Override> overrides = const [],
}) async {
  useScreen(tester, size);
  final c = container ?? friendsContainer(overrides: overrides);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: theme ?? QaddyTheme.dark,
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows what is really there, and nothing made up', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    for (final title in <String>[
      'Appearance',
      'Notifications',
      'Your account',
      'Your data',
      'About',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    // The old pretend settings are gone.
    expect(find.text('Profile Visibility'), findsNothing);
    expect(find.text('Friends Only'), findsNothing);
    expect(find.text('Enabled'), findsNothing);
    expect(find.text('Application'), findsNothing);
    expect(find.text('Playing as a guest'), findsOneWidget);
    expect(find.text('Qaddy $appVersion · $appReleaseLabel'), findsOneWidget);
  });

  group('the golfer', () {
    testWidgets('is shown with their handicap and course', (tester) async {
      final c = friendsContainer(
        overrides: <Override>[
          golferStorageProvider.overrideWithValue(
            MemoryDocumentStorage(
              encodeGolfer(
                GolferProfile(
                  firstName: 'Amy',
                  handicap: 12,
                  homeCourse: 'Royal Melbourne',
                  joinedAt: DateTime(2026),
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(resetGolferForTests);
      await _pump(tester, container: c);

      expect(find.text('Amy'), findsWidgets);
      expect(find.text('Handicap 12 · Royal Melbourne'), findsOneWidget);
    });

    testWidgets('asks for what is missing, kindly', (tester) async {
      final c = friendsContainer(
        overrides: <Override>[
          golferStorageProvider.overrideWithValue(
            MemoryDocumentStorage(
              encodeGolfer(
                GolferProfile(firstName: 'Sam', joinedAt: DateTime(2026)),
              ),
            ),
          ),
        ],
      );
      addTearDown(resetGolferForTests);
      await _pump(tester, container: c);

      expect(find.text('No handicap yet · No home course yet'), findsOneWidget);
    });

    testWidgets('can change handicap and home course, but not the name', (
      tester,
    ) async {
      final c = friendsContainer(
        overrides: <Override>[
          golferStorageProvider.overrideWithValue(
            MemoryDocumentStorage(
              encodeGolfer(
                GolferProfile(firstName: 'Amy', joinedAt: DateTime(2026)),
              ),
            ),
          ),
        ],
      );
      addTearDown(resetGolferForTests);
      await _pump(tester, container: c);

      await _tap(tester, find.text('Edit'));
      expect(find.textContaining('Your name stays'), findsOneWidget);
      final name = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(name.enabled, isFalse);

      await tester.enterText(find.byType(TextField).at(1), '9.1');
      await tester.enterText(find.byType(TextField).at(2), 'Kooyonga');
      await _tap(tester, find.text('Save'));

      final golfer = c.read(golferProvider)!;
      expect(golfer.firstName, 'Amy');
      expect(golfer.handicap, 9.1);
      expect(golfer.homeCourse, 'Kooyonga');
      expect(find.text('Handicap 9.1 · Kooyonga'), findsOneWidget);
    });
  });

  group('appearance', () {
    testWidgets('follows the phone until the golfer chooses', (tester) async {
      final c = await _pump(tester);

      expect(c.read(themeModeProvider), ThemeMode.system);
      expect(find.text('Qaddy follows your phone.'), findsOneWidget);
    });

    testWidgets('can be made light or dark, and the choice is kept', (
      tester,
    ) async {
      final storage = MemoryDocumentStorage();
      final c = await _pump(
        tester,
        overrides: <Override>[themeStorageProvider.overrideWithValue(storage)],
      );

      await _tap(tester, find.text('Light'));
      expect(c.read(themeModeProvider), ThemeMode.light);
      expect(find.text('Qaddy is always light.'), findsOneWidget);

      await _tap(tester, find.text('Dark'));
      expect(c.read(themeModeProvider), ThemeMode.dark);
      expect(storage.document, contains('"mode":"dark"'));

      final next = friendsContainer(
        overrides: <Override>[themeStorageProvider.overrideWithValue(storage)],
      );
      expect(next.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('notifications', () {
    testWidgets('has a real switch for every kind, all on to begin with', (
      tester,
    ) async {
      await _pump(tester);

      for (final category in NotificationCategory.values) {
        expect(find.text(notificationCategoryLabel(category)), findsOneWidget);
      }
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      expect(switches, hasLength(NotificationCategory.values.length));
      expect(switches.every((s) => s.value), isTrue);
    });

    testWidgets('switching one off changes what the feed and bell show', (
      tester,
    ) async {
      final c = await _pump(tester);
      final before = c.read(notificationEntriesProvider).length;

      await _tap(tester, find.text('Trips'));

      expect(
        c.read(notificationsProvider).muted,
        contains(NotificationCategory.tripUpdate),
      );
      expect(c.read(notificationEntriesProvider).length, lessThan(before));
    });

    testWidgets('is honest that nothing is pushed', (tester) async {
      await _pump(tester);

      expect(
        find.textContaining("doesn't send push notifications"),
        findsOneWidget,
      );
    });
  });

  group('your data', () {
    testWidgets('says what is kept, and offers no empty "clear" button', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.textContaining('saved on this phone'), findsWidgets);
      expect(find.text('Clear my rounds'), findsNothing);
      expect(find.text('Start over'), findsOneWidget);
    });

    testWidgets('clearing rounds asks first, then clears them', (tester) async {
      final played = PlayedRounds()
        ..play(1, List<int>.filled(18, 4))
        ..play(2, List<int>.filled(18, 5));
      final c = played.container;
      await _pump(tester, container: c);
      expect(find.textContaining('2 rounds'), findsWidgets);

      await _tap(tester, find.text('Clear my rounds'));
      expect(find.text('Clear your rounds?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(c.read(roundHistoryProvider), hasLength(2));

      await _tap(tester, find.text('Clear my rounds'));
      await tester.tap(find.text('Clear rounds'));
      await tester.pumpAndSettle();

      expect(c.read(roundHistoryProvider), isEmpty);
      expect(find.text('Clear my rounds'), findsNothing);
    });

    testWidgets(
      'starting over asks first, clears everything and says to reopen',
      (tester) async {
        final data = _RecordingLocalData();
        await _pump(
          tester,
          overrides: <Override>[localDataProvider.overrideWithValue(data)],
        );

        await _tap(tester, find.text('Start over'));
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(data.cleared, 0);

        await _tap(tester, find.text('Start over'));
        await tester.tap(find.widgetWithText(FilledButton, 'Start over'));
        await tester.pumpAndSettle();

        expect(data.cleared, 1);
        expect(find.text('Fresh start'), findsOneWidget);
        expect(find.textContaining('Close Qaddy completely'), findsOneWidget);
      },
    );
  });

  group('the Sample Clubhouse', () {
    testWidgets('says what is sample, and never calls it your own', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Sample Clubhouse'), findsOneWidget);
      expect(find.textContaining('always labelled Sample'), findsOneWidget);
      expect(find.text('Remove the Sample Clubhouse'), findsOneWidget);
    });

    testWidgets('removing it asks first, then takes the samples away', (
      tester,
    ) async {
      final c = await _pump(tester);
      addTearDown(resetSampleClubhouseForTests);

      await _tap(tester, find.text('Remove the Sample Clubhouse'));
      expect(find.text('Remove the Sample Clubhouse?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(c.read(sampleClubhouseProvider).enabled, isTrue);

      await _tap(tester, find.text('Remove the Sample Clubhouse'));
      await tester.tap(find.text('Remove it'));
      await tester.pumpAndSettle();

      expect(c.read(sampleClubhouseProvider).enabled, isFalse);
      expect(c.read(friendsProvider).friends, isEmpty);
      expect(c.read(tripsProvider).trips, isEmpty);
    });

    testWidgets('it can be brought back', (tester) async {
      final c = await _pump(
        tester,
        overrides: <Override>[
          sampleStorageProvider.overrideWithValue(
            MemoryDocumentStorage(
              encodeSampleChoice(
                const SampleChoice(enabled: false, decided: true),
              ),
            ),
          ),
        ],
      );
      addTearDown(resetSampleClubhouseForTests);
      expect(
        find.text(
          "You're starting with an empty clubhouse. Bring the Sample "
          'Clubhouse back to see what Qaddy can do with mates, groups and '
          'trips.',
        ),
        findsOneWidget,
      );

      await _tap(tester, find.text('Bring back the Sample Clubhouse'));

      expect(c.read(sampleClubhouseProvider).enabled, isTrue);
      expect(c.read(friendsProvider).friends, isNotEmpty);
      expect(c.read(tripsProvider).trips, isNotEmpty);
    });
  });

  group('about', () {
    testWidgets('Privacy says plainly where the data lives', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Privacy'));

      expect(find.text('Your golf stays on your phone'), findsWidgets);
      expect(
        find.textContaining('no accounts in this release'),
        findsOneWidget,
      );
      expect(find.textContaining('Crash reports are off'), findsOneWidget);
    });

    testWidgets('About shows the version', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('About Qaddy'));

      expect(
        find.text('Version $appVersionLabel · $appReleaseLabel'),
        findsOneWidget,
      );
      expect(find.text("The golfer's ecosystem"), findsOneWidget);
    });
  });

  testWidgets('lays out on a small phone and in the light theme', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 3600));
    expect(tester.takeException(), isNull);

    await _pump(tester, theme: QaddyTheme.light);
    expect(tester.takeException(), isNull);
  });
}
