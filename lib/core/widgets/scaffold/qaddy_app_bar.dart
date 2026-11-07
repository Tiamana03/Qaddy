/// Qaddy's top bar, as the approved mockups draw it: a back chevron, a
/// semibold title with a quiet line beneath it (the course, the group) and
/// whatever sits at the right (faces, a round menu button).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';

/// A top bar with a title and an optional [subtitle].
class QaddyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QaddyAppBar({
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    super.key,
  });

  /// The title.
  final String title;

  /// A quiet line under the title.
  final String? subtitle;

  /// Widgets at the right, in order.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return AppBar(
      toolbarHeight: 60,
      titleSpacing: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: QaddyText.screenTitle.copyWith(color: colours.textPrimary),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.screenSubtitle.copyWith(
                color: colours.textSecondary,
              ),
            ),
        ],
      ),
      actions: <Widget>[...actions, const SizedBox(width: 12)],
    );
  }
}
