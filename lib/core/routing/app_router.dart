/// Minimal routing shell — enough for the app to boot in Milestone 0.
///
/// The real navigation tree (satisfying the Design System's Three-Click
/// Rule across all eleven Release One features) is a Milestone 1 decision,
/// made once and documented there — do not grow this file feature-by-feature
/// in the meantime; add a screen's route in its own milestone alongside the
/// screen itself, and revisit the overall shape in M1.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _BootPlaceholderScreen(),
      ),
    ],
  );
});

class _BootPlaceholderScreen extends StatelessWidget {
  const _BootPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Qaddy — foundations laid, features next.')),
    );
  }
}
