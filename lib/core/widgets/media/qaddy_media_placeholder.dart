/// A photo slot: the place a course, trip or hero photograph goes.
///
/// Until the final photography arrives (see `docs/design/asset-register.md`)
/// the slot shows a quiet drawn course (sky, two rolling fairways and a flag)
/// in the theme's greens, at exactly the size, shape and position the photo
/// will have, with the same dark scrim at the bottom that keeps overlaid text
/// readable. Pass `image` and the photograph replaces the drawing; nothing
/// else about the screen changes.
library;

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

/// A hole from above: dark trees, a fairway ribbon bending up to a green with
/// a flag, and a bunker beside it.
class _AerialPainter extends CustomPainter {
  const _AerialPainter({required this.colours});

  final QaddyColours colours;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bounds = Offset.zero & size;

    // The rough: a deep green with a lighter middle.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, 0.1),
          radius: 1.1,
          colors: <Color>[
            Color.lerp(colours.selected, colours.backgroundBase, 0.55)!,
            Color.lerp(colours.primary, colours.backgroundBase, 0.6)!,
          ],
        ).createShader(bounds),
    );

    // Trees: soft dark blobs down both sides.
    final tree = Paint()..color = const Color(0x33000000);
    for (var i = 0; i < 26; i++) {
      final t = i / 25;
      final y = h * (0.04 + 0.92 * t);
      canvas
        ..drawCircle(
          Offset(w * (0.06 + 0.05 * ((i * 7) % 5) / 4), y),
          h * 0.06,
          tree,
        )
        ..drawCircle(
          Offset(w * (0.86 + 0.07 * ((i * 3) % 5) / 4), y),
          h * 0.065,
          tree,
        );
    }

    // The fairway: a ribbon from the tee at the bottom to the green.
    final fairway = Path()
      ..moveTo(w * 0.42, h)
      ..cubicTo(w * 0.36, h * 0.7, w * 0.5, h * 0.5, w * 0.46, h * 0.22)
      ..lineTo(w * 0.62, h * 0.22)
      ..cubicTo(w * 0.66, h * 0.5, w * 0.58, h * 0.7, w * 0.64, h)
      ..close();
    canvas.drawPath(
      fairway,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(colours.accentTeal, colours.selected, 0.6)!,
            colours.selected,
          ],
        ).createShader(bounds),
    );
    // The mown line down the middle, then the green and its flag.
    final green = Offset(w * 0.54, h * 0.2);
    canvas
      ..drawPath(
        Path()
          ..moveTo(w * 0.53, h)
          ..cubicTo(w * 0.47, h * 0.7, w * 0.58, h * 0.5, w * 0.54, h * 0.22),
        Paint()
          ..color = colours.gold.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      )
      ..drawCircle(green, h * 0.1, Paint()..color = colours.selected)
      ..drawCircle(
        green,
        h * 0.1,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      )
      ..drawLine(
        green,
        green.translate(0, -h * 0.09),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      )
      ..drawPath(
        Path()
          ..moveTo(green.dx, green.dy - h * 0.09)
          ..lineTo(green.dx + h * 0.05, green.dy - h * 0.07)
          ..lineTo(green.dx, green.dy - h * 0.05)
          ..close(),
        Paint()..color = colours.gold,
      )
      // A bunker beside the green.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.42, h * 0.3),
          width: w * 0.07,
          height: h * 0.1,
        ),
        Paint()..color = const Color(0xFFD9C9A0).withValues(alpha: 0.85),
      );
  }

  @override
  bool shouldRepaint(_AerialPainter old) => old.colours != colours;
}
