/// Add or edit a flight.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The flight form. Pass [flight] to edit one; omit it to add a new flight.
class FlightForm extends ConsumerStatefulWidget {
  const FlightForm({
    required this.tripId,
    required this.fallbackRoute,
    this.flight,
    super.key,
  });

  /// The trip the flight belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The flight being edited, or `null` when adding.
  final TripFlight? flight;

  @override
  ConsumerState<FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends ConsumerState<FlightForm> {
  late final TextEditingController _airline;
  late final TextEditingController _number;
  late final TextEditingController _from;
  late final TextEditingController _to;
  late final TextEditingController _terminal;
  late final TextEditingController _gate;
  late final TextEditingController _seat;
  late final TextEditingController _reference;
  late DateTime _departure;
  late DateTime _arrival;
  TimeOfDay? _boarding;
  late FlightCheckInStatus _checkIn;

  @override
  void initState() {
    super.initState();
    final flight = widget.flight;
    final trip = ref.read(tripProvider(widget.tripId))!;
    _airline = TextEditingController(text: flight?.airline ?? '');
    _number = TextEditingController(text: flight?.flightNumber ?? '');
    _from = TextEditingController(text: flight?.fromAirport ?? '');
    _to = TextEditingController(text: flight?.toAirport ?? '');
    _terminal = TextEditingController(text: flight?.terminal ?? '');
    _gate = TextEditingController(text: flight?.gate ?? '');
    _seat = TextEditingController(text: flight?.seat ?? '');
    _reference = TextEditingController(text: flight?.bookingReference ?? '');
    final start = trip.startDate;
    _departure =
        flight?.departure ?? DateTime(start.year, start.month, start.day, 9);
    _arrival = flight?.arrival ?? _departure.add(const Duration(hours: 2));
    final boarding = flight?.boarding;
    _boarding = boarding == null
        ? null
        : TimeOfDay(hour: boarding.hour, minute: boarding.minute);
    _checkIn = flight?.checkInStatus ?? FlightCheckInStatus.notOpen;
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _airline,
      _number,
      _from,
      _to,
      _terminal,
      _gate,
      _seat,
      _reference,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _arrivalOk => !_arrival.isBefore(_departure);

  bool get _valid =>
      _airline.text.trim().isNotEmpty &&
      _number.text.trim().isNotEmpty &&
      _from.text.trim().isNotEmpty &&
      _to.text.trim().isNotEmpty &&
      _arrivalOk;

  String? _required(
    TextEditingController controller,
    String message, {
    required bool submitted,
  }) => submitted && controller.text.trim().isEmpty ? message : null;

  void _save() {
    final boarding = _boarding;
    final built = TripFlight(
      id: widget.flight?.id ?? ref.read(tripsProvider.notifier).newId('flight'),
      airline: _airline.text.trim(),
      flightNumber: _number.text.trim().toUpperCase(),
      fromAirport: _from.text.trim(),
      toAirport: _to.text.trim(),
      departure: _departure,
      arrival: _arrival,
      terminal: _terminal.text.trim(),
      gate: _gate.text.trim().toUpperCase(),
      seat: _seat.text.trim().toUpperCase(),
      boarding: boarding == null
          ? null
          : DateTime(
              _departure.year,
              _departure.month,
              _departure.day,
              boarding.hour,
              boarding.minute,
            ),
      bookingReference: _reference.text.trim().toUpperCase(),
      checkInStatus: _checkIn,
    );
    final existing = widget.flight != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            flights: existing
                ? <TripFlight>[
                    for (final flight in plan.flights)
                      if (flight.id == built.id) built else flight,
                  ]
                : <TripFlight>[...plan.flights, built],
          ),
          log: existing
              ? 'Updated flight ${built.flightNumber}'
              : 'Added flight ${built.flightNumber}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;

    return TripFormPage(
      title: flight == null ? 'Add Flight' : 'Edit Flight',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _valid,
      onSave: _save,
      onDelete: flight == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    flights: <TripFlight>[
                      for (final f in plan.flights)
                        if (f.id != flight.id) f,
                    ],
                  ),
                  log: 'Removed flight ${flight.flightNumber}',
                ),
      deleteTitle: 'Delete this flight?',
      deleteMessage: 'It will be removed from the trip and its timeline.',
      builder: (context, {required submitted}) => <Widget>[
        FieldPair(
          left: QaddyTextField(
            controller: _airline,
            label: 'Airline',
            hintText: 'Qantas',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: _required(_airline, 'Required', submitted: submitted),
            onChanged: (_) => setState(() {}),
          ),
          right: QaddyTextField(
            controller: _number,
            label: 'Flight Number',
            hintText: 'QF431',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            errorText: _required(_number, 'Required', submitted: submitted),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const TripFieldGap(),
        FieldPair(
          left: QaddyTextField(
            controller: _from,
            label: 'From',
            hintText: 'Sydney (SYD)',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: _required(_from, 'Required', submitted: submitted),
            onChanged: (_) => setState(() {}),
          ),
          right: QaddyTextField(
            controller: _to,
            label: 'To',
            hintText: 'Melbourne (MEL)',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: _required(_to, 'Required', submitted: submitted),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const FormLabel('Departure'),
        QaddyDateTimeField(
          label: 'Departure',
          value: _departure,
          onChanged: (value) => setState(() {
            _departure = value;
            if (_arrival.isBefore(value)) {
              _arrival = value.add(const Duration(hours: 2));
            }
          }),
        ),
        const FormLabel('Arrival'),
        QaddyDateTimeField(
          label: 'Arrival',
          value: _arrival,
          errorText: _arrivalOk ? null : 'Arrival must be after departure',
          onChanged: (value) => setState(() => _arrival = value),
        ),
        const FormLabel('At the airport'),
        FieldPair(
          left: QaddyTextField(
            controller: _terminal,
            label: 'Terminal',
            textInputAction: TextInputAction.next,
          ),
          right: QaddyTextField(
            controller: _gate,
            label: 'Gate',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
        ),
        const TripFieldGap(),
        FieldPair(
          left: QaddyTextField(
            controller: _seat,
            label: 'Seat',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
          right: QaddyTimeField(
            label: 'Boarding',
            value: _boarding,
            onChanged: (time) => setState(() => _boarding = time),
          ),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _reference,
          label: 'Booking Reference',
          textCapitalization: TextCapitalization.characters,
        ),
        const FormLabel('Check-in'),
        QaddyChipSelector<FlightCheckInStatus>(
          options: const <QaddyChipOption<FlightCheckInStatus>>[
            QaddyChipOption(
              value: FlightCheckInStatus.notOpen,
              label: 'Not open',
            ),
            QaddyChipOption(value: FlightCheckInStatus.open, label: 'Open'),
            QaddyChipOption(
              value: FlightCheckInStatus.checkedIn,
              label: 'Checked in',
            ),
          ],
          selected: _checkIn,
          onChanged: (value) => setState(() => _checkIn = value),
        ),
      ],
    );
  }
}
