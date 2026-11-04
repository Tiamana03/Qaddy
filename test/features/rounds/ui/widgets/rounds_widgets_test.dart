import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_banner.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_progress_strip.dart';
import 'package:qaddy/features/rounds/ui/widgets/player_score_row.dart';
import 'package:qaddy/features/rounds/ui/widgets/setup_player_tile.dart';
import 'package:qaddy/features/rounds/ui/widgets/standing_row.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: QaddyTheme.dark,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

const RoundPlayer _tom = RoundPlayer(name: 'Tom', handicap: 8);

Round _round({int currentHole = 0}) => Round.start(
  id: 'r',
  course: 'Richmond Golf Club',
  format: 'Stableford',
  holes: richmondHoles,
  players: const <RoundPlayer>[_tom],
  now: DateTime(2026, 11, 7),
).copyWith(currentHole: currentHole);

void main() {
  group('PlayerScoreRow', () {
    Widget row({
      int? gross,
      int par = 4,
      int shots = 0,
      int points = 2,
      bool isYou = false,
      ValueChanged<int>? onNudge,
    }) => _app(
      PlayerScoreRow(
        name: 'Tom',
        isYou: isYou,
        par: par,
        shots: shots,
        gross: gross,
        points: points,
        onNudge: onNudge ?? (_) {},
      ),
    );

    testWidgets('shows par until a score is recorded', (tester) async {
      await tester.pumpWidget(row());

      expect(find.text('4'), findsOneWidget);
      expect(find.text('Par'), findsOneWidget);
      expect(find.text('2 pts'), findsOneWidget);
    });

    testWidgets('names the score and the shots received', (tester) async {
      await tester.pumpWidget(row(gross: 3, shots: 1, points: 4));

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Birdie'), findsOneWidget);
      expect(find.text('4 pts · +1 shot'), findsOneWidget);
    });

    testWidgets('calls onNudge with +1 and -1', (tester) async {
      final nudges = <int>[];
      await tester.pumpWidget(row(onNudge: nudges.add));

      await tester.tap(find.byTooltip('Add a stroke for Tom'));
      await tester.tap(find.byTooltip('Take a stroke off Tom'));

      expect(nudges, <int>[1, -1]);
    });

    testWidgets('says "You" for the golfer', (tester) async {
      await tester.pumpWidget(row(isYou: true));

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Tom'), findsNothing);
    });

    testWidgets('a picked-up hole shows a dash and cannot go lower', (
      tester,
    ) async {
      await tester.pumpWidget(row(gross: 0, points: 0));

      expect(find.text('–'), findsOneWidget);
      expect(find.text('Picked up'), findsOneWidget);
      final minus = find.ancestor(
        of: find.byTooltip('Take a stroke off Tom'),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(minus).onPressed, isNull);
    });

    testWidgets('a birdie plays a short celebration and then settles', (
      tester,
    ) async {
      await tester.pumpWidget(row(gross: 4));
      await tester.pumpWidget(row(gross: 3, points: 3));
      await tester.pump(const Duration(milliseconds: 300));

      // Mid-celebration it is glowing; pumpAndSettle proves it ends.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('with reduced motion there is nothing to wait for', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          PlayerScoreRow(
            name: 'Tom',
            isYou: false,
            par: 4,
            shots: 0,
            gross: 4,
            points: 2,
            onNudge: (_) {},
          ),
          reduceMotion: true,
        ),
      );
      await tester.pumpWidget(
        _app(
          PlayerScoreRow(
            name: 'Tom',
            isYou: false,
            par: 4,
            shots: 0,
            gross: 3,
            points: 3,
            onNudge: (_) {},
          ),
          reduceMotion: true,
        ),
      );

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('HoleProgressStrip', () {
    testWidgets('marks played, current and coming holes', (tester) async {
      final round = _round(currentHole: 2);
      final played = round.copyWith(
        scores: <String, List<int?>>{
          'Tom': <int?>[4, 5, ...List<int?>.filled(16, null)],
        },
      );
      await tester.pumpWidget(
        _app(HoleProgressStrip(round: played, onSelect: (_) {})),
      );

      expect(find.bySemanticsLabel('Hole 1, scored'), findsOneWidget);
      expect(find.bySemanticsLabel('Hole 3, current hole'), findsOneWidget);
      expect(find.bySemanticsLabel('Hole 4, not played yet'), findsOneWidget);
    });

    testWidgets('tapping a hole reports its index', (tester) async {
      final picked = <int>[];
      await tester.pumpWidget(
        _app(HoleProgressStrip(round: _round(), onSelect: picked.add)),
      );

      await tester.tap(find.bySemanticsLabel('Hole 3, not played yet'));

      expect(picked, <int>[2]);
    });

    testWidgets('scrolls the current hole into view', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          HoleProgressStrip(round: _round(currentHole: 15), onSelect: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Hole 16, current hole'), findsOneWidget);
    });
  });

  group('HoleBanner', () {
    testWidgets('gives the number, par, length and index', (tester) async {
      await tester.pumpWidget(
        _app(HoleBanner(hole: richmondHoles[6], total: 18)),
      );

      expect(find.text('Front nine · Hole 7 of 18'), findsOneWidget);
      expect(find.text('Par 4'), findsOneWidget);
      expect(find.text('364 m · SI 9'), findsOneWidget);
    });

    testWidgets('says back nine from the tenth, and flags a side game', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(HoleBanner(hole: richmondHoles[11], total: 18)),
      );

      expect(find.text('Back nine · Hole 12 of 18'), findsOneWidget);
      expect(find.text('Nearest the Pin on this hole'), findsOneWidget);
    });
  });

  group('StandingRow', () {
    PlayerStanding standing({String position = '1', bool leader = true}) =>
        PlayerStanding(
          player: _tom,
          position: position,
          isLeader: leader,
          points: 24,
          gross: 40,
          toPar: 2,
          birdies: 1,
        );

    testWidgets('shows position, name, points and progress', (tester) async {
      await tester.pumpWidget(
        _app(
          StandingRow(
            standing: standing(),
            isYou: false,
            leaderPoints: 24,
            holesPlayed: 9,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('+2 · 40 strokes'), findsOneWidget);
    });

    testWidgets('says "Not started" before a hole is played', (tester) async {
      await tester.pumpWidget(
        _app(
          StandingRow(
            standing: standing(),
            isYou: true,
            leaderPoints: 0,
            holesPlayed: 0,
          ),
        ),
      );

      expect(find.text('Not started'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });
  });

  group('SetupPlayerTile', () {
    Widget tile({
      bool isYou = false,
      bool included = true,
      bool confirmed = true,
      VoidCallback? onToggle,
    }) => _app(
      SetupPlayerTile(
        player: _tom,
        isYou: isYou,
        included: included,
        confirmed: confirmed,
        onToggle: onToggle ?? () {},
      ),
    );

    testWidgets('tapping toggles a friend', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(tile(onToggle: () => toggles++));

      await tester.tap(find.text('Tom'));

      expect(toggles, 1);
      expect(find.text('Sample mate · HCP 8'), findsOneWidget);
    });

    testWidgets('the golfer cannot be toggled', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(tile(isYou: true, onToggle: () => toggles++));

      await tester.tap(find.text('You'));

      expect(toggles, 0);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('someone yet to reply is labelled', (tester) async {
      await tester.pumpWidget(tile(included: false, confirmed: false));

      expect(
        find.text('Sample mate · HCP 8 · Waiting to reply'),
        findsOneWidget,
      );
    });
  });
}
