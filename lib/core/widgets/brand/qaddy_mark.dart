/// Qaddy's mark: a golf ball on its tee inside a gold ring that draws itself.
/// The brand moment of the splash, onboarding and sign-in screens.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// The Qaddy mark, [size] across. When [animate] is true (and the platform has
/// not asked for reduced motion) the ring draws itself and the ball settles in;
/// otherwise it is simply there.
class QaddyMark extends StatelessWidget {
  const QaddyMark({this.size = 96, this.animate = true, super.key});

  /// The mark's diameter.
  final double size;

  /// Whether the mark draws itself in.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final animated = animate && !MediaQuery.disableAnimationsOf(context);

    Widget mark(double t) {
      final settle = QaddyMotion.standard.enter.transform(
        ((t - 0.35) / 0.65).clamp(0.0, 1.0),
      );
      return Semantics(
        label: 'Qaddy',
        image: true,
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colours.gold.withValues(alpha: 0.28 * t),
                  blurRadius: size * 0.4,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _RingPainter(
                progress: QaddyMotion.standard.enter.transform(
                  t.clamp(0.0, 1.0),
                ),
                colour: colours.gold,
                width: size * 0.05,
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.7 + 0.3 * settle,
                  child: Opacity(
                    opacity: settle.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.sports_golf,
                      color: colours.gold,
                      size: size * 0.46,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!animated) {
      return mark(1);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      builder: (context, t, _) => mark(t),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.colour,
    required this.width,
  });

  final double progress;
  final Color colour;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(width / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.colour != colour || old.width != width;
}
