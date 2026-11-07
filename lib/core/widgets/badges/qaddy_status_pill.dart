/// The small coloured pill the mockups use for where something stands:
/// "Round Ready", "Waiting on 2", "Paid", "Pending". Green is good, amber is
/// waiting, red needs attention.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';

/// How a status pill is coloured.
enum QaddyPillTone {
  /// Green: all good ("Finished", "Round ready").
  success,

  /// Amber: waiting ("Planned", "Waiting on 2").
  pending,

  /// Red: needs attention.
  danger,
}

/// A status pill.
class QaddyStatusPill extends StatelessWidget {
  const QaddyStatusPill({
    required this.label,
    this.tone = QaddyPillTone.pending,
    this.icon,
    this.filled = false,
    super.key,
  });

  /// The pill's text.
  final String label;

  /// The pill's colour.
  final QaddyPillTone tone;

  /// An icon after the text.
  final IconData? icon;

  /// A solid fill with dark text (the mockup's "Round Ready") rather than a
  /// tinted outline.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final colour = switch (tone) {
      QaddyPillTone.success => colours.success,
      QaddyPillTone.pending => colours.gold,
      QaddyPillTone.danger => colours.error,
    };
    final text = filled ? colours.backgroundBase : colour;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: filled ? colour : colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? colour : colour.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.pillLabel.copyWith(color: text),
            ),
          ),
          if (icon != null) ...<Widget>[
            const SizedBox(width: 5),
            Icon(icon, size: 14, color: text),
          ],
        ],
      ),
    );
  }
}
