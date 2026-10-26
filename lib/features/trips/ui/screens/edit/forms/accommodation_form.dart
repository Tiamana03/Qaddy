/// Add or edit accommodation, including who sleeps in which room.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_accommodation.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The accommodation form. Pass [stay] to edit one; omit it to add.
class AccommodationForm extends ConsumerStatefulWidget {
  const AccommodationForm({
    required this.tripId,
    required this.fallbackRoute,
    this.stay,
    super.key,
  });

  /// The trip the stay belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The stay being edited, or `null` when adding.
  final TripAccommodation? stay;

  @override
  ConsumerState<AccommodationForm> createState() => _AccommodationFormState();
}

/// A room being edited: its name field and who is in it.
class _RoomDraft {
  _RoomDraft(String name, this.guests)
    : name = TextEditingController(text: name);

  final TextEditingController name;
  Set<String> guests;
}

class _AccommodationFormState extends ConsumerState<AccommodationForm> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _website;
  late final TextEditingController _booking;
  late final TextEditingController _cost;
  late final TextEditingController _notes;
  late DateTime _checkIn;
  late DateTime _checkOut;
  late List<_RoomDraft> _rooms;

  @override
  void initState() {
    super.initState();
    final stay = widget.stay;
    final trip = ref.read(tripProvider(widget.tripId))!;
    _name = TextEditingController(text: stay?.name ?? '');
    _address = TextEditingController(text: stay?.address ?? '');
    _phone = TextEditingController(text: stay?.phone ?? '');
    _website = TextEditingController(text: stay?.website ?? '');
    _booking = TextEditingController(text: stay?.bookingNumber ?? '');
    final cost = stay?.totalCost;
    _cost = TextEditingController(
      text: cost == null
          ? ''
          : (cost == cost.roundToDouble()
                ? cost.toStringAsFixed(0)
                : cost.toString()),
    );
    _notes = TextEditingController(text: stay?.notes ?? '');
    _checkIn = stay?.checkIn ?? trip.startDate;
    _checkOut = stay?.checkOut ?? trip.endDate;
    _rooms = <_RoomDraft>[
      for (final room in stay?.rooms ?? const <TripRoom>[])
        _RoomDraft(room.name, room.guests.toSet()),
    ];
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _name,
      _address,
      _phone,
      _website,
      _booking,
      _cost,
      _notes,
      for (final room in _rooms) room.name,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? get _costValue => parseAmount(_cost.text);
  bool get _costOk => _cost.text.trim().isEmpty || _costValue != null;
  bool get _datesOk => _checkOut.isAfter(_checkIn);

  /// A guest can only sleep in one room.
  String? _roomOf(String guest, _RoomDraft except) {
    for (final room in _rooms) {
      if (!identical(room, except) && room.guests.contains(guest)) {
        return room.name.text.trim().isEmpty ? 'another room' : room.name.text;
      }
    }
    return null;
  }

  bool get _valid => _name.text.trim().isNotEmpty && _costOk && _datesOk;

  void _save() {
    final plan = ref.read(tripPlanProvider(widget.tripId));
    final order = plan.members.map((m) => m.displayName).toList();
    final rooms = <TripRoom>[
      for (final (index, room) in _rooms.indexed)
        TripRoom(
          name: room.name.text.trim().isEmpty
              ? 'Room ${index + 1}'
              : room.name.text.trim(),
          guests: <String>[
            for (final name in order)
              if (room.guests.contains(name)) name,
          ],
        ),
    ];
    final built = TripAccommodation(
      id: widget.stay?.id ?? ref.read(tripsProvider.notifier).newId('stay'),
      name: _name.text.trim(),
      checkIn: _checkIn,
      checkOut: _checkOut,
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      website: _website.text.trim(),
      bookingNumber: _booking.text.trim().toUpperCase(),
      rooms: rooms,
      totalCost: _costValue,
      notes: _notes.text.trim(),
    );
    final existing = widget.stay != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            accommodations: existing
                ? <TripAccommodation>[
                    for (final s in plan.accommodations)
                      if (s.id == built.id) built else s,
                  ]
                : <TripAccommodation>[...plan.accommodations, built],
          ),
          log: existing
              ? 'Updated ${built.name}'
              : 'Added accommodation: ${built.name}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final stay = widget.stay;
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return TripFormPage(
      title: stay == null ? 'Add Accommodation' : 'Edit Accommodation',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _valid,
      onSave: _save,
      onDelete: stay == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    accommodations: <TripAccommodation>[
                      for (final s in plan.accommodations)
                        if (s.id != stay.id) s,
                    ],
                  ),
                  log: 'Removed ${stay.name}',
                ),
      deleteTitle: 'Delete this stay?',
      deleteMessage: 'It will be removed from the trip and its timeline.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _name,
          label: 'Name',
          hintText: 'RACV Healesville Resort',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          errorText: submitted && _name.text.trim().isEmpty
              ? 'Where are you staying?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _address,
          label: 'Address',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const TripFieldGap(),
        FieldPair(
          left: QaddyDateField(
            label: 'Check-in',
            value: _checkIn,
            onChanged: (date) => setState(() {
              _checkIn = date;
              if (!_checkOut.isAfter(date)) {
                _checkOut = date.add(const Duration(days: 1));
              }
            }),
          ),
          right: QaddyDateField(
            label: 'Check-out',
            value: _checkOut,
            firstDate: _checkIn,
            errorText: _datesOk ? null : 'After check-in',
            onChanged: (date) => setState(() => _checkOut = date),
          ),
        ),
        const FormLabel('Contact & booking'),
        FieldPair(
          left: QaddyTextField(
            controller: _phone,
            label: 'Phone',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          right: QaddyTextField(
            controller: _website,
            label: 'Website',
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
        ),
        const TripFieldGap(),
        FieldPair(
          left: QaddyTextField(
            controller: _booking,
            label: 'Booking Number',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
          right: QaddyTextField(
            controller: _cost,
            label: 'Total Cost',
            hintText: r'$3,360',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: submitted && !_costOk ? 'Check this number' : null,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const FormLabel('Room allocation'),
        for (final (index, room) in _rooms.indexed) ...<Widget>[
          QaddyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: QaddyTextField(
                        controller: room.name,
                        label: 'Room ${index + 1}',
                        hintText: 'Twin room',
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove room ${index + 1}',
                      onPressed: () => setState(() {
                        _rooms.removeAt(index).name.dispose();
                      }),
                      icon: Icon(Icons.delete_outline, color: colours.error),
                    ),
                  ],
                ),
                SizedBox(height: spacing.sm),
                QaddyMultiChipSelector<String>(
                  options: <QaddyChipOption<String>>[
                    for (final option in memberChipOptions(plan))
                      if (_roomOf(option.value, room) == null) option,
                  ],
                  selected: room.guests,
                  onChanged: (value) => setState(() => room.guests = value),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
        ],
        if (_rooms.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Text(
              'Add rooms to say who is sleeping where — the cost is then '
              'split per guest.',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ),
        QaddySecondaryButton(
          label: 'Add Room',
          onPressed: () =>
              setState(() => _rooms.add(_RoomDraft('', <String>{}))),
        ),
        const FormLabel('Notes'),
        QaddyTextField(
          controller: _notes,
          label: 'Notes',
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
