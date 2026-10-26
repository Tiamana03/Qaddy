/// Shown by any trip screen whose trip no longer exists (deleted, or a stale
/// link). Offers a way back rather than a blank page.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';

/// A full-screen "this trip is gone" state.
class TripNotFound extends StatelessWidget {
  const TripNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: Center(
        child: QaddyEmptyState(
          icon: Icons.search_off,
          title: 'Trip not found',
          message: 'This trip may have been deleted.',
          actionLabel: 'Back to Trips',
          onAction: () => context.go(AppRoutes.trips),
        ),
      ),
    );
  }
}
