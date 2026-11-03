/// A group's crest and colour: its initial on a gold ring, in the colour the
/// group wears everywhere (the Friends clubs strip, the Groups list and the
/// group's own page).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';

/// The accent for the group at [index] in the golfer's list of groups. Chosen
/// by position so neighbours never share a colour.
Color groupAccent(QaddyColours colours, int index) {
  final palette = <Color>[
    colours.accentTeal,
    colours.accentIndigo,
    colours.accentOrange,
    colours.accentPink,
  ];
  return palette[index % palette.length];
}

/// The accent for [group], by its place in the golfer's groups.
Color accentForGroup(QaddyColours colours, Group group) {
  final index = groups.indexWhere((g) => g.id == group.id);
  return groupAccent(colours, index < 0 ? 0 : index);
}

/// The group's initial on a gold ring.
class GroupCrest extends StatelessWidget {
  const GroupCrest({required this.name, this.size = 44, super.key});

  /// The group's name; its first letter is the crest.
  final String name;

  /// The crest's diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colours.gold, width: size >= 60 ? 3 : 2),
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.10),
      ),
      child: Text(
        name.characters.first.toUpperCase(),
        style: typography.h3.copyWith(
          color: colours.gold,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
