// Verifies the whole Rounds journey through the real app router: start a round,
// score it, finish it, see the results and go home.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

import '../../features/trips/trips_test_harness.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Rounds -> Start -> score -> finish -> results -> Home', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      location: '/rounds',
      size: const Size(400, 2000),
    );

    expect(find.text('My rounds'), findsOneWidget);
    await _tap(tester, find.text('Start round'));

    // On the first tee, full screen.
    expect(find.text('Hole 1'), findsOneWidget);
    expect(container.read(liveRoundProvider), isNotNull);

    // Birdie for the golfer, then play the rest of the course at par.
    await _tap(tester, find.byTooltip('Take a stroke off Tiamana'));
    expect(find.bySemanticsLabel(RegExp('^You: 3, Birdie')), findsOneWidget);
    for (var hole = 1; hole < 18; hole++) {
      await _tap(tester, find.text('Next hole'));
    }
    expect(find.text('Hole 18'), findsOneWidget);

    await _tap(tester, find.text('Finish round'));

    // The celebration.
    expect(find.textContaining('Round complete'), findsOneWidget);
    expect(find.text('Your round'), findsOneWidget);
    expect(container.read(liveRoundProvider), isNull);
    expect(container.read(completedRoundProvider)!.holesPlayed, 18);

    await _tap(tester, find.text('Back to Home'));

    expect(find.text('Your game'), findsOneWidget);
  });

  testWidgets('a round in progress can be left and returned to', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      location: '/rounds',
      size: const Size(400, 2000),
    );
    await _tap(tester, find.text('Start round'));
    await _tap(tester, find.text('Next hole'));

    // Back to the Rounds tab: it now offers to continue.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Hole 2 of 18'), findsOneWidget);

    await _tap(tester, find.text('Continue round'));
    expect(find.text('Hole 2'), findsOneWidget);
    expect(container.read(liveRoundProvider)!.currentHole, 1);
  });

  testWidgets('the Dashboard leads to the round and back', (tester) async {
    await pumpApp(tester, location: '/home', size: const Size(400, 3400));

    await _tap(tester, find.text('Get ready'));
    expect(find.text('My rounds'), findsOneWidget);

    await _tap(tester, find.text('Start round'));
    expect(find.text('Hole 1'), findsOneWidget);
  });
}
