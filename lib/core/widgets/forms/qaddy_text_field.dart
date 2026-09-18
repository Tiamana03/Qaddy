/// Qaddy's standard text field.
///
/// See `design/ui-components/forms/forms-library-v1.png`, panel 1 ("Text
/// Field") and `design/design-tokens/radius.md`'s Border Width Engineering
/// Decision.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_input_decoration.dart';

/// Qaddy's standard single-line text field.
class QaddyTextField extends StatelessWidget {
  const QaddyTextField({
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
    super.key,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Field label.
  final String? label;

  /// Placeholder text shown when empty.
  final String? hintText;

  /// Error message. Non-null switches the field into its error state.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: typography.body.copyWith(
        color: enabled ? colours.textPrimary : colours.disabledForeground,
      ),
      decoration: buildQaddyInputDecoration(
        context: context,
        label: label,
        hintText: hintText,
        errorText: errorText,
        enabled: enabled,
      ),
    );
  }
}
