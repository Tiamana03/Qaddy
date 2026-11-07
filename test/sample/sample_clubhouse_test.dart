// The promise of the Sample Clubhouse: the app never pretends Tom, Ben or the
// Saturday Boys are real unless the golfer made them.
//
// Without it, no screen shows any sample person, group, trip, course or plan.
// With it, every screen that shows sample content says Sample.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/main.dart';

import '../support/memory_document_storage.dart';
import '../support/played_rounds.dart';

/// Screens a golfer with an empty clubhouse can reach.
const _emptyRoutes = <String>[
  '/home',
  '/home/search',
  '/home/notifications',
  '/rounds',
  '/rounds/scorecard',
  '/rounds/leaderboard',
  '/rounds/complete',
  '/trips',
  '/trips/create',
  '/friends',
  '/friends/list',
  '/friends/activity',
  '/friends/requests',
  '/friends/search',
  '/friends/groups',
  '/profile',
  '/profile/statistics',
  '/profile/bag',
  '/profile/settings',
];

/// Screens that show sample content, and so must say so.
const _sampleRoutes = <String>[
  '/home',
  '/home/search',
  '/home/notifications',
  '/rounds',
  '/friends',
  '/friends/list',
  '/friends/profile',
  '/friends/rivalries',
  '/friends/groups',
  '/friends/groups/saturday-boys',
  '/trips',
  '/trips/melbourne-golf-weekend',
];

/// Things only the sample world has.
const _sampleWords = <String>[
  'Tom',
  'Ben',
  'Luke',
  'Josh',
  'Nick',
  'Liam',
  'Jack',
  'Saturday Boys',
  'Wednesday Warriors',
  'Friday Social',
  'Family Golf',
  'Melbourne',
  'Gold Coast',
  'Tasmania',
  'Queenstown',
  'Richmond',
  'Kingston Heath',
];

Future<ProviderContainer> _open(
  WidgetTester tester, {
  required bool sample,
  bool playedRounds = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 3000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final zed = GolferProfile(
    firstName: 'Zed',
    handicap: 12.4,
    homeCourse: 'Zedmoor Links',
    joinedAt: DateTime(2026, 11),
  );
  // As `main` does, before any seeded data is read.
  useGolfer(zed);
  useSampleClubhouse(on: sample);
  addTearDown(resetGolferForTests);
  addTearDown(resetSampleClubhouseForTests);

  final played = PlayedRounds(
    overrides: <Override>[
      golferStorageProvider.overrideWithValue(
        MemoryDocumentStorage(encodeGolfer(zed)),
      ),
      sampleStorageProvider.overrideWithValue(
        MemoryDocumentStorage(
          encodeSampleChoice(SampleChoice(enabled: sample, decided: true)),
        ),
      ),
    ],
  );
  if (playedRounds) {
    played
      ..play(1, List<int>.filled(18, 4), partners: const <String>[])
      ..play(2, List<int>.filled(18, 5), partners: const <String>[]);
  }
  final container = played.container;
  container
      .read(roundsProvider.notifier)
      .startRound(container.read(selectedPlayersProvider));

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const QaddyApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

String _everyWord(WidgetTester tester) {
  final words = StringBuffer();
  for (final element in find.byType(Text).evaluate()) {
    final widget = element.widget as Text;
    words
      ..write(widget.data ?? widget.textSpan?.toPlainText() ?? '')
      ..write(' | ');
  }
  for (final element in find.byType(RichText).evaluate()) {
    words
      ..write((element.widget as RichText).text.toPlainText())
      ..write(' | ');
  }
  return words.toString();
}

void main() {
  testWidgets('with it off, no screen shows anything sample', (tester) async {
    final c = await _open(tester, sample: false, playedRounds: true);

    final leaks = <String>[];
    for (final route in _emptyRoutes) {
      c.read(appRouterProvider).go(route);
      await tester.pumpAndSettle();
      final text = _everyWord(tester);
      for (final word in _sampleWords) {
        if (RegExp('\\b$word\\b').hasMatch(text)) {
          leaks.add('$route: "$word" in "${_around(text, word)}"');
        }
      }
      // Settings is where it is managed, so it may mention it.
      if (route != '/profile/settings' &&
          text.toLowerCase().contains('sample')) {
        // The Rounds layout caption and the empty states are honest about it.
        final allowed =
            text.contains('sample 18-hole layout') ||
            text.toLowerCase().contains('sample clubhouse');
        final others = RegExp(
          'sample',
          caseSensitive: false,
        ).allMatches(text).length;
        if (!allowed || others > 2) {
          leaks.add('$route: says "sample"');
        }
      }
    }

    expect(leaks, isEmpty, reason: 'Sample content still shows: $leaks');
  });

  testWidgets('with it on, every screen that shows sample content says so', (
    tester,
  ) async {
    final c = await _open(tester, sample: true);

    final unlabelled = <String>[];
    for (final route in _sampleRoutes) {
      c.read(appRouterProvider).go(route);
      await tester.pumpAndSettle();
      if (!_everyWord(tester).toLowerCase().contains('sample')) {
        unlabelled.add(route);
      }
    }

    expect(unlabelled, isEmpty, reason: 'Not labelled Sample: $unlabelled');
  });

  testWidgets('the golfer is never the sample', (tester) async {
    final c = await _open(tester, sample: false);

    expect(currentUserDisplayName, 'Zed');
    expect(c.read(roundSetupProvider), <String>{currentUserName});
  });
}

/// A little of the text either side of [word], to say where it was found.
String _around(String text, String word) {
  final at = text.indexOf(word);
  return text.substring(
    (at - 60).clamp(0, text.length),
    (at + 60).clamp(0, text.length),
  );
}
