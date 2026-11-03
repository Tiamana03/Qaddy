/// Qaddy's Splash screen — the first moment: the mark draws itself, the name
/// and promise fade in, and the golfer is taken where they belong: the
/// introduction the first time, straight into the app after that.
///
/// See `docs/features/launch-experience.md`.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/widgets/launch_scaffold.dart';

/// How long the splash is shown.
const Duration splashDuration = Duration(milliseconds: 1900);

/// How long it is shown when the golfer has asked for reduced motion.
const Duration splashReducedMotionDuration = Duration(milliseconds: 600);

/// Splash (route `/`).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer ??= Timer(
      MediaQuery.disableAnimationsOf(context)
          ? splashReducedMotionDuration
          : splashDuration,
      _advance,
    );
  }

  void _advance() {
    if (!mounted) {
      return;
    }
    final seen = ref.read(sessionProvider).onboardingComplete;
    final known = ref.read(golferProvider) != null;
    context.go(
      !seen
          ? AppRoutes.onboarding
          : known
          ? AppRoutes.home
          : AppRoutes.setup,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LaunchScaffold(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colours = theme.extension<QaddyColours>()!;
          final spacing = theme.extension<QaddySpacing>()!;
          final typography = theme.extension<QaddyTypography>()!;
          final animate = !MediaQuery.disableAnimationsOf(context);

          Widget fadeIn(Widget child, {required int delayMs}) =>
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
                duration: Duration(milliseconds: animate ? 700 + delayMs : 1),
                curve: Interval(
                  delayMs / (700 + delayMs),
                  1,
                  curve: Curves.easeOut,
                ),
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - t)),
                    child: child,
                  ),
                ),
                child: child,
              );

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const QaddyMark(size: 120),
                SizedBox(height: spacing.xl),
                fadeIn(
                  Text(
                    'Qaddy',
                    style: typography.display.copyWith(
                      color: colours.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  delayMs: 500,
                ),
                SizedBox(height: spacing.sm),
                fadeIn(
                  Text(
                    "The golfer's ecosystem",
                    style: typography.body.copyWith(
                      color: colours.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  delayMs: 800,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
