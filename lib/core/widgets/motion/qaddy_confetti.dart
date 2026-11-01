/// A single burst of confetti, for the moments that deserve one (winning a
/// round). It plays once, falls away and stops — nothing loops — and is skipped
/// entirely when the user has asked to reduce motion.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// Draws a burst of confetti over its parent (put it in a `Stack`). It never
/// takes taps.
class QaddyConfetti extends StatelessWidget {
  const QaddyConfetti({
    this.pieces = 70,
    this.duration = const Duration(milliseconds: 2600),
    super.key,
  });

  /// How many pieces fall.
  final int pieces;

  /// How long the burst lasts.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final palette = <Color>[
      colours.gold,
      colours.accentTeal,
      colours.accentSky,
      colours.accentPink,
      colours.accentOrange,
    ];

    return IgnorePointer(
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: duration,
          builder: (context, t, _) => t >= 1
              ? const SizedBox.shrink()
              : CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(
                    progress: t,
                    pieces: pieces,
                    palette: palette,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.pieces,
    required this.palette,
  });

  final double progress;
  final int pieces;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    // A fixed seed: the same burst every time, and nothing to store.
    final random = math.Random(7);
    final fade = progress < 0.75 ? 1.0 : (1 - progress) / 0.25;

    for (var i = 0; i < pieces; i++) {
      final x0 = random.nextDouble();
      final drift = (random.nextDouble() - 0.5) * 0.25;
      final speed = 0.6 + random.nextDouble() * 0.7;
      final spin = random.nextDouble() * math.pi * 4;
      final side = 5 + random.nextDouble() * 5;
      final colour = palette[i % palette.length];

      // Pieces start above the top edge and fall, easing in like gravity.
      final fall = (progress * speed).clamp(0.0, 1.0);
      final y = -side + (size.height + side * 2) * fall * fall;
      final x = size.width * (x0 + drift * progress);

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(spin * progress)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: side,
            height: side * 0.55,
          ),
          Paint()..color = colour.withValues(alpha: fade.clamp(0.0, 1.0)),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
