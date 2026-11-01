import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_chart.dart';
import 'package:qaddy/features/statistics/ui/widgets/rival_row.dart';
import 'package:qaddy/features/statistics/ui/widgets/score_mix_bar.dart';

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
}
