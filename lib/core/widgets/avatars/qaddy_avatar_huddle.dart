/// A huddle of overlapping faces with a count beside it ("+3 more · 8
/// playing"): who is in on something, at a glance.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';

/// Up to [limit] overlapping avatars, then how many more there are.
class QaddyAvatarHuddle extends StatelessWidget {
  const QaddyAvatarHuddle({
    required this.names,
    required this.total,
    required this.textColour,
    this.limit = 5,
    super.key,
  });

  /// Names to show faces for, in order.
  final List<String> names;

  /// How many are in altogether (may exceed [names]).
  final int total;

  /// The colour of the count beside the faces.
  final Color textColour;

  /// How many faces to show before "+N more".
  final int limit;

  static const double _size = 36;
  static const double _step = 26;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final shown = names.take(limit).toList();
    final more = total - shown.length;

    // Each face is ringed in the page colour so they read as a huddle rather
    // than a row of stickers.
    return Row(
      children: <Widget>[
        SizedBox(
          width: _size + _step * (shown.length - 1),
          height: _size,
          child: Stack(
            children: <Widget>[
              for (final (index, name) in shown.indexed)
                Positioned(
                  left: _step * index,
                  child: Container(
                    width: _size,
                    height: _size,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colours.backgroundBase,
                    ),
                    child: FittedBox(child: QaddyAvatar(name: name)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Text(
            more > 0 ? '+$more more · $total playing' : '$total playing',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(color: textColour),
          ),
        ),
      ],
    );
  }
}
