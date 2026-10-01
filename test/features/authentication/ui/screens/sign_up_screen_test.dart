import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/authentication/ui/screens/login_screen.dart';
import 'package:qaddy/features/authentication/ui/screens/sign_up_screen.dart';

void main() {
  testWidgets('shows Create Account fields and links back to Login', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.signUp,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.signUp,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Qaddy'), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(QaddyPasswordField), findsOneWidget);

    await tester.tap(find.text('Already have an account? Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
