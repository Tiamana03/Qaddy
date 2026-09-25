/// Qaddy's Accommodation screen.
///
/// See `docs/features/trips-feature-integration.md`'s "Accommodation"
/// section ("Displays: Hotel, Check-in, Check-out, Address, Contact
/// information").
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Accommodation (route `/trips/accommodation`).
class TripAccommodationScreen extends StatelessWidget {
  const TripAccommodationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    const accommodation = melbourneGolfWeekendAccommodation;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Accommodation')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: accommodation.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TripInfoRow(label: 'Check In', value: accommodation.checkIn),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(
                    label: 'Check Out',
                    value: accommodation.checkOut,
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Address', value: accommodation.address),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Contact', value: accommodation.contact),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
