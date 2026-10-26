/// Qaddy's date and time pickers, styled as form fields.
///
/// Each looks and behaves like `QaddyTextField` (same decoration, label and
/// error styling) but opens the platform picker instead of a keyboard. They
/// hold no state of their own: the parent owns the value and passes the
/// chosen one back through `onChanged`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/forms/qaddy_input_decoration.dart';

/// A form field that picks a calendar date.
class QaddyDateField extends StatelessWidget {
  const QaddyDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.errorText,
    super.key,
  });

  /// The field label.
  final String label;

  /// The chosen date, or `null` when none is chosen yet.
  final DateTime? value;

  /// Called with the date the user picks.
  final ValueChanged<DateTime> onChanged;

  /// The earliest selectable date (defaults to five years ago).
  final DateTime? firstDate;

  /// The latest selectable date (defaults to ten years ahead).
  final DateTime? lastDate;

  /// Error message. Non-null switches the field into its error state.
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final earliest = firstDate ?? DateTime(now.year - 5);
    final latest = lastDate ?? DateTime(now.year + 10);
    var initial = value ?? now;
    // The picker rejects an initial date outside its range (e.g. an end date
    // opening on today when the trip starts next month).
    if (initial.isBefore(earliest)) {
      initial = earliest;
    } else if (initial.isAfter(latest)) {
      initial = latest;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latest,
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      label: label,
      text: value?.toFriendlyDate(),
      icon: Icons.calendar_today_outlined,
      errorText: errorText,
      onTap: () => _pick(context),
    );
  }
}

/// A form field that picks a time of day.
class QaddyTimeField extends StatelessWidget {
  const QaddyTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  /// The field label.
  final String label;

  /// The chosen time, or `null` when none is chosen yet.
  final TimeOfDay? value;

  /// Called with the time the user picks.
  final ValueChanged<TimeOfDay> onChanged;

  /// Error message. Non-null switches the field into its error state.
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = value;
    return _PickerField(
      label: label,
      text: time == null
          ? null
          : DateTime(2000, 1, 1, time.hour, time.minute).toFriendlyTime(),
      icon: Icons.schedule,
      errorText: errorText,
      onTap: () => _pick(context),
    );
  }
}

/// A date field and a time field side by side, bound to one [DateTime].
class QaddyDateTimeField extends StatelessWidget {
  const QaddyDateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  /// The label prefixing both fields (e.g. "Tee time").
  final String label;

  /// The chosen moment, or `null`.
  final DateTime? value;

  /// Called whenever either the date or the time changes. Until both have
  /// been chosen, the missing half defaults to the current day / 9:00 AM.
  final ValueChanged<DateTime> onChanged;

  /// Error message shown beneath the date half.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final current = value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: QaddyDateField(
            label: '$label date',
            value: current,
            errorText: errorText,
            onChanged: (date) => onChanged(
              DateTime(
                date.year,
                date.month,
                date.day,
                current?.hour ?? 9,
                current?.minute ?? 0,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          flex: 2,
          child: QaddyTimeField(
            label: 'Time',
            value: current == null
                ? null
                : TimeOfDay(hour: current.hour, minute: current.minute),
            onChanged: (time) {
              final base = current ?? DateTime.now();
              onChanged(
                DateTime(
                  base.year,
                  base.month,
                  base.day,
                  time.hour,
                  time.minute,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.text,
    required this.icon,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String? text;
  final IconData icon;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      label: text == null ? label : '$label, $text',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          isEmpty: text == null,
          decoration: buildQaddyInputDecoration(
            context: context,
            enabled: true,
            label: label,
            errorText: errorText,
            suffixIcon: Icon(icon, color: colours.textSecondary),
          ),
          child: Text(
            text ?? '',
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
        ),
      ),
    );
  }
}
