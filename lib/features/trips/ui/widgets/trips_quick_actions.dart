/// The Trips screen's quick actions — Create Trip and Browse Trips.
///
/// See `docs/sprints/sprint-03-01-trips-foundation.md`'s "Quick Actions"
/// section and `docs/features/trips-feature-integration.md`'s Button
/// Behaviour table ("Create Trip | Open Trip Details") — per that table's
/// "Buttons should never remain disabled once the feature is integrated",
/// both actions are wired by the caller rather than left inert.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';

/// Create Trip and Browse Trips actions.
class TripsQuickActions extends StatelessWidget {
  const TripsQuickActions({
    required this.onCreateTrip,
    required this.onBrowseTrips,
    super.key,
  });

  /// Called when "Create Trip" is tapped.
  final VoidCallback onCreateTrip;

  /// Called when "Browse Trips" is tapped.
  final VoidCallback onBrowseTrips;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Row(
      children: <Widget>[
        Expanded(
          child: QaddyPrimaryButton(
            label: 'Create Trip',
            onPressed: onCreateTrip,
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: QaddySecondaryButton(
            label: 'Browse Trips',
            onPressed: onBrowseTrips,
          ),
        ),
      ],
    );
  }
}
