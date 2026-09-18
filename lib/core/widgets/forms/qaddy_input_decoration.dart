/// Shared [InputDecoration] builder for every Qaddy input field.
///
/// Centralising this is what lets `QaddyPasswordField` truthfully reuse
/// "identical spacing, typography, border radius, colours and validation
/// styling" from `QaddyTextField`, per `sprint-01-3-shared-components.md`'s
/// Password Field Engineering Decision — both call this same function.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Builds the [InputDecoration] shared by every Qaddy input field.
InputDecoration buildQaddyInputDecoration({
  required BuildContext context,
  required bool enabled,
  String? label,
  String? hintText,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final theme = Theme.of(context);
  final colours = theme.extension<QaddyColours>()!;
  final radius = theme.extension<QaddyRadius>()!;
  final spacing = theme.extension<QaddySpacing>()!;
  final typography = theme.extension<QaddyTypography>()!;

  final borderRadius = BorderRadius.circular(radius.small);

  OutlineInputBorder border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    filled: true,
    fillColor: enabled ? colours.surface1 : colours.disabledBackground,
    contentPadding: EdgeInsets.symmetric(
      horizontal: spacing.cardPadding,
      vertical: spacing.md,
    ),
    labelText: label,
    hintText: hintText,
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelStyle: typography.small.copyWith(color: colours.textSecondary),
    hintStyle: typography.body.copyWith(color: colours.textTertiary),
    errorStyle: typography.caption.copyWith(color: colours.error),
    border: border(colours.border, radius.borderWidthDefault),
    enabledBorder: border(colours.border, radius.borderWidthDefault),
    focusedBorder: border(colours.primary, radius.borderWidthFocused),
    errorBorder: border(colours.error, radius.borderWidthDefault),
    focusedErrorBorder: border(colours.error, radius.borderWidthFocused),
    disabledBorder: border(colours.disabledBorder, radius.borderWidthDefault),
  );
}
