/// Add or edit a transport booking (rental car, transfer, Uber, taxi, parking).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The transport form. Pass [transport] to edit one; omit it to add.
class TransportForm extends ConsumerStatefulWidget {
  const TransportForm({
    required this.tripId,
    required this.fallbackRoute,
    this.transport,
    super.key,
  });

  /// The trip the booking belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The booking being edited, or `null` when adding.
  final TripTransport? transport;

  @override
  ConsumerState<TransportForm> createState() => _TransportFormState();
}

class _TransportFormState extends ConsumerState<TransportForm> {
  late TransportType _type;
  late DateTime _pickup;
  late final TextEditingController _from;
  late final TextEditingController _to;
  late final TextEditingController _driver;
  late final TextEditingController _vehicle;
  late final TextEditingController _reference;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final leg = widget.transport;
    final start = ref.read(tripProvider(widget.tripId))!.startDate;
    _type = leg?.type ?? TransportType.rentalCar;
    _pickup = leg?.pickup ?? DateTime(start.year, start.month, start.day, 10);
    _from = TextEditingController(text: leg?.from ?? '');
    _to = TextEditingController(text: leg?.to ?? '');
    _driver = TextEditingController(text: leg?.driver ?? '');
    _vehicle = TextEditingController(text: leg?.vehicle ?? '');
    _reference = TextEditingController(text: leg?.bookingReference ?? '');
    _notes = TextEditingController(text: leg?.notes ?? '');
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _from,
      _to,
      _driver,
      _vehicle,
      _reference,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// A booking needs to say where it starts or where it goes.
  bool get _hasPlace =>
      _from.text.trim().isNotEmpty || _to.text.trim().isNotEmpty;

  void _save() {
    final built = TripTransport(
      id:
          widget.transport?.id ??
          ref.read(tripsProvider.notifier).newId('transport'),
      type: _type,
      pickup: _pickup,
      from: _from.text.trim(),
      to: _to.text.trim(),
      driver: _driver.text.trim(),
      vehicle: _vehicle.text.trim(),
      bookingReference: _reference.text.trim().toUpperCase(),
      notes: _notes.text.trim(),
    );
    final existing = widget.transport != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            transport: existing
                ? <TripTransport>[
                    for (final leg in plan.transport)
                      if (leg.id == built.id) built else leg,
                  ]
                : <TripTransport>[...plan.transport, built],
          ),
          log: '${existing ? 'Updated' : 'Added'} ${_type.label}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final leg = widget.transport;

    return TripFormPage(
      title: leg == null ? 'Add Transport' : 'Edit Transport',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _hasPlace,
      onSave: _save,
      onDelete: leg == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    transport: <TripTransport>[
                      for (final t in plan.transport)
                        if (t.id != leg.id) t,
                    ],
                  ),
                  log: 'Removed ${leg.type.label}',
                ),
      deleteTitle: 'Delete this booking?',
      deleteMessage: 'It will be removed from the trip and its timeline.',
      builder: (context, {required submitted}) {
        final placeError = submitted && !_hasPlace
            ? 'Add a pickup or a drop-off'
            : null;
        return <Widget>[
          const FormLabel('Type'),
          QaddyChipSelector<TransportType>(
            options: <QaddyChipOption<TransportType>>[
              for (final type in TransportType.values)
                QaddyChipOption(
                  value: type,
                  label: type.label,
                  icon: type.icon,
                ),
            ],
            selected: _type,
            onChanged: (value) => setState(() => _type = value),
          ),
          const FormLabel('Pickup'),
          QaddyDateTimeField(
            label: 'Pickup',
            value: _pickup,
            onChanged: (value) => setState(() => _pickup = value),
          ),
          const FormLabel('Route'),
          QaddyTextField(
            controller: _from,
            label: 'From',
            hintText: 'Melbourne Airport',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: placeError,
            onChanged: (_) => setState(() {}),
          ),
          const TripFieldGap(),
          QaddyTextField(
            controller: _to,
            label: 'To',
            hintText: 'RACV Healesville Resort',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: placeError,
            onChanged: (_) => setState(() {}),
          ),
          const FormLabel('Details'),
          FieldPair(
            left: QaddyTextField(
              controller: _driver,
              label: 'Driver',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            right: QaddyTextField(
              controller: _vehicle,
              label: 'Vehicle',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
          ),
          const TripFieldGap(),
          QaddyTextField(
            controller: _reference,
            label: 'Booking Reference',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
          const TripFieldGap(),
          QaddyTextField(
            controller: _notes,
            label: 'Notes',
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
          ),
        ];
      },
    );
  }
}
