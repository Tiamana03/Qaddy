/// A photo slot: the place a course, trip or hero photograph goes.
///
/// Until the final photography arrives (see `docs/design/asset-register.md`)
/// the slot shows a quiet drawn course (sky, two rolling fairways and a flag)
/// in the theme's greens, at exactly the size, shape and position the photo
/// will have, with the same dark scrim at the bottom that keeps overlaid text
/// readable. Pass `image` and the photograph replaces the drawing; nothing
/// else about the screen changes.
library;

// The painters draw one layer after another; cascading every canvas call would
// hide the order the picture is built in.
// ignore_for_file: cascade_invocations

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// A rounded photo slot with a drawn-course placeholder.
class QaddyMediaPlaceholder extends StatelessWidget {
  const QaddyMediaPlaceholder({
    this.image,
    this.borderRadius = BorderRadius.zero,
    this.scrim = false,
    this.child,
    this.tone = 0,
    this.aerial = false,
    this.coastal = false,
    super.key,
  });

  /// The final photograph. Leave `null` to show the placeholder drawing.
  final ImageProvider? image;

  /// The slot's corners.
  final BorderRadius borderRadius;

  /// Darkens the bottom of the slot so text drawn over it stays readable.
  final bool scrim;

  /// What is drawn over the slot (a title, a weather card).
  final Widget? child;

  /// Which of a few tones the drawing takes (0 sea-green, 1 dusk, 2 forest),
  /// so neighbouring slots are not identical.
  final int tone;

  /// Draws the course as seen from above (a hole view): trees, a fairway
  /// ribbon, a green with its flag and a bunker.
  final bool aerial;

  /// Draws a bright coastal course at golden hour (sky, sea, a headland of
  /// trees, rolling fairway and a flag): the Home hero.
  final bool coastal;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (image != null)
            Image(image: image!, fit: BoxFit.cover)
          else
            CustomPaint(
              painter: aerial
                  ? _AerialPainter(colours: colours)
                  : coastal
                  ? _CoastalPainter(tone: tone)
                  : _CoursePainter(colours: colours, tone: tone),
            ),
          if (scrim)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x00000000), Color(0xB3000000)],
                  stops: <double>[0.45, 1],
                ),
              ),
            ),
          ?child,
        ],
      ),
    );
  }
}

class _CoursePainter extends CustomPainter {
  const _CoursePainter({required this.colours, required this.tone});

  final QaddyColours colours;
  final int tone;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = switch (tone) {
      1 => <Color>[const Color(0xFF1B2A4A), const Color(0xFF3B4F7A)],
      2 => <Color>[colours.surface2, colours.secondary],
      _ => <Color>[
        colours.accentSky.withValues(alpha: 0.55),
        colours.accentTeal,
      ],
    };
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(sky.first, colours.backgroundBase, 0.35)!,
            Color.lerp(sky.last, colours.backgroundBase, 0.15)!,
          ],
        ).createShader(Offset.zero & size),
    );

    final w = size.width;
    final h = size.height;
    Path hill(double y0, double y1, double lift) => Path()
      ..moveTo(0, h * y0)
      ..cubicTo(w * 0.3, h * (y0 - lift), w * 0.65, h * (y1 + lift), w, h * y1)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas
      ..drawPath(
        hill(0.62, 0.55, 0.08),
        Paint()..color = colours.secondary.withValues(alpha: 0.85),
      )
      ..drawPath(
        hill(0.78, 0.7, 0.07),
        Paint()
          ..color = Color.lerp(colours.selected, colours.backgroundBase, 0.45)!,
      )
      ..drawPath(
        hill(0.92, 0.88, 0.04),
        Paint()..color = colours.primary.withValues(alpha: 0.95),
      );

    // A pin on the far green.
    final px = w * 0.72;
    final py = h * 0.6;
    canvas
      ..drawLine(
        Offset(px, py),
        Offset(px, py - h * 0.16),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 1.5,
      )
      ..drawPath(
        Path()
          ..moveTo(px, py - h * 0.16)
          ..lineTo(px + w * 0.05, py - h * 0.135)
          ..lineTo(px, py - h * 0.11)
          ..close(),
        Paint()..color = colours.gold,
      );
  }

  @override
  bool shouldRepaint(_CoursePainter old) =>
      old.colours != colours || old.tone != tone;
}

/// A hole from above, as an aerial photograph would show it: a canopy of
/// trees in many greens with soft shadows, a mown fairway in stripes bending up
/// to a green with its flag, a bunker and a cart path.
class _AerialPainter extends CustomPainter {
  const _AerialPainter({required this.colours});

  final QaddyColours colours;

  /// The fairway's centre line at [t] (0 at the tee, 1 at the green), as a
  /// fraction of the width.
  static double _centre(double t) => 0.52 - 0.07 * math.sin(t * math.pi * 1.1);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bounds = Offset.zero & size;

    // The rough: a deep green, lighter in the middle.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.1, 0.1),
          radius: 1,
          colors: <Color>[Color(0xFF2F6B2C), Color(0xFF123A18)],
        ).createShader(bounds),
    );

    // The tree canopy, kept off the fairway. The seed is fixed so the picture
    // never shimmers between frames.
    const palette = <Color>[
      Color(0xFF0E3A17),
      Color(0xFF1B5A24),
      Color(0xFF2A7A31),
      Color(0xFF3C913A),
      Color(0xFF14461C),
      Color(0xFF4E9F42),
    ];
    var seed = 5;
    double next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    bool onFairway(double x, double y, double margin) {
      final t = 1 - y / h;
      final half = w * (0.085 + 0.03 * (1 - t) - 0.02 * t) + margin;
      return (x - w * _centre(t)).abs() < half;
    }

    for (var i = 0; i < 900; i++) {
      final x = next() * w;
      final y = next() * h;
      if (onFairway(x, y, h * 0.02)) {
        continue;
      }
      final r = h * (0.012 + 0.022 * next());
      final colour =
          palette[(next() * palette.length).floor() % palette.length];
      canvas
        ..drawCircle(
          Offset(x + r * 0.35, y + r * 0.4),
          r,
          Paint()..color = const Color(0x33000000),
        )
        ..drawCircle(Offset(x, y), r, Paint()..color = colour)
        ..drawCircle(
          Offset(x - r * 0.25, y - r * 0.3),
          r * 0.45,
          Paint()..color = Colors.white.withValues(alpha: 0.07),
        );
    }

    // The first cut of rough beside the fairway.
    Path ribbon(double halfTop, double halfBottom) {
      final path = Path();
      const steps = 24;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final y = h * (1 - t);
        final half = w * (halfBottom + (halfTop - halfBottom) * t);
        final x = w * _centre(t) - half;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      for (var i = steps; i >= 0; i--) {
        final t = i / steps;
        final y = h * (1 - t);
        final half = w * (halfBottom + (halfTop - halfBottom) * t);
        path.lineTo(w * _centre(t) + half, y);
      }
      return path..close();
    }

    canvas.drawPath(
      ribbon(0.085, 0.14),
      Paint()..color = const Color(0xFF4C9A3A),
    );

    // The fairway, mown in stripes.
    final fairway = ribbon(0.07, 0.115);
    canvas
      ..save()
      ..clipPath(fairway)
      ..drawRect(bounds, Paint()..color = const Color(0xFF6DB241));
    for (var i = 0; i < 14; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, h * (i / 14), w, h / 28),
        Paint()..color = const Color(0x2AFFFFFF),
      );
    }
    canvas.restore();

    // The mown line down the middle.
    final line = Path();
    for (var i = 0; i <= 24; i++) {
      final t = i / 24;
      final point = Offset(w * _centre(t), h * (1 - t));
      i == 0
          ? line.moveTo(point.dx, point.dy)
          : line.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = colours.gold.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // A cart path down the left edge of the rough.
    final path = Path();
    for (var i = 0; i <= 24; i++) {
      final t = i / 24;
      final point = Offset(w * (_centre(t) - 0.2 + 0.04 * t), h * (1 - t));
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xCCD8CBA8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // The green, its fringe and the flag.
    final green = Offset(w * _centre(0.86), h * 0.2);
    canvas
      ..drawCircle(green, h * 0.105, Paint()..color = const Color(0xFF58AE3E))
      ..drawCircle(green, h * 0.088, Paint()..color = const Color(0xFF7CC84B))
      ..drawCircle(
        green,
        h * 0.1,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )
      ..drawLine(
        green,
        green.translate(0, -h * 0.1),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      )
      ..drawPath(
        Path()
          ..moveTo(green.dx, green.dy - h * 0.1)
          ..lineTo(green.dx + h * 0.055, green.dy - h * 0.08)
          ..lineTo(green.dx, green.dy - h * 0.06)
          ..close(),
        Paint()..color = const Color(0xFFE0463A),
      );

    // Bunkers beside the green.
    void bunker(Offset at, double bw, double bh) {
      canvas
        ..drawOval(
          Rect.fromCenter(center: at, width: bw, height: bh),
          Paint()..color = const Color(0xFFE6D8B0),
        )
        ..drawOval(
          Rect.fromCenter(
            center: at.translate(-bw * 0.08, -bh * 0.1),
            width: bw * 0.75,
            height: bh * 0.7,
          ),
          Paint()..color = const Color(0xFFF3E8C9),
        );
    }

    bunker(Offset(w * (_centre(0.78) - 0.12), h * 0.3), w * 0.075, h * 0.12);
    bunker(Offset(w * (_centre(0.62) + 0.13), h * 0.44), w * 0.06, h * 0.09);
  }

  @override
  bool shouldRepaint(_AerialPainter old) => old.colours != colours;
}

/// A coastal course in the afternoon light: the placeholder for a wide hero
/// photograph.
class _CoastalPainter extends CustomPainter {
  const _CoastalPainter({required this.tone});

  /// Which of a few variations to draw (the flag and the sky move).
  final int tone;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bounds = Offset.zero & size;
    final horizon = h * 0.58;
    final flagX = <double>[0.86, 0.3, 0.62][tone % 3];

    // Sky.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF5E96D2),
            Color(0xFFA9C9E6),
            Color(0xFFF2E4C8),
          ],
          stops: <double>[0, 0.55, 0.78],
        ).createShader(Rect.fromLTWH(0, 0, w, horizon * 1.05)),
    );

    // The sea, left of a headland.
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, w * 0.6, h * 0.12),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF8DB4D6), Color(0xFF2F6C9E)],
        ).createShader(Rect.fromLTWH(0, horizon, w * 0.6, h * 0.12)),
    );

    // The headland and its trees.
    final headland = Path()
      ..moveTo(w * 0.34, horizon + h * 0.06)
      ..quadraticBezierTo(
        w * 0.42,
        horizon - h * 0.04,
        w * 0.58,
        horizon - h * 0.02,
      )
      ..lineTo(w, horizon - h * 0.03)
      ..lineTo(w, horizon + h * 0.2)
      ..lineTo(w * 0.3, horizon + h * 0.2)
      ..close();
    canvas.drawPath(headland, Paint()..color = const Color(0xFF3B5A2E));
    var seed = 11;
    double next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    for (var i = 0; i < 90; i++) {
      final x = w * (0.3 + 0.7 * next());
      final y = horizon + h * (0.0 + 0.13 * next());
      final r = h * (0.016 + 0.026 * next());
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF1F3B22),
            const Color(0xFF55772F),
            next(),
          )!,
      );
    }

    // The rolling fairway in front.
    final fairway = Path()
      ..moveTo(0, horizon + h * 0.2)
      ..cubicTo(
        w * 0.25,
        horizon + h * 0.12,
        w * 0.55,
        horizon + h * 0.2,
        w,
        horizon + h * 0.12,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      fairway,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFA2BE48),
            Color(0xFF6D9531),
            Color(0xFF4F7A27),
          ],
        ).createShader(Rect.fromLTWH(0, horizon, w, h - horizon)),
    );
    // A lighter mown stripe and a bunker.
    canvas
      ..drawPath(
        Path()
          ..moveTo(w * 0.1, h)
          ..cubicTo(w * 0.3, h * 0.82, w * 0.6, h * 0.8, w * 0.9, h * 0.7)
          ..lineTo(w * 0.95, h * 0.74)
          ..cubicTo(w * 0.65, h * 0.86, w * 0.4, h * 0.88, w * 0.25, h)
          ..close(),
        Paint()..color = const Color(0x33FFFFFF),
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.76),
          width: w * 0.18,
          height: h * 0.07,
        ),
        Paint()..color = const Color(0xFFE6D7B3),
      )
      // The flag.
      ..drawLine(
        Offset(w * flagX, h * 0.9),
        Offset(w * flagX, h * 0.56),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.4,
      )
      ..drawPath(
        Path()
          ..moveTo(w * flagX, h * 0.56)
          ..lineTo(w * (flagX + 0.04), h * 0.585)
          ..lineTo(w * flagX, h * 0.61)
          ..close(),
        Paint()..color = const Color(0xFFF2C94C),
      );
  }

  @override
  bool shouldRepaint(_CoastalPainter old) => old.tone != tone;
}
