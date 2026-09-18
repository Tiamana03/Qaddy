/// Qaddy's search field.
///
/// See `design/ui-components/forms/forms-library-v1.png`, panel 2 ("Search
/// Bar") — leading search icon, optional trailing clear icon once text is
/// entered. Built on the same shared decoration as `QaddyTextField`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_input_decoration.dart';

/// Qaddy's search field — a text field with a leading search icon and a
/// reactive clear button.
class QaddySearchField extends StatelessWidget {
  const QaddySearchField({
    this.controller,
    this.hintText = 'Search…',
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Placeholder text shown when empty.
  final String hintText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final iconColour = enabled
        ? colours.textSecondary
        : colours.disabledForeground;
    final controller = this.controller;

    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      style: typography.body.copyWith(
        color: enabled ? colours.textPrimary : colours.disabledForeground,
      ),
      decoration: buildQaddyInputDecoration(
        context: context,
        hintText: hintText,
        enabled: enabled,
        prefixIcon: Icon(Icons.search, color: iconColour),
        suffixIcon: controller == null
            ? null
            : ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: Icon(Icons.close, color: iconColour),
                    onPressed: enabled ? controller.clear : null,
                  );
                },
              ),
      ),
    );
  }
}
