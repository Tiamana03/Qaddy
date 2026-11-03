/// Qaddy's Login screen.
///
/// See `docs/features/launch-experience.md`. Release 1 has no accounts, and the
/// screen says so up front rather than pretending: the fields are checked like
/// any sign-in form, but a valid submit explains that accounts open after the
/// soft launch and offers the guest way in. Nothing typed is stored or sent.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/forms/qaddy_password_field.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/authentication/logic/auth_validation.dart';
import 'package:qaddy/features/authentication/ui/widgets/accounts_notice.dart';
import 'package:qaddy/features/authentication/ui/widgets/launch_scaffold.dart';

/// Login (route `/login`).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Errors only show once the golfer has tried to sign in.
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _emailError => _submitted ? validateEmail(_email.text) : null;

  String? get _passwordError =>
      _submitted ? validateSignInPassword(_password.text) : null;

  void _submit() {
    setState(() => _submitted = true);
    if (validateEmail(_email.text) == null &&
        validateSignInPassword(_password.text) == null) {
      FocusScope.of(context).unfocus();
      showAccountsSoonSheet(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LaunchScaffold(
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.onboarding),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colours = theme.extension<QaddyColours>()!;
          final spacing = theme.extension<QaddySpacing>()!;
          final typography = theme.extension<QaddyTypography>()!;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggered(<Widget>[
                SizedBox(height: spacing.xl),
                const Center(child: QaddyMark(size: 72)),
                SizedBox(height: spacing.lg),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: typography.h1.copyWith(color: colours.textPrimary),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Sign in to your Qaddy account',
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
                SizedBox(height: spacing.xl),
                const AccountsNotice(),
                SizedBox(height: spacing.lg),
                QaddyTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.mail_outline),
                  errorText: _emailError,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: spacing.md),
                QaddyPasswordField(
                  controller: _password,
                  errorText: _passwordError,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: spacing.lg),
                QaddyGoldButton(
                  label: 'Sign in',
                  tall: true,
                  onPressed: _submit,
                ),
                SizedBox(height: spacing.sm),
                QaddySecondaryButton(
                  label: 'Continue as guest',
                  onPressed: () => enterAsGuest(context, ref),
                ),
                SizedBox(height: spacing.xs),
                QaddyTertiaryButton(
                  label: 'New to Qaddy? Create an account',
                  onPressed: () => context.pushReplacement(AppRoutes.signUp),
                ),
                SizedBox(height: spacing.xl),
              ]),
            ),
          );
        },
      ),
    );
  }
}
