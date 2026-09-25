import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/ui/screens/trip_details_screen.dart';

void main() {
  testWidgets('shows destination, countdown, members and quick actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripDetailsScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
    expect(find.text('Tiamana'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Edit Trip'), findsOneWidget);
    expect(find.text('Complete Trip'), findsOneWidget);
  });
}
