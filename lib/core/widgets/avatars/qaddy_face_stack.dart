/// A stack of overlapping faces with a "+N" circle: who else is in, small. The
/// round card and the scorecard's top bar both draw it, at their own size.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';

/// Up to [limit] faces from [names], then a "+N" circle for the rest of
/// [total].
class QaddyFaceStack extends StatelessWidget {
  const QaddyFaceStack({
    required this.names,
    required this.total,
    this.size = 26,
    this.step = 17,
    this.limit = 3,
    this.ringColour,
    super.key,
  });

  /// Names to show faces for, in order.
  final List<String> names;

  /// How many are in altogether (may exceed [names]).
  final int total;

  /// The diameter of each face.
  final double size;

  /// How far each face sits from the last (less than [size] overlaps them).
  final double step;

  /// How many faces to show before the "+N" circle.
  final int limit;

  /// The ring around each face; the card colour when omitted.
  final Color? ringColour;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final ring = ringColour ?? colours.card;
    final shown = names.take(limit).toList();
    final more = total - shown.length;
    final slots = shown.length + (more > 0 ? 1 : 0);

    Widget face(Widget child, int index) => Positioned(
      left: step * index,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
        child: child,
      ),
    );

    return Semantics(
      label: '$total playing',
      excludeSemantics: true,
      child: SizedBox(
        width: size + step * (slots - 1),
        height: size,
        child: Stack(
          children: <Widget>[
            for (final (index, name) in shown.indexed)
              face(FittedBox(child: QaddyAvatar(name: name)), index),
            if (more > 0)
              face(
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colours.surface2,
                  ),
                  child: Text(
                    '+$more',
                    style: TextStyle(
                      color: colours.textPrimary,
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
                shown.length,
              ),
          ],
        ),
      ),
    );
  }
}
