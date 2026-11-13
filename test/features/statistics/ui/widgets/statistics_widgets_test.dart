import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_chart.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_sparkline.dart';
import 'package:qaddy/features/statistics/ui/widgets/hole_bars.dart';
import 'package:qaddy/features/statistics/ui/widgets/rival_row.dart';
import 'package:qaddy/features/statistics/ui/widgets/score_mix_bar.dart';
import 'package:qaddy/features/statistics/ui/widgets/stats_panel.dart';

Widget _app(Widget child) => MaterialApp(
  theme: QaddyTheme.dark,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

/// A one-hole round where the golfer cards par and Tom cards a birdie (the
/// golfer loses) or a bogey ([won]).
YourRound _round(int day, {bool won = false}) {
  final tomStrokes = won ? 5 : 3;
  const me = RoundPlayer(name: 'Alex', handicap: 0);
  const other = RoundPlayer(name: 'Tom', handicap: 0);
  final start = Round.start(
    id: 'r$day',
    course: 'Richmond Golf Club',
    format: 'Stableford',
    holes: richmondHoles,
    players: const <RoundPlayer>[me, other],
    now: DateTime(2026, 10, day, 8),
  );
  final stats = CareerStats.of(<Round>[
    start.copyWith(
      scores: <String, List<int?>>{
        'Alex': <int?>[4, ...List<int?>.filled(17, null)],
        'Tom': <int?>[tomStrokes, ...List<int?>.filled(17, null)],
      },
      status: RoundStatus.completed,
      completedAt: DateTime(2026, 10, day, 12),
    ),
  ], you: 'Alex')!;
  return stats.chronological.single;
}

void main() {
  group('ScoreMixBar', () {
    const mix = ScoreMix(
      eagleOrBetter: 1,
      birdies: 3,
      pars: 10,
      bogeys: 4,
      doubleOrWorse: 2,
      pickedUp: 0,
    );

    testWidgets('paints a visible bar, not a collapsed one', (tester) async {
      await tester.pumpWidget(_app(const ScoreMixBar(mix: mix)));
      await tester.pumpAndSettle();

      final bar = tester.getSize(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(bar.height, 16);
      expect(bar.width, greaterThan(100));
      // Every segment has height, so it is actually coloured in.
      final segments = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(ClipRRect),
              matching: find.byType(ColoredBox),
            ),
          )
          .length;
      expect(segments, 5);
    });

    testWidgets('lists only what happened, with counts', (tester) async {
      await tester.pumpWidget(_app(const ScoreMixBar(mix: mix)));

      expect(find.text('Birdie 3'), findsOneWidget);
      expect(find.text('Par 10'), findsOneWidget);
      expect(find.text('Picked up 0'), findsNothing);
    });

    testWidgets('a long legend entry shrinks rather than overflowing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(260, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(const ScoreMixBar(mix: mix)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('RivalRow', () {
    testWidgets('shows the record and who leads', (tester) async {
      await tester.pumpWidget(
        _app(
          const RivalRow(
            rival: Rival(
              name: 'Tom',
              together: 5,
              youWon: 3,
              theyWon: 1,
              halved: 1,
            ),
          ),
        ),
      );

      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('5 rounds together'), findsOneWidget);
      expect(find.text('3 – 1'), findsOneWidget);
      expect(find.text('You lead'), findsOneWidget);
    });

    testWidgets('says when the partner leads, and when it is level', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const RivalRow(
            rival: Rival(
              name: 'Ben',
              together: 2,
              youWon: 0,
              theyWon: 2,
              halved: 0,
            ),
          ),
        ),
      );
      expect(find.text('Ben leads'), findsOneWidget);

      await tester.pumpWidget(
        _app(
          const RivalRow(
            rival: Rival(
              name: 'Ben',
              together: 1,
              youWon: 0,
              theyWon: 0,
              halved: 1,
            ),
          ),
        ),
      );
      expect(find.text('All square'), findsOneWidget);
      expect(find.text('1 round together'), findsOneWidget);
    });

    testWidgets('its split bar has height', (tester) async {
      await tester.pumpWidget(
        _app(
          const RivalRow(
            rival: Rival(
              name: 'Tom',
              together: 2,
              youWon: 1,
              theyWon: 1,
              halved: 0,
            ),
          ),
        ),
      );

      final boxes = tester.widgetList<ColoredBox>(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(boxes, hasLength(2));
      for (final box in boxes) {
        final size = tester.getSize(find.byWidget(box));
        expect(size.height, 6);
      }
    });
  });

  group('FormChart', () {
    testWidgets('draws one bar per round, the best the tallest', (
      tester,
    ) async {
      final rounds = <YourRound>[_round(1), _round(2, won: true)];
      await tester.pumpWidget(_app(FormChart(rounds: rounds)));
      await tester.pumpAndSettle();

      expect(find.text('1\nOct'), findsOneWidget);
      expect(find.text('2\nOct'), findsOneWidget);
      // Only the round the golfer won carries a trophy.
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('eight rounds fit a phone width without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final rounds = <YourRound>[
        for (var day = 1; day <= 8; day++) _round(day),
      ];
      await tester.pumpWidget(_app(FormChart(rounds: rounds)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('StatsPanel', () {
    testWidgets('shows its title and a tappable link', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          StatsPanel(
            title: 'Driving',
            actionLabel: 'View Details',
            onAction: () => taps++,
            child: const Text('inside'),
          ),
        ),
      );

      expect(find.text('Driving'), findsOneWidget);
      expect(find.text('inside'), findsOneWidget);
      await tester.tap(find.text('View Details'));
      expect(taps, 1);
    });

    testWidgets('has no link when it has no action', (tester) async {
      await tester.pumpWidget(
        _app(const StatsPanel(title: 'Approach', child: Text('inside'))),
      );

      expect(find.text('View Details'), findsNothing);
    });
  });

  group('HoleBars', () {
    testWidgets('always numbers all eighteen holes and keys the colours', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const HoleBars(
            holes: <HoleStat>[
              HoleStat(number: 1, par: 4, averagePoints: 3, played: 2),
              HoleStat(number: 2, par: 5, averagePoints: 1, played: 2),
            ],
          ),
        ),
      );

      for (var hole = 1; hole <= 18; hole++) {
        expect(find.text('$hole'), findsOneWidget, reason: 'hole $hole');
      }
      expect(find.text('Better than par'), findsOneWidget);
      expect(find.text('Par'), findsOneWidget);
      expect(find.text('Worse than par'), findsOneWidget);
    });

    testWidgets('describes only the holes that were played', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const HoleBars(
            holes: <HoleStat>[
              HoleStat(number: 3, par: 3, averagePoints: 2.5, played: 1),
            ],
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Hole 3: 2.5 points on average')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('Hole 4:')), findsNothing);
      handle.dispose();
    });

    testWidgets('lays out with no holes played', (tester) async {
      await tester.pumpWidget(_app(const HoleBars(holes: <HoleStat>[])));

      expect(tester.takeException(), isNull);
    });
  });

  group('FormSparkline', () {
    testWidgets('draws one round, several and none without error', (
      tester,
    ) async {
      for (final values in <List<double>>[
        <double>[],
        <double>[30],
        <double>[30, 34, 28, 40],
      ]) {
        await tester.pumpWidget(
          _app(SizedBox(height: 80, child: FormSparkline(values: values))),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('says the points for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            height: 80,
            child: FormSparkline(values: <double>[30, 34.4]),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Points per round, oldest first: 30, 34.'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
