import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_card_grid.dart';

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1000);
  await tester.pumpWidget(
    MaterialApp(
      theme: QaddyTheme.dark,
      home: const Scaffold(
        body: TripCardGrid(
          children: <Widget>[Text('A'), Text('B'), Text('C'), Text('D')],
        ),
      ),
    ),
  );
}

int _rows(WidgetTester tester) => <double>{
  for (final label in <String>['A', 'B', 'C', 'D'])
    tester.getTopLeft(find.text(label)).dy,
}.length;

void main() {
  testWidgets('uses 1 column on mobile, 2 on tablet and 3 on desktop', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400);
    expect(_rows(tester), 4);

    await _pumpAtWidth(tester, 700);
    expect(_rows(tester), 2);

    await _pumpAtWidth(tester, 1200);
    expect(_rows(tester), 2);
    expect(
      tester.getTopLeft(find.text('D')).dx,
      tester.getTopLeft(find.text('A')).dx,
    );
  });
}
