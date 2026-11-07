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
              painter: _CoursePainter(colours: colours, tone: tone),
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
