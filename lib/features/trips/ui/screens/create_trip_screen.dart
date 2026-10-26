/// Qaddy's Create Trip screen — a full-page form that starts a new trip.
///
/// Saving adds the trip to the store as `planning`, so it appears under
/// "Upcoming Trips" on the Trips overview straight away.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_cover.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_friend_picker.dart';

/// Create Trip (route `/trips/create`).
class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _name = TextEditingController();
  final _destination = TextEditingController();
  final _description = TextEditingController();

  DateTime? _start;
  DateTime? _end;
  String _cover = tripCoverPresets.first.id;
  TripVisibility _visibility = TripVisibility.private;
  Set<String> _invited = <String>{};

  /// Errors only show once the user has tried to save, so an untouched form
  /// doesn't open covered in red.
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _destination.dispose();
    _description.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _submitted && _name.text.trim().isEmpty ? 'Give your trip a name' : null;

  String? get _destinationError =>
      _submitted && _destination.text.trim().isEmpty
      ? 'Where are you going?'
      : null;

  String? get _startError =>
      _submitted && _start == null ? 'Pick a start date' : null;

  String? get _endError {
    if (!_submitted) {
      return null;
    }
    if (_end == null) {
      return 'Pick an end date';
    }
    if (_start != null && _end!.isBefore(_start!)) {
      return 'End date must be on or after the start';
    }
    return null;
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _destination.text.trim().isNotEmpty &&
      _start != null &&
      _end != null &&
      !_end!.isBefore(_start!);

  void _save() {
    setState(() => _submitted = true);
    if (!_valid) {
      return;
    }
    ref
        .read(tripsProvider.notifier)
        .createTrip(
          NewTripDraft(
            name: _name.text,
            destination: _destination.text,
            startDate: _start!,
            endDate: _end!,
            description: _description.text,
            visibility: _visibility,
            coverImage: _cover,
            invitedFriends: _invited.toList(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_name.text.trim()} added to Upcoming Trips')),
    );
    context.go(AppRoutes.trips);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final today = DateTime.now();
    final earliest = DateTime(today.year, today.month, today.day);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Center(
              child: TripCoverTile(presetId: _cover, size: spacing.hero * 2),
            ),
            SizedBox(height: spacing.sm),
            Center(
              child: Text(
                'Cover image — ${tripCoverFor(_cover).label}',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ),
            SizedBox(height: spacing.sm),
            TripCoverPicker(
              selectedId: _cover,
              onChanged: (id) => setState(() => _cover = id),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Trip Details',
              child: Column(
                children: <Widget>[
                  QaddyTextField(
                    controller: _name,
                    label: 'Trip Name',
                    hintText: 'Melbourne Golf Weekend',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    errorText: _nameError,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: spacing.md),
                  QaddyTextField(
                    controller: _destination,
                    label: 'Destination',
                    hintText: 'Melbourne, Australia',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.place_outlined),
                    errorText: _destinationError,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: spacing.md),
                  QaddyDateField(
                    label: 'Start Date',
                    value: _start,
                    firstDate: earliest,
                    errorText: _startError,
                    onChanged: (date) => setState(() {
                      _start = date;
                      if (_end != null && _end!.isBefore(date)) {
                        _end = date;
                      }
                    }),
                  ),
                  SizedBox(height: spacing.md),
                  QaddyDateField(
                    label: 'End Date',
                    value: _end,
                    firstDate: _start ?? earliest,
                    errorText: _endError,
                    onChanged: (date) => setState(() => _end = date),
                  ),
                  if (_start != null && _end != null && _endError == null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.sm),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_start!.toFriendlyRange(_end!)} · '
                          '${_start!.calendarDaysUntil(_end!) + 1} days',
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: spacing.md),
                  QaddyTextField(
                    controller: _description,
                    label: 'Description',
                    hintText: 'What is this trip about?',
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Who Can See This Trip',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QaddySegmentedControl<TripVisibility>(
                    segments: const <QaddySegment<TripVisibility>>[
                      QaddySegment(
                        value: TripVisibility.private,
                        label: 'Private',
                        icon: Icons.lock_outline,
                      ),
                      QaddySegment(
                        value: TripVisibility.public,
                        label: 'Public',
                        icon: Icons.public,
                      ),
                    ],
                    selected: _visibility,
                    onChanged: (value) => setState(() => _visibility = value),
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    _visibility == TripVisibility.private
                        ? 'Only people you invite can see this trip.'
                        : 'Anyone with the invite link can view this trip.',
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Invite Friends',
              child: TripFriendPicker(
                selected: _invited,
                onChanged: (names) => setState(() => _invited = names),
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyPrimaryButton(
              label: _invited.isEmpty
                  ? 'Save Trip'
                  : 'Save Trip & Invite ${_invited.length}',
              onPressed: _save,
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
