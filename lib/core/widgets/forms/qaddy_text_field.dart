/// Qaddy's standard text field.
///
/// See `design/ui-components/forms/forms-library-v1.png`, panel 1 ("Text
/// Field") and `design/design-tokens/radius.md`'s Border Width Engineering
/// Decision.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_input_decoration.dart';

/// Qaddy's standard text field — single-line by default, multi-line when
/// [maxLines] is raised.
class QaddyTextField extends StatelessWidget {
  const QaddyTextField({
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.autofocus = false,
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

  /// Called when the user submits (e.g. presses Enter on a single line).
  final ValueChanged<String>? onSubmitted;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// How the keyboard capitalises as the user types.
  final TextCapitalization textCapitalization;

  /// Restricts or reformats input.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum visible lines (1 for a single-line field; `null` for unlimited).
  final int? maxLines;

  /// Minimum visible lines for a multi-line field.
  final int? minLines;

  /// Whether the text can't be edited directly (e.g. a date picker field).
  final bool readOnly;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// An icon drawn before the text.
  final Widget? prefixIcon;

  /// An icon or button drawn after the text.
  final Widget? suffixIcon;

  /// Controls focus programmatically.
  final FocusNode? focusNode;

  /// Whether to take focus when first shown.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      style: typography.body.copyWith(
        color: enabled ? colours.textPrimary : colours.disabledForeground,
      ),
      decoration: buildQaddyInputDecoration(
        context: context,
        label: label,
        hintText: hintText,
        errorText: errorText,
        enabled: enabled,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
