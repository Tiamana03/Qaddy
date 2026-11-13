/// The little line beside the handicap figure in the Statistics mockup: a gold
/// polyline with a dot on each point and a soft wash beneath it.
///
/// Qaddy has no handicap history to draw, so this draws what it does have: the
/// points scored per round, oldest first.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// A sparkline of [values], oldest first.
class FormSparkline extends StatelessWidget {
  const FormSparkline({required this.values, super.key});

  /// The numbers to draw. One value draws a single dot.
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Semantics(
      container: true,
      label:
          'Points per round, oldest first: '
          '${values.map((v) => v.round()).join(', ')}.',
      excludeSemantics: true,
      child: CustomPaint(
        painter: _SparklinePainter(values, colours.gold),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values, this.colour);

  final List<double> values;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const inset = 6.0;
    final low = values.reduce((a, b) => a < b ? a : b);
    final high = values.reduce((a, b) => a > b ? a : b);
    // Never stretch a flat run into a cliff: keep at least six points of range.
    final range = (high - low) < 6 ? 6.0 : high - low;
    final mid = (high + low) / 2;

    Offset at(int index) {
      final x = values.length == 1
          ? inset
          : inset + (size.width - inset * 2) * index / (values.length - 1);
      final y =
          size.height / 2 -
          ((values[index] - mid) / range) * (size.height - 24);
      return Offset(x, y);
    }

    final points = <Offset>[for (var i = 0; i < values.length; i++) at(i)];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    if (points.length > 1) {
      final wash = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas
        ..drawPath(
          wash,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                colour.withValues(alpha: 0.22),
                colour.withValues(alpha: 0),
              ],
            ).createShader(Offset.zero & size),
        )
        ..drawPath(
          line,
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round,
        );
    }
    for (final point in points) {
      canvas.drawCircle(point, 3.6, Paint()..color = colour);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.colour != colour || old.values != values;
}
