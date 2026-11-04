import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_bottom_nav.dart';

const List<QaddyNavDestination> _destinations = <QaddyNavDestination>[
  QaddyNavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  QaddyNavDestination(
    label: 'Rounds',
    icon: Icons.flag_outlined,
    activeIcon: Icons.flag,
  ),
  QaddyNavDestination(
    label: 'Trips',
    icon: Icons.work_outline,
    activeIcon: Icons.work,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  int current = 0,
  ValueChanged<int>? onSelected,
}) => tester.pumpWidget(
  MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(
      bottomNavigationBar: QaddyBottomNav(
        destinations: _destinations,
        currentIndex: current,
        onSelected: onSelected ?? (_) {},
      ),
    ),
  ),
);

void main() {
  testWidgets('shows every destination, outlined until active', (tester) async {
    await _pump(tester, current: 1);

    for (final label in <String>['Home', 'Rounds', 'Trips']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.work_outline), findsOneWidget);
  });

  testWidgets('the active item is gold (accent) and the others are quiet', (
    tester,
  ) async {
    await _pump(tester, current: 2);
    const colours = QaddyColours.dark;

    Color? colourOf(String label) =>
        tester.widget<Text>(find.text(label)).style?.color;

    expect(colourOf('Trips'), colours.accent);
    expect(colourOf('Home'), colours.textTertiary);
    expect(colourOf('Rounds'), colours.textTertiary);
  });

  testWidgets('only the active item has the indicator', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    final indicators = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final widths = <double?>[
      for (final c in indicators) c.constraints?.maxWidth,
    ];
    expect(widths.where((w) => w != null && w > 0), hasLength(1));
  });

  testWidgets('tapping a destination reports its index', (tester) async {
    final taps = <int>[];
    await _pump(tester, onSelected: taps.add);

    await tester.tap(find.text('Trips'));
    await tester.tap(find.text('Home'));

    expect(taps, <int>[2, 0]);
  });

  testWidgets('is read out as selectable buttons', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, current: 1);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Rounds')),
      matchesSemantics(
        label: 'Rounds',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
