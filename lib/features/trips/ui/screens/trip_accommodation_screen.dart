/// Qaddy's Accommodation screen — where the group is staying: dates, contact
/// details, booking number, who is in which room and what it costs each.
///
/// See `docs/features/trips-feature-integration.md`'s "Accommodation"
/// section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Accommodation (route `/trips/:tripId/accommodation`).
class TripAccommodationScreen extends ConsumerWidget {
  const TripAccommodationScreen({required this.tripId, super.key});

  /// The trip whose accommodation is shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final stays = <TripAccommodation>[...plan.accommodations]
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.accommodation.slug,
      'new',
    );

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Accommodation'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Accommodation',
            onPressed: () => context.push(addRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            if (stays.isEmpty)
              QaddyEmptyState(
                icon: Icons.hotel_outlined,
                title: 'No accommodation yet',
                message:
                    'Add where you are staying — check-in times, room '
                    'allocation and the cost per person.',
                actionLabel: 'Add Accommodation',
                onAction: () => context.push(addRoute),
              )
            else ...<Widget>[
              for (final (index, stay) in stays.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.sectionGap),
                _StayDetail(tripId: tripId, stay: stay),
              ],
              SizedBox(height: spacing.sectionGap),
              QaddyPrimaryButton(
                label: 'Add Accommodation',
                onPressed: () => context.push(addRoute),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _StayDetail extends ConsumerWidget {
  const _StayDetail({required this.tripId, required this.stay});

  final String tripId;
  final TripAccommodation stay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final nights = stay.nights;
    final cost = stay.totalCost;
    final perGuest = stay.costPerGuest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DetailHeader(
          icon: Icons.hotel_outlined,
          title: stay.name,
          subtitle: stay.address.isEmpty ? null : stay.address,
          facts: <String>[
            stay.checkIn.toFriendlyRange(stay.checkOut),
            '$nights ${nights == 1 ? 'night' : 'nights'}',
            if (stay.guests.isNotEmpty) '${stay.guests.length} guests',
          ],
        ),
        const DetailSectionTitle('Stay'),
        QaddyCard(
          child: Column(
            children: <Widget>[
              FactRow(
                label: 'Check-in',
                value: stay.checkIn.toWeekdayAndDate(),
              ),
              FactRow(
                label: 'Check-out',
                value: stay.checkOut.toWeekdayAndDate(),
              ),
              if (stay.bookingNumber.isNotEmpty)
                CopyableRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Booking number',
                  value: stay.bookingNumber,
                  copiedMessage: 'Booking number copied',
                ),
            ],
          ),
        ),
        const DetailSectionTitle('Contact'),
        QaddyCard(
          child: Column(
            children: <Widget>[
              if (stay.phone.isNotEmpty)
                ContactRow(kind: ContactKind.phone, value: stay.phone),
              if (stay.website.isNotEmpty)
                ContactRow(kind: ContactKind.website, value: stay.website),
              if (stay.address.isNotEmpty)
                ContactRow(kind: ContactKind.address, value: stay.address),
              if (stay.phone.isEmpty &&
                  stay.website.isEmpty &&
                  stay.address.isEmpty)
                Text(
                  'No contact details yet.',
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
            ],
          ),
        ),
        const DetailSectionTitle('Room Allocation'),
        if (stay.rooms.isEmpty)
          QaddyCard(
            child: Text(
              'No rooms allocated yet. Edit the stay to say who is sleeping '
              'where.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          )
        else
          for (final room in stay.rooms) ...<Widget>[
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    room.name,
                    style: typography.h4.copyWith(color: colours.textPrimary),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    room.guests.isEmpty
                        ? 'No one assigned'
                        : room.guests.join(', '),
                    style: typography.body.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sm),
          ],
        if (cost != null) ...<Widget>[
          const DetailSectionTitle('Cost Split'),
          QaddyCard(
            child: Column(
              children: <Widget>[
                FactRow(label: 'Total', value: formatMoney(cost)),
                if (perGuest != null)
                  FactRow(
                    label: 'Per guest (${stay.guests.length})',
                    value: formatMoney(perGuest),
                  )
                else
                  const FactRow(
                    label: 'Per guest',
                    value: 'Allocate rooms to split',
                  ),
              ],
            ),
          ),
        ],
        const DetailSectionTitle('Map'),
        MapPlaceholder(
          label: stay.address.isEmpty ? stay.name : stay.address,
          onTap: () => openLinkOrCopy(
            context,
            ref,
            uri: mapSearchUri(stay.address.isEmpty ? stay.name : stay.address),
            fallback: stay.address.isEmpty ? stay.name : stay.address,
            label: 'the map',
          ),
        ),
        if (stay.notes.isNotEmpty) ...<Widget>[
          const DetailSectionTitle('Notes'),
          QaddyCard(
            child: Text(
              stay.notes,
              style: typography.body.copyWith(color: colours.textPrimary),
            ),
          ),
        ],
        SizedBox(height: spacing.md),
        QaddySecondaryButton(
          label: 'Edit ${stay.name}',
          onPressed: () => context.push(
            AppRoutes.tripEditItem(
              tripId,
              TripEditSection.accommodation.slug,
              stay.id,
            ),
          ),
        ),
      ],
    );
  }
}
