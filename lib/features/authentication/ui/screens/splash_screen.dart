/// Qaddy's Splash screen — the first screen in the Authentication flow.
///
/// See `docs/features/authentication-feature-integration.md`. Reuses
/// `QaddyFullScreenLoader` exactly as Sprint 1.3 built it. Not part of the
/// app's boot sequence — reachable only by navigating to `/` directly, per
/// `docs/architecture/authentication-engineering-decisions.md`'s "This Flow
/// Is Not the App's Boot Sequence". Visual only: advances to Onboarding
/// automatically after a fixed delay, no user interaction possible.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/widgets/loaders/qaddy_full_screen_loader.dart';

/// Splash (route `/`).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _advanceDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Future.delayed(_advanceDelay, () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const QaddyFullScreenLoader(message: 'Loading your golf world…');
  }
}
