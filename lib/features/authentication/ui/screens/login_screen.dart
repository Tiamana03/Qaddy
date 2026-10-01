/// Qaddy's Login screen — the final screen in the Authentication flow.
///
/// See `docs/features/authentication-feature-integration.md` and
/// `docs/architecture/authentication-engineering-decisions.md`'s "Login
/// Reuses Sprint 1.3's Form Fields Exactly" and "Sign In / Create Account
/// Submit Is a Pure Navigation, Not a Validated Action". Reachable only by
/// navigating to `/login` directly. Visual only: no credential is read,
/// validated or stored — the primary button always opens Dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

/// Login (route `/login`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isCreatingAccount = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: spacing.hero),
              Text(
                'Qaddy',
                textAlign: TextAlign.center,
                style: typography.h1.copyWith(color: colours.gold),
              ),
              SizedBox(height: spacing.sm),
              Text(
                _isCreatingAccount
                    ? 'Create your account'
                    : 'Sign in to continue',
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
              SizedBox(height: spacing.sectionGap),
              if (_isCreatingAccount) ...<Widget>[
                const QaddyTextField(label: 'Full Name'),
                SizedBox(height: spacing.md),
              ],
              const QaddyTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: spacing.md),
              const QaddyPasswordField(),
              SizedBox(height: spacing.sectionGap),
              QaddyPrimaryButton(
                label: _isCreatingAccount ? 'Create Account' : 'Sign In',
                onPressed: () => context.go(AppRoutes.home),
              ),
              SizedBox(height: spacing.md),
              QaddyTertiaryButton(
                label: _isCreatingAccount
                    ? 'Already have an account? Sign In'
                    : "Don't have an account? Create one",
                onPressed: () =>
                    setState(() => _isCreatingAccount = !_isCreatingAccount),
              ),
              SizedBox(height: spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
