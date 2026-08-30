// Smoke test — confirms the app boots end to end (ProviderScope, router,
// theme) without a real Supabase project configured, since AppConfig
// defaults to empty credentials until one exists (see core/config/app_config.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('QaddyApp boots and shows the placeholder home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    expect(
      find.text('Qaddy — foundations laid, features next.'),
      findsOneWidget,
    );
  });
}
