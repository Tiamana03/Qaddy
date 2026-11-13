/// "Performance by Hole", as the Statistics mockup draws it: eighteen bars
/// around an E line, green where the golfer beats par on average, gold where
/// the hole beats them, with the hole numbers beneath and a three-part key.
///
/// A hole's bar is its average Stableford points against the two a par is
/// worth: up is better than par, down is worse. Holes not yet played are a
/// short grey stub, so the row always shows all eighteen.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// The eighteen-hole bar chart.
class HoleBars extends StatelessWidget {
  const HoleBars({required this.holes, super.key});

  /// What is known of each hole played.
  final List<HoleStat> holes;

  static const double _plot = 56;
  static const double _axis = 24;

  /// How far a bar can reach either side of par, in points.
  static const double _reach = 2;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final byNumber = <int, HoleStat>{
      for (final hole in holes) hole.number: hole,
    };
    final label = QaddyText.tileLabel.copyWith(color: colours.textSecondary);

    final description = <String>[
      for (var n = 1; n <= 18; n++)
        if (byNumber[n] case final hole?)
          'Hole $n: ${hole.averagePoints.toStringAsFixed(1)} points on average',
    ].join('. ');

    return Column(
      children: <Widget>[
        Semantics(
          container: true,
          label: 'Performance by hole. $description.',
          excludeSemantics: true,
          child: SizedBox(
            height: _plot + 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: _axis,
                  height: _plot,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('+2', style: label),
                      Text('E', style: label),
                      Text('-2', style: label),
                    ],
                  ),
                ),
                for (var n = 1; n <= 18; n++)
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: _plot,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _BarPainter(
                              delta: byNumber[n] == null
                                  ? null
                                  : byNumber[n]!.averagePoints - _reach,
                              better: Color.lerp(
                                colours.success,
                                Colors.white,
                                0.12,
                              )!,
                              worse: colours.gold,
                              level: Colors.white.withValues(alpha: 0.72),
                              line: colours.border,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$n',
                          maxLines: 1,
                          style: label.copyWith(fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 6,
          children: <Widget>[
            _Key(
              colour: Color.lerp(colours.success, colours.backgroundBase, 0.2)!,
              text: 'Better than par',
            ),
            _Key(colour: Colors.white.withValues(alpha: 0.72), text: 'Par'),
            _Key(colour: colours.gold, text: 'Worse than par'),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.colour, required this.text});

  final Color colour;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colour,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: QaddyText.tileLabel.copyWith(color: colours.textSecondary),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({
    required this.delta,
    required this.better,
    required this.worse,
    required this.level,
    required this.line,
  });

  /// Average points minus par's two; `null` for a hole not yet played.
  final double? delta;
  final Color better;
  final Color worse;
  final Color level;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final barWidth = (size.width - 5).clamp(3.0, 11.0);
    final left = (size.width - barWidth) / 2;

    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = line
        ..strokeWidth = 1,
    );

    final value = delta;
    Rect bar;
    Color colour;
    if (value == null) {
      bar = Rect.fromLTWH(left, mid - 2, barWidth, 4);
      colour = level.withValues(alpha: 0.35);
    } else if (value.abs() < 0.25) {
      // Level with par: a short grey bar across the line.
      bar = Rect.fromLTWH(left, mid - 3, barWidth, 6);
      colour = level;
    } else {
      final height =
          (value.abs() / HoleBars._reach).clamp(0.0, 1.0) * (mid - 2);
      final reach = height < 6 ? 6.0 : height;
      bar = value > 0
          ? Rect.fromLTWH(left, mid - reach, barWidth, reach)
          : Rect.fromLTWH(left, mid, barWidth, reach);
      colour = value > 0 ? better : worse;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(2)),
      Paint()..color = colour,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.delta != delta ||
      old.better != better ||
      old.worse != worse ||
      old.level != level ||
      old.line != line;
}
