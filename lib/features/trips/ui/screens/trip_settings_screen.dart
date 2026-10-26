/// Trip Settings — renaming, sharing, and the actions that change a trip's
/// life: duplicate, archive, leave and delete.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Trip Settings (route `/trips/:tripId/settings`).
class TripSettingsScreen extends ConsumerWidget {
  const TripSettingsScreen({required this.tripId, super.key});

  /// The trip being managed.
  final String tripId;

  void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final controller = ref.read(tripsProvider.notifier);
    final archived = trip.status == TripStatus.archived;

    Future<void> copyLink() async {
      await Clipboard.setData(ClipboardData(text: tripInviteLink(trip)));
      if (context.mounted) {
        _tell(context, 'Invite link copied');
      }
    }

    Future<void> duplicate() async {
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Duplicate this trip?',
        message:
            'Makes a copy of ${trip.name} with its courses, flights and '
            'bookings. Chat, payments and progress start fresh.',
        confirmLabel: 'Duplicate',
      );
      if (!confirmed || !context.mounted) {
        return;
      }
      final copyId = controller.duplicateTrip(tripId);
      if (copyId != null && context.mounted) {
        context.go(AppRoutes.tripDetails(copyId));
      }
    }

    Future<void> archiveToggle() async {
      if (archived) {
        controller.unarchiveTrip(tripId);
        _tell(context, '${trip.name} restored');
        return;
      }
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Archive this trip?',
        message:
            'It moves out of Upcoming and Past Trips into Archived. You can '
            'restore it any time.',
        confirmLabel: 'Archive',
      );
      if (!confirmed || !context.mounted) {
        return;
      }
      controller.archiveTrip(tripId);
      context.go(AppRoutes.trips);
    }

    Future<void> leave() async {
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Leave this trip?',
        message:
            'You will be taken off ${trip.name} and it will disappear from '
            'your trips.',
        confirmLabel: 'Leave',
        destructive: true,
      );
      if (!confirmed || !context.mounted) {
        return;
      }
      controller.leaveTrip(tripId);
      context.go(AppRoutes.trips);
    }

    Future<void> delete() async {
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Delete this trip?',
        message:
            '${trip.name} and everything in it — bookings, expenses and '
            'chat — will be permanently deleted.',
        confirmLabel: 'Delete Trip',
        destructive: true,
      );
      if (!confirmed || !context.mounted) {
        return;
      }
      controller.deleteTrip(tripId);
      context.go(AppRoutes.trips);
    }

    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: typography.h3.copyWith(color: colours.textPrimary)),
        SizedBox(height: spacing.sm),
        QaddyCard(child: Column(children: rows)),
        SizedBox(height: spacing.sectionGap),
      ],
    );

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            group('Trip', <Widget>[
              QaddyNavRow(
                icon: Icons.edit_outlined,
                title: 'Rename Trip',
                subtitle: trip.name,
                onTap: () => context.push(
                  AppRoutes.tripEditSection(
                    tripId,
                    TripEditSection.details.slug,
                  ),
                ),
              ),
              QaddyNavRow(
                icon: Icons.image_outlined,
                title: 'Change Cover Image',
                onTap: () => context.push(
                  AppRoutes.tripEditSection(
                    tripId,
                    TripEditSection.details.slug,
                  ),
                ),
              ),
              QaddyNavRow(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Settings',
                onTap: () => context.push(
                  AppRoutes.tripEditSection(tripId, TripEditSection.chat.slug),
                ),
              ),
            ]),
            group('Share', <Widget>[
              QaddyNavRow(
                icon: Icons.person_add_alt_outlined,
                title: 'Invite More Friends',
                onTap: () => context.push(AppRoutes.tripInvite(tripId)),
              ),
              QaddyNavRow(
                icon: Icons.link,
                title: 'Share Invite Link',
                subtitle: 'Copies a link to your clipboard',
                onTap: copyLink,
              ),
              QaddyNavRow(
                icon: Icons.ios_share,
                title: 'Export Itinerary',
                subtitle: 'Copy the plan as text, or save a PDF',
                onTap: () => context.push(AppRoutes.tripExport(tripId)),
              ),
            ]),
            group('Manage', <Widget>[
              QaddyNavRow(
                icon: Icons.copy_all_outlined,
                title: 'Duplicate Trip',
                onTap: duplicate,
              ),
              QaddyNavRow(
                icon: archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                title: archived ? 'Restore from Archive' : 'Archive Trip',
                onTap: archiveToggle,
              ),
              QaddyNavRow(
                icon: Icons.logout,
                title: 'Leave Trip',
                destructive: true,
                onTap: leave,
              ),
              QaddyNavRow(
                icon: Icons.delete_outline,
                title: 'Delete Trip',
                destructive: true,
                onTap: delete,
              ),
            ]),
            SizedBox(height: spacing.md),
          ],
        ),
      ),
    );
  }
}
