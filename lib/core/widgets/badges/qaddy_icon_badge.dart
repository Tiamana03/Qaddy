/// A round, tinted badge holding an icon — the quiet colour that says what a
/// row or tile is about (a shortcut, a highlight, a trophy).
library;

import 'package:flutter/material.dart';

/// A circle of [colour] at low opacity with [icon] in full [colour].
class QaddyIconBadge extends StatelessWidget {
  const QaddyIconBadge({
    required this.icon,
    required this.colour,
    this.size = 40,
    this.iconSize,
    super.key,
  });

  /// The icon.
  final IconData icon;

  /// The accent: the icon's colour and, faded, the circle's.
  final Color colour;

  /// The circle's diameter.
  final double size;

  /// The icon's size; the icon's default when omitted.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colour.withValues(alpha: 0.18),
      ),
      child: Icon(icon, color: colour, size: iconSize),
    );
  }
}
