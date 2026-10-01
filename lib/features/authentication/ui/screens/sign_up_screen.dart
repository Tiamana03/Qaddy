/// Qaddy's Sign Up screen.
///
/// See `docs/features/authentication-feature-integration.md` and
/// `docs/architecture/authentication-engineering-decisions.md`'s "Login and
/// Sign Up Reuse Sprint 1.3's Form Fields Exactly" and "Sign In / Create
/// Account Submit Is a Pure Navigation, Not a Validated Action". Reachable
/// only by navigating to `/signup` directly, or via Login's own link. Visual
/// only: no credential is read, validated or stored — the primary button
/// always opens Dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/authentication/ui/widgets/auth_header.dart';

/// Sign Up (route `/signup`).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: spacing.hero),
              const AuthHeader(subtitle: 'Create your account'),
              SizedBox(height: spacing.sectionGap),
              const QaddyTextField(label: 'Full Name'),
              SizedBox(height: spacing.md),
              const QaddyTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: spacing.md),
              const QaddyPasswordField(),
              SizedBox(height: spacing.sectionGap),
              QaddyPrimaryButton(
                label: 'Create Account',
                onPressed: () => context.go(AppRoutes.home),
              ),
              SizedBox(height: spacing.md),
              QaddyTertiaryButton(
                label: 'Already have an account? Sign In',
                onPressed: () => context.go(AppRoutes.login),
              ),
              SizedBox(height: spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
