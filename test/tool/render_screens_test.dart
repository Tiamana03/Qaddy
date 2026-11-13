// A development tool, not a test: renders screens to PNG files so they can be
// laid beside their approved mockups.
//
//   QADDY_RENDER=1 flutter test test/tool/render_screens_test.dart
//
// writes build/renders/<screen>.png at 393 x 852 logical pixels, twice that
// many device pixels, with the bundled Inter and Material icon fonts (a plain
// `flutter test` draws every glyph as a box). Without QADDY_RENDER it does
// nothing, so it costs the normal test run nothing.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:qaddy/features/groups/ui/screens/groups_screen.dart';
import 'package:qaddy/features/my_bag/ui/screens/golf_bag_screen.dart';
import 'package:qaddy/features/profile/ui/screens/profile_screen.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/leaderboard_screen.dart';
import 'package:qaddy/features/rounds/ui/screens/live_scorecard_screen.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';

import '../support/app_test_harness.dart';
import '../support/played_rounds.dart';

const Size _phone = Size(393, 852);

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final file in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$file.ttf').readAsBytesSync();
    inter.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await inter.load();

  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = <String>[
    if (root != null)
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ].where((p) => File(p).existsSync());
  if (icons.isNotEmpty) {
    final material = FontLoader('MaterialIcons')
      ..addFont(
        Future<ByteData>.value(
          ByteData.sublistView(File(icons.first).readAsBytesSync()),
        ),
      );
    await material.load();
  }
}

Future<void> _render(
  WidgetTester tester,
  String name,
  Widget screen, {
  ProviderContainer? container,
  Duration settle = const Duration(seconds: 3),
  bool pushed = false,
  Future<void> Function()? interact,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _phone;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: UncontrolledProviderScope(
        container: container ?? friendsContainer(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: QaddyTheme.dark,
          home: pushed ? const Scaffold() : screen,
        ),
      ),
    ),
  );
  if (pushed) {
    // Opened from another screen, so the top bar has its back arrow.
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute<void>(builder: (_) => screen)),
    );
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(settle);
  if (interact != null) {
    await interact();
    await tester.pump(const Duration(seconds: 1));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    return (await image.toByteData(format: ui.ImageByteFormat.png))!;
  });
  File('build/renders/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

ProviderContainer _roundContainer({int players = 4, int holes = 0}) {
  final container = friendsContainer(
    overrides: <Override>[
      dashboardClockProvider.overrideWithValue(() => DateTime(2026, 11, 7, 9)),
    ],
  );
  final store = container.read(roundsProvider.notifier)
    ..startRound(
      upcomingRoundInvitees.take(players).map((i) => i.player).toList(),
    );
  for (var i = 0; i < holes; i++) {
    store.nextHole();
  }
  return container;
}

void main() {
  final enabled = Platform.environment.containsKey('QADDY_RENDER');

  setUpAll(() async {
    if (enabled) {
      await _loadFonts();
    }
  });

  testWidgets('render: live scorecard', (tester) async {
    await _render(
      tester,
      'live_scorecard',
      const LiveScorecardScreen(),
      container: _roundContainer(),
      pushed: true,
    );
  }, skip: !enabled);

  testWidgets('render: leaderboard', (tester) async {
    final container = _roundContainer(holes: 1);
    await _render(
      tester,
      'leaderboard',
      const LeaderboardScreen(),
      container: container,
      pushed: true,
    );
  }, skip: !enabled);

  testWidgets('render: my rounds', (tester) async {
    final container = friendsContainer(
      overrides: <Override>[
        dashboardClockProvider.overrideWithValue(
          () => DateTime(2026, 11, 7, 9),
        ),
      ],
    );
    container.read(roundSetupProvider.notifier)
      ..toggle('Tom')
      ..toggle('Ben')
      ..toggle('Luke');
    await _render(
      tester,
      'my_rounds',
      const RoundsScreen(),
      container: container,
    );
  }, skip: !enabled);

  testWidgets('render: my rounds, live', (tester) async {
    final container = _roundContainer(holes: 2);
    await _render(
      tester,
      'my_rounds_live',
      const RoundsScreen(),
      container: container,
    );
  }, skip: !enabled);

  testWidgets('render: my rounds, completed', (tester) async {
    final container = _roundContainer(holes: 1);
    container.read(roundsProvider.notifier).finishRound();
    await _render(
      tester,
      'my_rounds_completed',
      const RoundsScreen(),
      container: container,
      interact: () async {
        await tester.tap(find.textContaining('Completed'));
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  }, skip: !enabled);

  testWidgets('render: profile', (tester) async {
    final played = PlayedRounds()
      ..play(1, <int>[3, 5, 3, 4], partners: <String>['Tom', 'Ben', 'Luke'])
      ..play(2, <int>[5, 6, 4, 5])
      ..play(3, <int>[3, 4, 2, 4]);
    await _render(
      tester,
      'profile',
      const ProfileScreen(),
      container: played.container,
    );
  }, skip: !enabled);

  testWidgets('render: groups', (tester) async {
    await _render(tester, 'groups', const GroupsScreen());
  }, skip: !enabled);

  testWidgets('render: golf bag', (tester) async {
    await _render(tester, 'golf_bag', const GolfBagScreen(), pushed: true);
  }, skip: !enabled);

  testWidgets('render: home', (tester) async {
    await _render(
      tester,
      'home',
      const DashboardScreen(),
      container: friendsContainer(
        overrides: <Override>[
          dashboardClockProvider.overrideWithValue(
            () => DateTime(2026, 11, 7, 9),
          ),
        ],
      ),
    );
  }, skip: !enabled);
}
