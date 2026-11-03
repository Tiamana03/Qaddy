/// Add or edit a planned activity or meal, or a checklist task.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/core/widgets/forms/qaddy_switch_row.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';
import 'package:qaddy/features/trips/models/trip_itinerary.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_page.dart';

/// The kinds of plan a golfer adds by hand. Flights, stays, tee times and
/// transport come from their own sections, so they are not offered here.
const List<ItineraryKind> _manualKinds = <ItineraryKind>[
  ItineraryKind.food,
  ItineraryKind.activity,
  ItineraryKind.other,
];

/// The activity form. Pass [item] to edit one; omit it to add.
class ActivityForm extends ConsumerStatefulWidget {
  const ActivityForm({
    required this.tripId,
    required this.fallbackRoute,
    this.item,
    super.key,
  });

  /// The trip the activity belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The activity being edited, or `null` when adding.
  final TripItineraryItem? item;

  @override
  ConsumerState<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<ActivityForm> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late ItineraryKind _kind;
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final trip = ref.read(tripProvider(widget.tripId))!;
    _title = TextEditingController(text: item?.title ?? '');
    _location = TextEditingController(text: item?.location ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _kind = item?.kind ?? ItineraryKind.food;
    final day = trip.startDate;
    _start = item?.start ?? DateTime(day.year, day.month, day.day, 19);
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final built = TripItineraryItem(
      id: widget.item?.id ?? ref.read(tripsProvider.notifier).newId('plan'),
      kind: _kind,
      title: _title.text.trim(),
      start: _start,
      location: _location.text.trim(),
      notes: _notes.text.trim(),
    );
    final existing = widget.item != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            itinerary: existing
                ? <TripItineraryItem>[
                    for (final i in plan.itinerary)
                      if (i.id == built.id) built else i,
                  ]
                : <TripItineraryItem>[...plan.itinerary, built],
          ),
          log:
              '${existing ? 'Updated' : 'Added'} ${built.title} '
              '(${built.start.toShortWeekdayAndDate()})',
        );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    // An item of a kind not offered for new plans keeps its own kind.
    final kinds = <ItineraryKind>[
      ..._manualKinds,
      if (!_manualKinds.contains(_kind)) _kind,
    ];

    return TripFormPage(
      title: item == null ? 'Add activity' : 'Edit activity',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _title.text.trim().isNotEmpty,
      onSave: _save,
      onDelete: item == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    itinerary: <TripItineraryItem>[
                      for (final i in plan.itinerary)
                        if (i.id != item.id) i,
                    ],
                  ),
                  log: 'Removed ${item.title}',
                ),
      deleteTitle: 'Delete this plan?',
      deleteMessage: 'It will be removed from the daily timeline.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _title,
          label: 'What are you doing?',
          hintText: 'Dinner at Rosetta',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          errorText: submitted && _title.text.trim().isEmpty
              ? 'Give it a name'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const FormLabel('Type'),
        QaddyChipSelector<ItineraryKind>(
          options: <QaddyChipOption<ItineraryKind>>[
            for (final kind in kinds)
              QaddyChipOption(value: kind, label: kind.label, icon: kind.icon),
          ],
          selected: _kind,
          onChanged: (value) => setState(() => _kind = value),
        ),
        const FormLabel('When'),
        QaddyDateTimeField(
          label: 'Start',
          value: _start,
          onChanged: (value) => setState(() => _start = value),
        ),
        const TripFieldGap(),
        QaddyTextField(
          controller: _location,
          label: 'Where',
          hintText: 'Restaurant or venue',
          textCapitalization: TextCapitalization.words,
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

/// The checklist task form. Pass [task] to edit one; omit it to add.
class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({
    required this.tripId,
    required this.fallbackRoute,
    this.task,
    super.key,
  });

  /// The trip the task belongs to.
  final String tripId;

  /// Where to go if there is nothing to pop back to.
  final String fallbackRoute;

  /// The task being edited, or `null` when adding.
  final TripTask? task;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  late final TextEditingController _title = TextEditingController(
    text: widget.task?.title ?? '',
  );
  late DateTime? _due = widget.task?.due;
  late bool _done = widget.task?.done ?? false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final built = TripTask(
      id: widget.task?.id ?? ref.read(tripsProvider.notifier).newId('task'),
      title: _title.text.trim(),
      done: _done,
      due: _due,
    );
    final existing = widget.task != null;
    ref
        .read(tripsProvider.notifier)
        .updatePlan(
          widget.tripId,
          (plan) => plan.copyWith(
            tasks: existing
                ? <TripTask>[
                    for (final t in plan.tasks)
                      if (t.id == built.id) built else t,
                  ]
                : <TripTask>[...plan.tasks, built],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return TripFormPage(
      title: task == null ? 'Add task' : 'Edit task',
      fallbackRoute: widget.fallbackRoute,
      validate: () => _title.text.trim().isNotEmpty,
      onSave: _save,
      onDelete: task == null
          ? null
          : () => ref
                .read(tripsProvider.notifier)
                .updatePlan(
                  widget.tripId,
                  (plan) => plan.copyWith(
                    tasks: <TripTask>[
                      for (final t in plan.tasks)
                        if (t.id != task.id) t,
                    ],
                  ),
                ),
      deleteTitle: 'Delete this task?',
      deleteMessage: 'It will be removed from the checklist.',
      builder: (context, {required submitted}) => <Widget>[
        QaddyTextField(
          controller: _title,
          label: 'Task',
          hintText: 'Book the Saturday dinner',
          textCapitalization: TextCapitalization.sentences,
          errorText: submitted && _title.text.trim().isEmpty
              ? 'What needs doing?'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const TripFieldGap(),
        QaddyDateField(
          label: 'Due date (optional)',
          value: _due,
          onChanged: (date) => setState(() => _due = date),
        ),
        if (_due != null)
          Align(
            alignment: Alignment.centerLeft,
            child: QaddyTertiaryButton(
              label: 'Clear due date',
              onPressed: () => setState(() => _due = null),
            ),
          ),
        const TripFieldGap(),
        QaddySwitchRow(
          title: 'Done',
          value: _done,
          onChanged: (value) => setState(() => _done = value),
        ),
      ],
    );
  }
}
