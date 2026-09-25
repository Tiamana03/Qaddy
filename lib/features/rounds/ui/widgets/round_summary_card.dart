/// The Round Complete screen's Round Summary.
///
/// See `docs/sprints/sprint-02-05-round-complete.md`'s "Round Summary"
/// section.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';

/// Course, date, player count, completed holes, winner and round status.
class RoundSummaryCard extends StatelessWidget {
  const RoundSummaryCard({
    required this.courseName,
    required this.date,
    required this.playerCount,
    required this.completedHoles,
    required this.winnerNames,
    required this.roundStatus,
    super.key,
  });

  /// The course played.
  final String courseName;

  /// The round's date.
  final String date;

  /// How many players took part.
  final int playerCount;

  /// How many holes were completed.
  final int completedHoles;

  /// The winner's name, or names joined together on a tie.
  final String winnerNames;

  /// The round's final status (e.g. "Completed").
  final String roundStatus;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Round Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SummaryRow(label: 'Course', value: courseName),
          SizedBox(height: spacing.sm),
          _SummaryRow(label: 'Date', value: date),
          SizedBox(height: spacing.sm),
          _SummaryRow(label: 'Players', value: '$playerCount'),
          SizedBox(height: spacing.sm),
          _SummaryRow(label: 'Completed Holes', value: '$completedHoles'),
          SizedBox(height: spacing.sm),
          _SummaryRow(label: 'Winner', value: winnerNames),
          SizedBox(height: spacing.sm),
          _SummaryRow(label: 'Round Status', value: roundStatus),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: typography.body.copyWith(color: colours.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: spacing.sm),
        Text(
          value,
          style: typography.body.copyWith(
            color: colours.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
