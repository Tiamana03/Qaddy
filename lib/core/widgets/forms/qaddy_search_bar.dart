/// The search bar under a list screen's title, as the approved mockups draw
/// it: a rounded dark field with a magnifying glass, and a square filter
/// button beside it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';

/// A search field with an optional filter button.
class QaddySearchBar extends StatelessWidget {
  const QaddySearchBar({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onFilter,
    this.showFilter = true,
    super.key,
  });

  /// The placeholder text.
  final String hintText;

  /// Holds the text typed.
  final TextEditingController? controller;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Called when the filter button is tapped. When null the button is drawn
  /// dimmed and does nothing: its place is kept for when there are filters.
  final VoidCallback? onFilter;

  /// Whether the filter button is drawn at all.
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    final field = Container(
      height: 40,
      decoration: BoxDecoration(
        color: colours.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 14),
          Icon(Icons.search, size: 20, color: colours.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: QaddyText.listMeta.copyWith(
                color: colours.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hintText,
                hintStyle: QaddyText.listMeta.copyWith(
                  color: colours.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );

    if (!showFilter) {
      return field;
    }

    return Row(
      children: <Widget>[
        Expanded(child: field),
        const SizedBox(width: 10),
        Opacity(
          opacity: onFilter == null ? 0.5 : 1,
          child: Material(
            color: colours.surface1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colours.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onFilter,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: colours.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
