/// Qaddy's password field.
///
/// Not present in `design/ui-components/forms/forms-library-v1.png` — see
/// `docs/sprints/sprint-01-3-shared-components.md`'s "Engineering Decision —
/// Password Field": reuses `QaddyTextField`'s spacing, typography, border
/// radius, colours and validation styling exactly (via the same
/// [buildQaddyInputDecoration] helper), adding only obscure-text-by-default
/// and a trailing Material visibility-toggle icon. This is the one widget
/// in this sprint that must be stateful — it has to remember whether the
/// password is currently obscured or revealed.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/forms/qaddy_input_decoration.dart';

/// Qaddy's password field — a text field with obscured input and a
/// visibility toggle.
class QaddyPasswordField extends StatefulWidget {
  const QaddyPasswordField({
    this.controller,
    this.label = 'Password',
    this.errorText,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Field label.
  final String label;

  /// Error message. Non-null switches the field into its error state.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  @override
  State<QaddyPasswordField> createState() => _QaddyPasswordFieldState();
}

class _QaddyPasswordFieldState extends State<QaddyPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final iconColour = widget.enabled
        ? colours.textSecondary
        : colours.disabledForeground;

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      obscureText: _obscure,
      style: typography.body.copyWith(
        color: widget.enabled
            ? colours.textPrimary
            : colours.disabledForeground,
      ),
      decoration: buildQaddyInputDecoration(
        context: context,
        label: widget.label,
        errorText: widget.errorText,
        enabled: widget.enabled,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
            color: iconColour,
          ),
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
        ),
      ),
    );
  }
}
