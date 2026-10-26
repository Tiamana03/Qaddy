/// Add or edit a manual weather forecast day, or a packing-list item.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_switch_row.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_weather.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The weather form. Forecasts are typed in by hand (there is no weather
/// service yet). Pass [day] to edit one; omit it to add.
class WeatherForm extends ConsumerStatefulWidget {
  const WeatherForm({
    required this.tripId,
    required this.fallbackRoute,
    this.day,
    super.key,
  });

  /// The trip the forecast belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The forecast being edited, or `null` when adding.
  final TripWeatherForecast? day;

  @override
  ConsumerState<WeatherForm> createState() => _WeatherFormState();
}

class _WeatherFormState extends ConsumerState<WeatherForm> {
  late final TextEditingController _day;
  late final TextEditingController _high;
  late final TextEditingController _low;
  late WeatherCondition _condition;

  @override
  void initState() {
    super.initState();
    final day = widget.day;
    _day = TextEditingController(text: day?.day ?? '');
    _high = TextEditingController(text: day == null ? '' : '${day.high}');
    _low = TextEditingController(text: day == null ? '' : '${day.low}');
    _condition = day?.condition ?? WeatherCondition.sunny;
  }

  @override
  void dispose() {
    _day.dispose();
    _high.dispose();
    _low.dispose();
    super.dispose();
  }

  int? get _highValue => int.tryParse(_high.text.trim());
  int? get _lowValue => int.tryParse(_low.text.trim());

  bool get _valid =>
      _day.text.trim().isNotEmpty && _highValue != null && _lowValue != null;

  void _save() {
    final built = TripWeatherForecast(
      id: widget.day?.id ?? ref.read(tripsProvider.notifier).newId('weather'),
      day: _day.text.trim(),
      condition: _condition,
      high: _highValue!,
      low: _lowValue!,
    );
    final existing = widget.day != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            weather: existing
                ? <TripWeatherForecast>[
                    for (final d in plan.weather)
                      if (d.id == built.id) built else d,
                  ]
                : <TripWeatherForecast>[...plan.weather, built],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;

    return TripFormPage(
      title: day == null ? 'Add Forecast Day' : 'Edit Forecast Day',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _valid,
      onSave: _save,
      onDelete: day == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    weather: <TripWeatherForecast>[
                      for (final d in plan.weather)
                        if (d.id != day.id) d,
                    ],
                  ),
                ),
      deleteTitle: 'Delete this forecast?',
      deleteMessage: 'This day will be removed from the weather list.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _day,
          label: 'Day',
          hintText: 'Saturday',
          textCapitalization: TextCapitalization.words,
          errorText: submitted && _day.text.trim().isEmpty
              ? 'Which day?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const FormLabel('Conditions'),
        QaddyChipSelector<WeatherCondition>(
          options: <QaddyChipOption<WeatherCondition>>[
            for (final condition in WeatherCondition.values)
              QaddyChipOption(
                value: condition,
                label: condition.label,
                icon: condition.icon,
              ),
          ],
          selected: _condition,
          onChanged: (value) => setState(() => _condition = value),
        ),
        const FormLabel('Temperature (°C)'),
        FieldPair(
          left: QaddyTextField(
            controller: _high,
            label: 'High',
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
            ],
            errorText: submitted && _highValue == null ? 'Number' : null,
            onChanged: (_) => setState(() {}),
          ),
          right: QaddyTextField(
            controller: _low,
            label: 'Low',
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
            ],
            errorText: submitted && _lowValue == null ? 'Number' : null,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}

/// The packing-list form. Pass [item] to edit one; omit it to add.
class PackingForm extends ConsumerStatefulWidget {
  const PackingForm({
    required this.tripId,
    required this.fallbackRoute,
    this.item,
    super.key,
  });

  /// The trip the item belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The item being edited, or `null` when adding.
  final PackingItem? item;

  @override
  ConsumerState<PackingForm> createState() => _PackingFormState();
}

class _PackingFormState extends ConsumerState<PackingForm> {
  late final TextEditingController _label = TextEditingController(
    text: widget.item?.label ?? '',
  );
  late bool _packed = widget.item?.packed ?? false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _save() {
    final built = PackingItem(
      id: widget.item?.id ?? ref.read(tripsProvider.notifier).newId('pack'),
      label: _label.text.trim(),
      packed: _packed,
    );
    final existing = widget.item != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            packing: existing
                ? <PackingItem>[
                    for (final i in plan.packing)
                      if (i.id == built.id) built else i,
                  ]
                : <PackingItem>[...plan.packing, built],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return TripFormPage(
      title: item == null ? 'Add Packing Item' : 'Edit Packing Item',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _label.text.trim().isNotEmpty,
      onSave: _save,
      onDelete: item == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    packing: <PackingItem>[
                      for (final i in plan.packing)
                        if (i.id != item.id) i,
                    ],
                  ),
                ),
      deleteTitle: 'Delete this item?',
      deleteMessage: 'It will be removed from the packing list.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _label,
          label: 'Item',
          hintText: 'Rain jacket',
          textCapitalization: TextCapitalization.sentences,
          errorText: submitted && _label.text.trim().isEmpty
              ? 'What are you packing?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        QaddySwitchRow(
          title: 'Packed',
          value: _packed,
          onChanged: (value) => setState(() => _packed = value),
        ),
      ],
    );
  }
}
