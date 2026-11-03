/// Edit Trip -> one section. Single-form sections (details, dates,
/// destination, notes) open a form; chat settings apply as they are toggled;
/// players and the item lists (flights, courses, …) have their own editors.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/forms/qaddy_switch_row.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_cover.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_friend_picker.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// One section of Edit Trip (route `/trips/:tripId/edit/:section`).
class EditTripSectionScreen extends ConsumerWidget {
  const EditTripSectionScreen({
    required this.tripId,
    required this.section,
    super.key,
  });

  /// The trip being edited.
  final String tripId;

  /// The route segment naming the section (see [TripEditSection.slug]).
  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    final kind = TripEditSection.fromSlug(section);
    if (trip == null || kind == null) {
      return const TripNotFound();
    }
    final back = AppRoutes.tripEdit(tripId);

    return switch (kind) {
      TripEditSection.details => _DetailsForm(trip: trip, fallbackRoute: back),
      TripEditSection.dates => _DatesForm(trip: trip, fallbackRoute: back),
      TripEditSection.destination => _DestinationForm(
        trip: trip,
        fallbackRoute: back,
      ),
      TripEditSection.notes => _NotesForm(trip: trip, fallbackRoute: back),
      TripEditSection.chat => _ChatSettings(tripId: tripId),
      TripEditSection.players => _PlayersEditor(tripId: tripId),
      _ => TripItemList(tripId: tripId, section: kind),
    };
  }
}

// ---------------------------------------------------------------- details

class _DetailsForm extends ConsumerStatefulWidget {
  const _DetailsForm({required this.trip, required this.fallbackRoute});

  final Trip trip;
  final String fallbackRoute;

  @override
  ConsumerState<_DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends ConsumerState<_DetailsForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.trip.name,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.trip.description ?? '',
  );
  late String _cover = tripCoverFor(widget.trip.coverImage).id;
  late TripVisibility _visibility = widget.trip.visibility;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return TripFormPage(
      title: 'Trip Details',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _name.text.trim().isNotEmpty,
      onSave: () {
        final renamed = _name.text.trim() != widget.trip.name;
        final description = _description.text.trim();
        ref
            .read(tripsProvider.notifier)
            .updateTrip(
              widget.trip.id,
              (trip) => trip.copyWith(
                name: _name.text.trim(),
                description: description,
                clearDescription: description.isEmpty,
                visibility: _visibility,
                coverImage: _cover,
              ),
              log: renamed
                  ? 'Renamed the trip to ${_name.text.trim()}'
                  : 'Updated trip details',
            );
      },
      builder: (context, {required submitted}) => <Widget>[
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
        SizedBox(height: spacing.lg),
        QaddyTextField(
          controller: _name,
          label: 'Trip Name',
          textCapitalization: TextCapitalization.words,
          errorText: submitted && _name.text.trim().isEmpty
              ? 'Give your trip a name'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _description,
          label: 'Description',
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
        ),
        const TripFieldGap(),
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
      ],
    );
  }
}

// ------------------------------------------------------------------ dates

class _DatesForm extends ConsumerStatefulWidget {
  const _DatesForm({required this.trip, required this.fallbackRoute});

  final Trip trip;
  final String fallbackRoute;

  @override
  ConsumerState<_DatesForm> createState() => _DatesFormState();
}

class _DatesFormState extends ConsumerState<_DatesForm> {
  late DateTime _start = widget.trip.startDate;
  late DateTime _end = widget.trip.endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final valid = !_end.isBefore(_start);

    return TripFormPage(
      title: 'Dates',
      fallbackRoute: widget.fallbackRoute,
      validate: () => valid,
      onSave: () => ref
          .read(tripsProvider.notifier)
          .updateTrip(
            widget.trip.id,
            (trip) => trip.copyWith(startDate: _start, endDate: _end),
            log: 'Changed dates to ${_start.toFriendlyRange(_end)}',
          ),
      builder: (context, {required submitted}) => <Widget>[
        QaddyDateField(
          label: 'Start Date',
          value: _start,
          onChanged: (date) => setState(() {
            _start = date;
            if (_end.isBefore(date)) {
              _end = date;
            }
          }),
        ),
        const TripFieldGap(),
        QaddyDateField(
          label: 'End Date',
          value: _end,
          firstDate: _start,
          errorText: valid ? null : 'End date must be on or after the start',
          onChanged: (date) => setState(() => _end = date),
        ),
        SizedBox(height: spacing.md),
        if (valid)
          Text(
            '${_start.calendarDaysUntil(_end) + 1} days · '
            '${_start.toFriendlyRange(_end)}',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ destination

class _DestinationForm extends ConsumerStatefulWidget {
  const _DestinationForm({required this.trip, required this.fallbackRoute});

  final Trip trip;
  final String fallbackRoute;

  @override
  ConsumerState<_DestinationForm> createState() => _DestinationFormState();
}

class _DestinationFormState extends ConsumerState<_DestinationForm> {
  late final TextEditingController _destination = TextEditingController(
    text: widget.trip.destination,
  );

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TripFormPage(
      title: 'Destination',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _destination.text.trim().isNotEmpty,
      onSave: () => ref
          .read(tripsProvider.notifier)
          .updateTrip(
            widget.trip.id,
            (trip) => trip.copyWith(
              destination: _destination.text.trim(),
              country: countryFromDestination(_destination.text),
            ),
            log: 'Changed destination to ${_destination.text.trim()}',
          ),
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _destination,
          label: 'Destination',
          hintText: 'Melbourne, Australia',
          prefixIcon: const Icon(Icons.place_outlined),
          textCapitalization: TextCapitalization.words,
          errorText: submitted && _destination.text.trim().isEmpty
              ? 'Where are you going?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ notes

class _NotesForm extends ConsumerStatefulWidget {
  const _NotesForm({required this.trip, required this.fallbackRoute});

  final Trip trip;
  final String fallbackRoute;

  @override
  ConsumerState<_NotesForm> createState() => _NotesFormState();
}

class _NotesFormState extends ConsumerState<_NotesForm> {
  late final TextEditingController _notes = TextEditingController(
    text: ref.read(tripPlanProvider(widget.trip.id)).notes,
  );

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TripFormPage(
      title: 'Notes',
      fallbackRoute: widget.fallbackRoute,
      validate: () => true,
      onSave: () => ref
          .read(tripsProvider.notifier)
          .updatePlan(
            widget.trip.id,
            (plan) => plan.copyWith(notes: _notes.text.trim()),
            log: 'Updated trip notes',
          ),
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _notes,
          label: 'Notes',
          hintText: 'Dress codes, dinner bookings, things to remember…',
          minLines: 6,
          maxLines: 12,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}

// -------------------------------------------------------- chat settings

class _ChatSettings extends ConsumerWidget {
  const _ChatSettings({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tripPlanProvider(tripId)).chatSettings;
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final controller = ref.read(tripsProvider.notifier);

    void change(TripChatSettings Function(TripChatSettings) update) =>
        controller.updatePlan(
          tripId,
          (plan) => plan.copyWith(chatSettings: update(plan.chatSettings)),
        );

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Chat Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  QaddySwitchRow(
                    title: 'Mute notifications',
                    subtitle: 'Stop alerts for new messages in this trip.',
                    value: settings.muted,
                    onChanged: (value) =>
                        change((s) => s.copyWith(muted: value)),
                  ),
                  QaddySwitchRow(
                    title: 'Read receipts',
                    subtitle: 'Show when your messages have been read.',
                    value: settings.readReceipts,
                    onChanged: (value) =>
                        change((s) => s.copyWith(readReceipts: value)),
                  ),
                  QaddySwitchRow(
                    title: 'Typing indicators',
                    subtitle: 'Show when someone is typing.',
                    value: settings.typingIndicators,
                    onChanged: (value) =>
                        change((s) => s.copyWith(typingIndicators: value)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- players

class _PlayersEditor extends ConsumerStatefulWidget {
  const _PlayersEditor({required this.tripId});

  final String tripId;

  @override
  ConsumerState<_PlayersEditor> createState() => _PlayersEditorState();
}

class _PlayersEditorState extends ConsumerState<_PlayersEditor> {
  Set<String> _invite = <String>{};

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onTrip = plan.members.map((member) => member.displayName).toSet();

    Future<void> remove(TripMember member) async {
      final confirmed = await showQaddyConfirm(
        context,
        title: 'Remove ${member.displayName}?',
        message: '${member.displayName} will be taken off this trip.',
        confirmLabel: 'Remove',
        destructive: true,
      );
      if (confirmed) {
        ref
            .read(tripsProvider.notifier)
            .removeMember(widget.tripId, member.displayName);
      }
    }

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Players')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  for (final member in plan.members)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing.xs),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  member.displayName,
                                  style: typography.body.copyWith(
                                    color: colours.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_roleLabel(member)} · '
                                  '${handicapPhrase(member.handicap)}',
                                  style: typography.small.copyWith(
                                    color: colours.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (member.role != TripRole.organiser)
                            IconButton(
                              tooltip: 'Remove ${member.displayName}',
                              onPressed: () => remove(member),
                              icon: Icon(
                                Icons.person_remove_outlined,
                                color: colours.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            Text(
              'Invite more friends',
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sm),
            QaddyCard(
              child: TripFriendPicker(
                selected: _invite,
                exclude: onTrip,
                onChanged: (names) => setState(() => _invite = names),
              ),
            ),
            SizedBox(height: spacing.md),
            QaddyGoldButton(
              label: _invite.isEmpty
                  ? 'Invite'
                  : 'Invite ${_invite.length} '
                        '${_invite.length == 1 ? 'friend' : 'friends'}',
              onPressed: _invite.isEmpty
                  ? null
                  : () {
                      ref
                          .read(tripsProvider.notifier)
                          .inviteFriends(widget.tripId, _invite.toList());
                      setState(() => _invite = <String>{});
                    },
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(TripMember member) {
  if (member.role == TripRole.organiser) {
    return 'Organiser';
  }
  return switch (member.status) {
    ParticipantStatus.confirmed => 'Going',
    ParticipantStatus.pending => 'Invited',
    ParticipantStatus.declined => 'Declined',
  };
}

// ------------------------------------------------------------- item lists

/// The list of items in a list section (flights, courses, …), each opening
/// its own editor, plus an "Add" button.
class TripItemList extends ConsumerWidget {
  const TripItemList({required this.tripId, required this.section, super.key});

  /// The trip being edited.
  final String tripId;

  /// Which list to show.
  final TripEditSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(tripPlanProvider(tripId));
    final theme = Theme.of(context);
    final spacing = theme.extension<QaddySpacing>()!;

    final rows = _rows(plan);
    final noun = _noun(section);

    return QaddyScaffold(
      appBar: AppBar(title: Text(section.label)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            if (rows.isEmpty)
              QaddyEmptyState(
                icon: section.icon,
                title: 'No $noun yet',
                message: 'Add your first one below.',
              )
            else
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    for (final row in rows)
                      QaddyNavRow(
                        icon: row.icon ?? section.icon,
                        title: row.title,
                        subtitle: row.subtitle,
                        onTap: () => context.push(
                          AppRoutes.tripEditItem(tripId, section.slug, row.id),
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(height: spacing.lg),
            QaddyGoldButton(
              label: 'Add ${_singular(section)}',
              onPressed: () => context.push(
                AppRoutes.tripEditItem(tripId, section.slug, 'new'),
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }

  List<_ItemRow> _rows(TripPlan plan) {
    switch (section) {
      case TripEditSection.accommodation:
        return <_ItemRow>[
          for (final stay in plan.accommodations)
            _ItemRow(
              id: stay.id,
              title: stay.name,
              subtitle:
                  '${stay.checkIn.toFriendlyRange(stay.checkOut)} · '
                  '${stay.nights} ${stay.nights == 1 ? 'night' : 'nights'}',
            ),
        ];
      case TripEditSection.flights:
        return <_ItemRow>[
          for (final flight in plan.flights)
            _ItemRow(
              id: flight.id,
              title: '${flight.airline} ${flight.flightNumber}',
              subtitle:
                  '${flight.routeLabel} · ${flight.departure.toDayAndTime()}',
            ),
        ];
      case TripEditSection.transport:
        return <_ItemRow>[
          for (final leg in plan.transport)
            _ItemRow(
              id: leg.id,
              title: leg.type.label,
              icon: leg.type.icon,
              subtitle: <String>[
                if (leg.routeLabel.isNotEmpty) leg.routeLabel,
                leg.pickup.toDayAndTime(),
              ].join(' · '),
            ),
        ];
      case TripEditSection.courses:
        return <_ItemRow>[
          for (final course in plan.courses)
            _ItemRow(
              id: course.id,
              title: course.name,
              subtitle:
                  '${course.teeTime.toDayAndTime()} · '
                  '${course.players.length} '
                  '${course.players.length == 1 ? 'player' : 'players'}',
            ),
        ];
      case TripEditSection.expenses:
        return <_ItemRow>[
          for (final expense in plan.expenses)
            _ItemRow(
              id: expense.id,
              title: expense.title,
              icon: expense.category.icon,
              subtitle:
                  '${formatMoney(expense.amount)} · paid by '
                  '${expense.paidBy}',
            ),
        ];
      case TripEditSection.itinerary:
        return <_ItemRow>[
          for (final item in plan.itinerary)
            _ItemRow(
              id: item.id,
              title: item.title,
              icon: item.kind.icon,
              subtitle: <String>[
                item.start.toDayAndTime(),
                if (item.location.isNotEmpty) item.location,
              ].join(' · '),
            ),
        ];
      case TripEditSection.tasks:
        return <_ItemRow>[
          for (final task in plan.tasks)
            _ItemRow(
              id: task.id,
              title: task.title,
              icon: task.done
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              subtitle: <String>[
                if (task.done) 'Done' else 'To do',
                if (task.due != null) 'due ${task.due!.toFriendlyDate()}',
              ].join(' · '),
            ),
        ];
      case TripEditSection.weather:
        return <_ItemRow>[
          for (final day in plan.weather)
            _ItemRow(
              id: day.id,
              title: day.day,
              icon: day.condition.icon,
              subtitle: '${day.forecast} · ${day.highLabel} / ${day.lowLabel}',
            ),
        ];
      case TripEditSection.packing:
        return <_ItemRow>[
          for (final item in plan.packing)
            _ItemRow(
              id: item.id,
              title: item.label,
              icon: item.packed
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              subtitle: item.packed ? 'Packed' : 'Not packed yet',
            ),
        ];
      case TripEditSection.details ||
          TripEditSection.dates ||
          TripEditSection.destination ||
          TripEditSection.players ||
          TripEditSection.notes ||
          TripEditSection.chat:
        return const <_ItemRow>[];
    }
  }
}

class _ItemRow {
  const _ItemRow({
    required this.id,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData? icon;
}

String _noun(TripEditSection section) => switch (section) {
  TripEditSection.accommodation => 'accommodation',
  TripEditSection.flights => 'flights',
  TripEditSection.transport => 'transport',
  TripEditSection.courses => 'courses',
  TripEditSection.expenses => 'expenses',
  TripEditSection.itinerary => 'activities',
  TripEditSection.tasks => 'tasks',
  TripEditSection.weather => 'forecast days',
  TripEditSection.packing => 'packing items',
  _ => section.label.toLowerCase(),
};

String _singular(TripEditSection section) => switch (section) {
  TripEditSection.accommodation => 'Accommodation',
  TripEditSection.flights => 'Flight',
  TripEditSection.transport => 'Transport',
  TripEditSection.courses => 'Course',
  TripEditSection.expenses => 'Expense',
  TripEditSection.itinerary => 'Activity',
  TripEditSection.tasks => 'Task',
  TripEditSection.weather => 'Forecast Day',
  TripEditSection.packing => 'Packing Item',
  _ => section.label,
};
