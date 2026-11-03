// The promise of the identity pass: once a golfer has said who they are, no
// screen calls them by the placeholder golfer's name. This walks every screen
// of the real app with a golfer called Zed, with rounds played and a round in
// progress, and fails on the first "Tiamana" it can read.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/main.dart';

import '../support/memory_document_storage.dart';
import '../support/played_rounds.dart';

const _trip = '/trips/melbourne-golf-weekend';

const _routes = <String>[
  '/home',
  '/home/search',
  '/home/notifications',
  '/rounds',
  '/rounds/scorecard',
  '/rounds/leaderboard',
  '/rounds/complete',
  '/trips',
  _trip,
  '$_trip/planning',
  '$_trip/flights',
  '$_trip/accommodation',
  '$_trip/transport',
  '$_trip/golf',
  '$_trip/expenses',
  '$_trip/chat',
  '$_trip/complete',
  '$_trip/invite',
  '$_trip/settings',
  '$_trip/edit',
  '$_trip/export',
  '/trips/create',
  '/friends',
  '/friends/list',
  '/friends/profile',
  '/friends/rivalries',
  '/friends/activity',
  '/friends/requests',
  '/friends/search',
  '/friends/groups',
  '/friends/groups/saturday-boys',
  '/friends/groups/wednesday-warriors',
  '/profile',
  '/profile/statistics',
  '/profile/bag',
  '/profile/settings',
];

void main() {
  testWidgets('no screen calls the golfer by the placeholder name', (
    tester,
  ) async {
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
    addTearDown(resetGolferForTests);
    final golfer = MemoryDocumentStorage(encodeGolfer(zed));
    final played =
        PlayedRounds(
            overrides: <Override>[
              golferStorageProvider.overrideWithValue(golfer),
            ],
          )
          ..play(1, List<int>.filled(18, 4))
          ..play(2, List<int>.filled(18, 5));
    final container = played.container;
    // A round in progress too, for the scorecard and the leaderboard.
    container
        .read(roundsProvider.notifier)
        .startRound(container.read(selectedPlayersProvider));

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const QaddyApp()),
    );
    await tester.pumpAndSettle();

    final leaks = <String>[];
    for (final route in _routes) {
      container.read(appRouterProvider).go(route);
      await tester.pumpAndSettle();
      final found = find.textContaining('Tiamana', findRichText: true);
      for (final element in found.evaluate()) {
        final widget = element.widget;
        final text = widget is Text
            ? (widget.data ?? widget.textSpan?.toPlainText())
            : widget is RichText
            ? widget.text.toPlainText()
            : '$widget';
        leaks.add('$route: "$text"');
      }
    }

    expect(leaks, isEmpty, reason: 'These screens still say Tiamana: $leaks');
  });
}
