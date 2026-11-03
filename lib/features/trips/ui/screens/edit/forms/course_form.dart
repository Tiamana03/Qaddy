/// Add or edit a course and its tee time.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_golf.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The course form. Pass [course] to edit one; omit it to add.
class CourseForm extends ConsumerStatefulWidget {
  const CourseForm({
    required this.tripId,
    required this.fallbackRoute,
    this.course,
    super.key,
  });

  /// The trip the course belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The course being edited, or `null` when adding.
  final TripCourse? course;

  @override
  ConsumerState<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends ConsumerState<CourseForm> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _website;
  late final TextEditingController _rating;
  late final TextEditingController _slope;
  late final TextEditingController _fee;
  late final TextEditingController _dressCode;
  late final TextEditingController _notes;
  late DateTime _teeTime;
  late Set<String> _players;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    final plan = ref.read(tripPlanProvider(widget.tripId));
    final start = ref.read(tripProvider(widget.tripId))!.startDate;
    _name = TextEditingController(text: course?.name ?? '');
    _address = TextEditingController(text: course?.address ?? '');
    _phone = TextEditingController(text: course?.phone ?? '');
    _website = TextEditingController(text: course?.website ?? '');
    _rating = TextEditingController(text: _text(course?.courseRating));
    _slope = TextEditingController(text: course?.slope?.toString() ?? '');
    _fee = TextEditingController(text: _text(course?.greenFee));
    _dressCode = TextEditingController(text: course?.dressCode ?? '');
    _notes = TextEditingController(text: course?.notes ?? '');
    _teeTime =
        course?.teeTime ?? DateTime(start.year, start.month, start.day, 8, 10);
    _players = course == null
        ? <String>{for (final m in plan.confirmedMembers) m.displayName}
        : course.players.toSet();
  }

  static String _text(double? value) {
    if (value == null) {
      return '';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _name,
      _address,
      _phone,
      _website,
      _rating,
      _slope,
      _fee,
      _dressCode,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? get _ratingValue => double.tryParse(_rating.text.trim());
  int? get _slopeValue => int.tryParse(_slope.text.trim());
  double? get _feeValue => parseAmount(_fee.text);

  /// Optional numbers may be blank, but if typed they must make sense.
  bool get _numbersOk =>
      (_rating.text.trim().isEmpty || _ratingValue != null) &&
      (_slope.text.trim().isEmpty || _slopeValue != null) &&
      (_fee.text.trim().isEmpty || _feeValue != null);

  bool get _valid => _name.text.trim().isNotEmpty && _numbersOk;

  void _save() {
    final plan = ref.read(tripPlanProvider(widget.tripId));
    // Keep the players in the order they appear on the trip.
    final players = <String>[
      for (final member in plan.members)
        if (_players.contains(member.displayName)) member.displayName,
    ];
    final built = TripCourse(
      id: widget.course?.id ?? ref.read(tripsProvider.notifier).newId('course'),
      name: _name.text.trim(),
      teeTime: _teeTime,
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      website: _website.text.trim(),
      courseRating: _ratingValue,
      slope: _slopeValue,
      players: players,
      greenFee: _feeValue,
      dressCode: _dressCode.text.trim(),
      notes: _notes.text.trim(),
    );
    final existing = widget.course != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            courses: existing
                ? <TripCourse>[
                    for (final c in plan.courses)
                      if (c.id == built.id) built else c,
                  ]
                : <TripCourse>[...plan.courses, built],
          ),
          log: existing
              ? 'Updated ${built.name}'
              : 'Added ${built.name} to the golf schedule',
        );
  }

  String? _numberError(
    TextEditingController controller,
    bool valid, {
    required bool submitted,
  }) => submitted && controller.text.trim().isNotEmpty && !valid
      ? 'Check this number'
      : null;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final plan = ref.watch(tripPlanProvider(widget.tripId));

    return TripFormPage(
      title: course == null ? 'Add course' : 'Edit course',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _valid,
      onSave: _save,
      onDelete: course == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    courses: <TripCourse>[
                      for (final c in plan.courses)
                        if (c.id != course.id) c,
                    ],
                  ),
                  log: 'Removed ${course.name}',
                ),
      deleteTitle: 'Delete this course?',
      deleteMessage: 'It will be removed from the golf schedule.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _name,
          label: 'Course name',
          hintText: 'Kingston Heath',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          errorText: submitted && _name.text.trim().isEmpty
              ? 'Which course?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const FormLabel('Tee time'),
        QaddyDateTimeField(
          label: 'Tee time',
          value: _teeTime,
          onChanged: (value) => setState(() => _teeTime = value),
        ),
        const FormLabel('Players'),
        QaddyMultiChipSelector<String>(
          options: memberChipOptions(plan),
          selected: _players,
          onChanged: (value) => setState(() => _players = value),
        ),
        const FormLabel('About the course'),
        QaddyTextField(
          controller: _address,
          label: 'Address',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const TripFieldGap(),
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
            controller: _rating,
            label: 'Course rating',
            hintText: '73.4',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]*')),
            ],
            errorText: _numberError(
              _rating,
              _ratingValue != null,
              submitted: submitted,
            ),
            onChanged: (_) => setState(() {}),
          ),
          right: QaddyTextField(
            controller: _slope,
            label: 'Slope',
            hintText: '131',
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            errorText: _numberError(
              _slope,
              _slopeValue != null,
              submitted: submitted,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _fee,
          label: 'Green Fee (per player)',
          hintText: r'$250',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _numberError(
            _fee,
            _feeValue != null,
            submitted: submitted,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _dressCode,
          label: 'Dress code',
          textCapitalization: TextCapitalization.sentences,
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
      ],
    );
  }
}
