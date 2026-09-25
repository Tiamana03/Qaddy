import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_chat_screen.dart';

void main() {
  testWidgets('shows every placeholder chat message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripChatScreen()),
    );

    expect(find.text('Looking forward to this trip!'), findsOneWidget);
    expect(find.text("Can't wait."), findsOneWidget);
    expect(find.text('See everyone Saturday morning.'), findsOneWidget);
    expect(find.text('7:12 PM'), findsOneWidget);
  });
}
