/// The picture slot for a club, as the Golf Bag mockup draws them: a dark tile
/// holding a product shot (a driver head, an iron, a putter, a ball).
///
/// Until product photography exists (see `docs/design/asset-register.md`) the
/// slot draws a quiet silhouette of the right kind of club in a soft
/// gradient, at the size and in the place the photograph will have.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// A club's picture slot.
class ClubPicture extends StatelessWidget {
  const ClubPicture({required this.family, this.width = 62, super.key});

  /// What kind of club to draw.
  final ClubFamily family;

  /// The slot's width; its height is 0.9 of that.
  final double width;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return SizedBox(
      width: width,
      height: width * 0.9,
      child: CustomPaint(painter: _ClubPainter(family, colours)),
    );
  }
}

class _ClubPainter extends CustomPainter {
  const _ClubPainter(this.family, this.colours);

  final ClubFamily family;
  final QaddyColours colours;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (family) {
      case ClubFamily.wood || ClubFamily.hybrid:
        // A dark rounded head with a gold crown line, on a short shaft.
        final head = Path()
          ..moveTo(w * 0.12, h * 0.55)
          ..cubicTo(w * 0.1, h * 0.2, w * 0.5, h * 0.05, w * 0.78, h * 0.28)
          ..cubicTo(w * 0.95, h * 0.45, w * 0.85, h * 0.85, w * 0.5, h * 0.92)
          ..cubicTo(w * 0.25, h * 0.95, w * 0.14, h * 0.78, w * 0.12, h * 0.55)
          ..close();
        canvas
          ..drawPath(
            head,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF4A5450), Color(0xFF0E1412)],
              ).createShader(Offset.zero & size),
          )
          ..drawPath(
            Path()
              ..moveTo(w * 0.22, h * 0.5)
              ..cubicTo(
                w * 0.3,
                h * 0.28,
                w * 0.6,
                h * 0.2,
                w * 0.76,
                h * 0.34,
              ),
            Paint()
              ..color = colours.gold.withValues(alpha: 0.85)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
      case ClubFamily.iron || ClubFamily.wedge:
        // A silver blade with grooves, angled on its hosel.
        final blade = Path()
          ..moveTo(w * 0.2, h * 0.3)
          ..lineTo(w * 0.86, h * 0.2)
          ..lineTo(w * 0.8, h * 0.72)
          ..lineTo(w * 0.3, h * 0.8)
          ..close();
        canvas.drawPath(
          blade,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFF2F4F3), Color(0xFF8A9490)],
            ).createShader(Offset.zero & size),
        );
        for (var i = 0; i < 4; i++) {
          final y = h * (0.34 + i * 0.1);
          canvas.drawLine(
            Offset(w * 0.34, y + h * 0.02),
            Offset(w * 0.74, y - h * 0.03),
            Paint()
              ..color = const Color(0x55000000)
              ..strokeWidth = 1,
          );
        }
        canvas.drawLine(
          Offset(w * 0.3, h * 0.8),
          Offset(w * 0.26, h * 0.98),
          Paint()
            ..color = const Color(0xFFB9C2BE)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      case ClubFamily.putter:
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.14, h * 0.5, w * 0.7, h * 0.22),
              Radius.circular(w * 0.05),
            ),
            Paint()..color = const Color(0xFFC9D0CC),
          )
          ..drawLine(
            Offset(w * 0.5, h * 0.5),
            Offset(w * 0.56, h * 0.05),
            Paint()
              ..color = const Color(0xFF8A9490)
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round,
          );
      case ClubFamily.ball:
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.5),
          h * 0.36,
          Paint()
            ..shader =
                const RadialGradient(
                  center: Alignment(-0.3, -0.4),
                  colors: <Color>[Colors.white, Color(0xFFC5CCC8)],
                ).createShader(
                  Rect.fromCircle(
                    center: Offset(w * 0.5, h * 0.5),
                    radius: h * 0.4,
                  ),
                ),
        );
        for (var i = 0; i < 7; i++) {
          canvas.drawCircle(
            Offset(w * (0.4 + 0.05 * (i % 3)), h * (0.4 + 0.06 * (i ~/ 3))),
            1,
            Paint()..color = const Color(0x33000000),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_ClubPainter old) =>
      old.family != family || old.colours != colours;
}
