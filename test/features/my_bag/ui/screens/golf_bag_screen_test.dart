import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/state/bag_controller.dart';
import 'package:qaddy/features/my_bag/ui/screens/golf_bag_screen.dart';
import 'package:qaddy/features/my_bag/ui/widgets/club_sheet.dart';
import 'package:qaddy/features/my_bag/ui/widgets/distance_ladder.dart';

class _MemoryStorage implements DocumentStorage {
  String? document;

  @override
  String? read() => document;

  @override
  Future<void> write(String document) async => this.document = document;
}

BagClub _club(ProviderContainer c, String id) =>
    c.read(bagProvider).firstWhere((club) => club.id == id);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = const Size(400, 3000),
  ThemeData? theme,
  DocumentStorage? storage,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final container = ProviderContainer(
    overrides: <Override>[
      if (storage != null) bagStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme ?? QaddyTheme.dark,
        home: const GolfBagScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('the locker', () {
    testWidgets('opens with how many clubs and how they are gapped', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('YOUR BAG'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('clubs in\nthe bag'), findsOneWidget);
      expect(find.textContaining('Nicely spread.'), findsOneWidget);
    });

    testWidgets('highlights the longest club, the go-to and the ball', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Driver 235m'), findsOneWidget);
      expect(find.text('Go-to: 7 iron'), findsOneWidget);
      expect(find.text('Titleist Pro V1'), findsWidgets);
    });

    testWidgets('has none of the old inventory tables', (tester) async {
      await _pump(tester);

      expect(find.text('Bag Summary'), findsNothing);
      expect(find.text('Total Clubs'), findsNothing);
      expect(find.text('Equipment'), findsNothing);
      expect(find.text('Club Distances'), findsNothing);
    });
  });

  group('the distance ladder', () {
    testWidgets('lists every club longest first with its carry and gap', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Your distances'), findsOneWidget);
      for (final name in <String>[
        'Driver',
        '3 wood',
        'Hybrid',
        '5 iron',
        '7 iron',
        '9 iron',
        'Pitching wedge',
        'Sand wedge',
      ]) {
        expect(find.text(name), findsWidgets, reason: name);
      }
      expect(find.text('235m'), findsOneWidget);
      expect(find.text('80m'), findsOneWidget);
      // The first club has no gap above it; the rest show one.
      expect(find.text('−20'), findsOneWidget);
      expect(find.text('−25'), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('Driver').first).dy,
        lessThan(tester.getTopLeft(find.text('Sand wedge').first).dy),
      );
    });

    testWidgets('marks the go-to club and the clubs with notes', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsWidgets);
    });

    testWidgets('has a legend for the gap colours', (tester) async {
      await _pump(tester);

      expect(find.text('Tight'), findsOneWidget);
      expect(find.text('Watch'), findsOneWidget);
      expect(find.text('A hole'), findsOneWidget);
    });

    testWidgets('bars are drawn with height', (tester) async {
      await _pump(tester);

      final bars = tester.widgetList<FractionallySizedBox>(
        find.descendant(
          of: find.byType(DistanceLadder),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(bars, hasLength(11));
      for (final bar in bars) {
        final size = tester.getSize(find.byWidget(bar));
        expect(size.height, 14);
        expect(size.width, greaterThan(0));
      }
    });
  });

  group('putter, ball and notes', () {
    testWidgets('shows the putter and the ball as their own tiles', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Putter and ball'), findsOneWidget);
      expect(find.text('Putter'), findsWidgets);
      expect(find.text('Odyssey White Hot'), findsOneWidget);
      expect(find.text('Ball'), findsOneWidget);
    });

    testWidgets('quotes the golfer back to themselves', (tester) async {
      await _pump(tester);

      expect(find.text('Notes to self'), findsOneWidget);
      expect(
        find.text('My go-to. Smooth tempo, never force it.'),
        findsOneWidget,
      );
    });
  });

  group('tuning a club', () {
    testWidgets('tapping a club opens its sheet', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('7 iron').first);

      expect(find.byType(ClubSheet), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('How far it carries'), findsOneWidget);
      expect(find.text('Go-to'), findsOneWidget);
    });

    testWidgets('the steppers move the carry and show the gaps either side', (
      tester,
    ) async {
      await _pump(tester);
      await _tap(tester, find.text('7 iron').first);

      await _tap(tester, find.text('+5'));
      await _tap(tester, find.text('+1'));

      expect(find.text('151m'), findsWidgets);
      expect(find.textContaining('shorter than your 6 iron'), findsOneWidget);
      expect(find.textContaining('longer than your 8 iron'), findsOneWidget);
    });

    testWidgets('Save keeps the edit, reorders the ladder and closes', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _tap(tester, find.text('9 iron').first);

      for (var i = 0; i < 4; i++) {
        await _tap(tester, find.text('+5'));
      }
      await _tap(tester, find.text('Save'));

      expect(find.byType(ClubSheet), findsNothing);
      expect(_club(c, '9-iron').carryMetres, 145);
      // 145 ties the 7 iron, which stays first because the bag order wins.
      expect(find.text('145m'), findsNWidgets(2));
    });

    testWidgets('confidence can be set, and cleared by tapping it again', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _tap(tester, find.text('5 iron').first);

      await _tap(tester, find.bySemanticsLabel('5 of 5, Go-to'));
      expect(find.text('Go-to'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('5 of 5, Go-to'));
      expect(find.text('Not rated'), findsOneWidget);

      await _tap(tester, find.bySemanticsLabel('2 of 5, Getting there'));
      await _tap(tester, find.text('Save'));

      expect(_club(c, '5-iron').confidence, 2);
    });

    testWidgets('a note can be written and then shows in the notes', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _tap(tester, find.text('9 iron').first);

      await tester.enterText(
        find.widgetWithText(TextField, 'Note to self'),
        'Plays a club longer into the wind',
      );
      await _tap(tester, find.text('Save'));

      expect(_club(c, '9-iron').note, 'Plays a club longer into the wind');
      expect(find.text('Plays a club longer into the wind'), findsOneWidget);
    });

    testWidgets('the model can be changed', (tester) async {
      final c = await _pump(tester);
      await _tap(tester, find.text('Driver').first);

      await tester.enterText(
        find.widgetWithText(TextField, 'Model'),
        'Ping G430',
      );
      await _tap(tester, find.text('Save'));

      expect(_club(c, 'driver').model, 'Ping G430');
    });

    testWidgets('a putter has no carry to set', (tester) async {
      await _pump(tester);
      await _tap(tester, find.text('Putter').first);

      expect(find.byType(ClubSheet), findsOneWidget);
      expect(find.text('How far it carries'), findsNothing);
      expect(find.text('+5'), findsNothing);
    });

    testWidgets('dismissing the sheet changes nothing', (tester) async {
      final c = await _pump(tester);
      await _tap(tester, find.text('7 iron').first);
      await _tap(tester, find.text('+5'));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(_club(c, '7-iron').carryMetres, 145);
    });

    testWidgets('edits are saved for the next time', (tester) async {
      final storage = _MemoryStorage();
      await _pump(tester, storage: storage);
      await _tap(tester, find.text('7 iron').first);
      await _tap(tester, find.text('+5'));
      await _tap(tester, find.text('Save'));

      expect(storage.document, contains('150'));
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode', (tester) async {
          await _pump(tester, size: Size(width, 3400), theme: theme);

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('the club sheet fits a small phone', (tester) async {
      await _pump(tester, size: const Size(320, 700));
      await _tap(tester, find.text('Driver').first);

      expect(tester.takeException(), isNull);
    });

    testWidgets('settles without animating forever', (tester) async {
      await _pump(tester);

      await tester.pumpAndSettle();
    });
  });
}
