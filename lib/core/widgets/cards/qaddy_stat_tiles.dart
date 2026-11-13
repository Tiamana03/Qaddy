/// A row of small stat tiles, as the approved Home ("Your Game") and Profile
/// mockups draw them. Home's are left-aligned with the figure on top and the
/// icon at the foot; Profile's are centred with the icon on top. The first tile
/// is tinted green in both.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';

/// One tile's content.
class QaddyStat {
  const QaddyStat({
    required this.figure,
    required this.label,
    this.icon,
    this.iconColour,
  });

  /// The number (or "–" while it is not known).
  final String figure;

  /// What it is.
  final String label;

  /// The tile's icon.
  final IconData? icon;

  /// The icon's colour; gold when omitted.
  final Color? iconColour;
}

/// How a row of tiles is laid out.
enum QaddyStatLayout {
  /// Left-aligned: figure, label, then the icon at the foot (Home).
  game,

  /// Centred: icon, figure, label (Profile).
  profile,
}

/// Tiles for [stats], sharing the width equally.
class QaddyStatTiles extends StatelessWidget {
  const QaddyStatTiles({
    required this.stats,
    required this.onOpen,
    this.layout = QaddyStatLayout.game,
    this.tintFirst = true,
    this.semanticPrefix = 'Your game',
    super.key,
  });

  /// What to show.
  final List<QaddyStat> stats;

  /// Opens the place the numbers come from.
  final VoidCallback onOpen;

  /// Which of the mockups' two arrangements to use.
  final QaddyStatLayout layout;

  /// Tints the first tile green (Home does; Profile's four are alike).
  final bool tintFirst;

  /// What the whole row is called to a screen reader.
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          '$semanticPrefix. '
          '${stats.map((t) => '${t.label} ${t.figure}').join(', ')}. '
          'Opens your statistics.',
      child: SizedBox(
        height: layout == QaddyStatLayout.game ? 92 : 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (index, stat) in stats.indexed) ...<Widget>[
              if (index > 0) SizedBox(width: spacing.sm),
              Expanded(
                child: _Tile(
                  stat: stat,
                  layout: layout,
                  tinted: tintFirst && index == 0,
                  onTap: onOpen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.stat,
    required this.layout,
    required this.tinted,
    required this.onTap,
  });

  final QaddyStat stat;
  final QaddyStatLayout layout;
  final bool tinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final shape = BorderRadius.circular(radius.medium);
    final figureColour = tinted
        ? theme.colorScheme.onPrimary
        : colours.textPrimary;
    final labelColour = tinted
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
        : colours.textSecondary;
    final icon = stat.icon == null
        ? null
        : Icon(
            stat.icon,
            size: layout == QaddyStatLayout.game ? 22 : 20,
            color: stat.iconColour ?? colours.gold,
          );

    final figure = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: layout == QaddyStatLayout.game
          ? Alignment.centerLeft
          : Alignment.center,
      child: Text(
        stat.figure,
        style: QaddyText.tileFigure.copyWith(
          color: figureColour,
          fontSize: layout == QaddyStatLayout.profile ? 21 : null,
          height: layout == QaddyStatLayout.profile ? 26 / 21 : null,
        ),
      ),
    );
    final labelText = Text(
      stat.label,
      maxLines: layout == QaddyStatLayout.game ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: layout == QaddyStatLayout.game
          ? TextAlign.start
          : TextAlign.center,
      style: QaddyText.tileLabel.copyWith(color: labelColour),
    );
    // Profile's labels stay on one line, shrinking a touch, never wrapping.
    final label = layout == QaddyStatLayout.game
        ? labelText
        : FittedBox(fit: BoxFit.scaleDown, child: labelText);

    final content = layout == QaddyStatLayout.game
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              figure,
              label,
              if (icon != null) ...<Widget>[const Spacer(), icon],
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ?icon,
              if (icon != null) SizedBox(height: spacing.xs),
              figure,
              label,
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: tinted ? null : colours.card,
        gradient: tinted ? colours.tintedGradient : null,
        borderRadius: shape,
        border: Border.all(
          color: tinted
              ? colours.selected.withValues(alpha: 0.45)
              : colours.border,
        ),
        boxShadow: tinted
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm + 1,
              spacing.sm,
              spacing.sm,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
