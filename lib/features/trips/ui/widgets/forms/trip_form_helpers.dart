/// Small helpers shared by the Edit Trip item forms.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// Reads a money amount typed by a golfer: "$1,250.50", "1250", " 40 ".
/// Returns `null` for blank or unparseable text.
double? parseAmount(String text) {
  final cleaned = text.replaceAll(RegExp(r'[\s$,]'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  return double.tryParse(cleaned);
}

/// One chip per confirmed member of the trip (organiser included), for
/// choosing who is on a course, in a room, or sharing an expense.
List<QaddyChipOption<String>> memberChipOptions(TripPlan plan) =>
    <QaddyChipOption<String>>[
      for (final member in plan.confirmedMembers)
        QaddyChipOption<String>(
          value: member.displayName,
          label: member.displayName,
        ),
    ];

/// A small heading above a group of related fields in a form.
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key});

  /// The heading.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.only(top: spacing.lg, bottom: spacing.sm),
      child: Text(
        text,
        style: typography.body.copyWith(
          color: colours.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Two fields side by side (each takes half the width).
class FieldPair extends StatelessWidget {
  const FieldPair({required this.left, required this.right, super.key});

  /// The first field.
  final Widget left;

  /// The second field.
  final Widget right;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: left),
        SizedBox(width: spacing.md),
        Expanded(child: right),
      ],
    );
  }
}
