/// Assembles Qaddy's `ThemeData` from the token files in this directory.
///
/// This file makes the architectural decisions the individual token files
/// don't: how [QaddyColours] maps onto Flutter's [ColorScheme] and
/// [TextTheme] for the built-in Material widgets that haven't yet migrated
/// to reading the token extensions directly. Component-level theming
/// (button shapes, card padding, etc.) is deliberately out of scope here —
/// Sprint 1.1 is the theme foundation only; that belongs with whichever
/// sprint builds the actual shared button/card/dialog widgets.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_elevation.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Qaddy's two [ThemeData] instances, replacing Flutter's default theme.
///
/// [dark] is Qaddy's primary theme; [light] is the optional/secondary
/// theme — see `design/design-tokens/colours.md`.
abstract final class QaddyTheme {
  /// Qaddy's primary theme.
  static final ThemeData dark = _build(QaddyColours.dark, Brightness.dark);

  /// Qaddy's optional/secondary theme.
  static final ThemeData light = _build(QaddyColours.light, Brightness.light);

  static ThemeData _build(QaddyColours colours, Brightness brightness) {
    final colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: colours.primary,
            // White text on a coloured button/badge surface, per the UI
            // Component Library — `textPrimary` is white in Dark Mode.
            onPrimary: colours.textPrimary,
            secondary: colours.secondary,
            onSecondary: colours.textPrimary,
            error: colours.error,
            onError: colours.textPrimary,
            surface: colours.surface1,
            onSurface: colours.textPrimary,
          )
        : ColorScheme.light(
            primary: colours.primary,
            // White text on a coloured button/badge surface — `surface1`
            // is white in Light Mode.
            onPrimary: colours.surface1,
            secondary: colours.secondary,
            onSecondary: colours.surface1,
            error: colours.error,
            onError: colours.surface1,
            surface: colours.surface1,
            onSurface: colours.textPrimary,
          );

    final textTheme = _textTheme(colours);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colours.background,
      dividerColor: colours.divider,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colours.textPrimary),
      extensions: <ThemeExtension<dynamic>>[
        colours,
        QaddyTypography.standard,
        QaddySpacing.standard,
        QaddyRadius.standard,
        QaddyShadows.standard,
        QaddyElevation.standard,
        QaddyMotion.standard,
      ],
    );
  }

  static TextTheme _textTheme(QaddyColours colours) {
    const type = QaddyTypography.standard;
    return TextTheme(
      displayLarge: type.display.copyWith(color: colours.textPrimary),
      headlineLarge: type.h1.copyWith(color: colours.textPrimary),
      headlineMedium: type.h2.copyWith(color: colours.textPrimary),
      headlineSmall: type.h3.copyWith(color: colours.textPrimary),
      titleLarge: type.h4.copyWith(color: colours.textPrimary),
      bodyLarge: type.bodyLarge.copyWith(color: colours.textPrimary),
      bodyMedium: type.body.copyWith(color: colours.textSecondary),
      bodySmall: type.small.copyWith(color: colours.textSecondary),
      labelLarge: type.button.copyWith(color: colours.textPrimary),
      labelSmall: type.caption.copyWith(color: colours.textTertiary),
    );
  }
}
