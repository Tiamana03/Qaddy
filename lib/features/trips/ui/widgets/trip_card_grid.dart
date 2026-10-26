/// Lays trip cards out in 1, 2 or 3 columns by screen size.
///
/// `docs/sprints/sprint-03-01-trips-foundation.md`'s Responsive Behaviour
/// asks for one column on mobile, two on tablet and three on desktop; the
/// list was previously a single column everywhere. Rows are built eagerly,
/// which is fine for a golfer's handful of trips — revisit with a lazy
/// sliver grid if lists grow into the hundreds.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// A responsive grid of equally sized cards.
class TripCardGrid extends StatelessWidget {
  const TripCardGrid({required this.children, super.key});

  /// The cards, in reading order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final columns = context.isMobile ? 1 : (context.isTablet ? 2 : 3);

    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final end = (start + columns).clamp(0, children.length);
      final slice = children.sublist(start, end);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var i = 0; i < columns; i++) ...<Widget>[
              if (i > 0) SizedBox(width: spacing.cardGap),
              Expanded(child: i < slice.length ? slice[i] : const SizedBox()),
            ],
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (final (index, row) in rows.indexed) ...<Widget>[
          if (index > 0) SizedBox(height: spacing.cardGap),
          row,
        ],
      ],
    );
  }
}
