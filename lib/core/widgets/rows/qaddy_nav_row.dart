/// Qaddy's navigation row — an icon, a title, an optional summary line and a
/// chevron, for lists of places to go (settings-style hubs, action lists).
///
/// Replaces the private `_ActionTile` copies several screens carried. The
/// whole row is the tap target, at least 56px tall.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A tappable row that leads somewhere.
class QaddyNavRow extends StatelessWidget {
  const QaddyNavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    super.key,
  });

  /// The icon in the leading tile.
  final IconData icon;

  /// What the row is.
  final String title;

  /// A one-line summary beneath the title.
  final String? subtitle;

  /// Replaces the default chevron (e.g. a count or a status).
  final Widget? trailing;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  /// Whether the row performs a destructive action (tints it with the error
  /// colour).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final tint = destructive ? colours.error : colours.accent;

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.medium),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.hero - spacing.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              children: <Widget>[
                Container(
                  width: spacing.xxxl,
                  height: spacing.xxxl,
                  decoration: BoxDecoration(
                    color: colours.surface2,
                    borderRadius: BorderRadius.circular(radius.medium),
                  ),
                  child: Icon(icon, color: tint),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: typography.body.copyWith(
                          color: destructive
                              ? colours.error
                              : colours.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                trailing ??
                    Icon(Icons.chevron_right, color: colours.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
