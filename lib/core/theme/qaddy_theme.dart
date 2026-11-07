/// Assembles Qaddy's `ThemeData` from the token files in this directory.
///
/// This file makes the architectural decisions the individual token files
/// don't: how [QaddyColours] maps onto Flutter's [ColorScheme] and
/// [TextTheme] for the built-in Material widgets that haven't yet migrated
/// to reading the token extensions directly. Component-level theming
/// (button shapes, card padding, etc.) remains out of scope — Qaddy's own
/// shared widgets (`QaddyPrimaryButton`, `QaddyCard`, etc.) read the token
/// extensions directly rather than `ThemeData`. `appBarTheme` is the one
/// exception, added during Polish & Launch to resolve TD-003: every screen
/// builds a bare `AppBar()` with no Qaddy wrapper widget to theme instead,
/// so this is the only place that consistency could be enforced.
library;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
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
      fontFamily: QaddyTypography.fontFamily,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colours.background,
      dividerColor: colours.divider,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colours.textPrimary),
      // TD-003: every screen previously relied on Material 3's default
      // AppBar background (`colorScheme.surface`), which only happened to
      // look consistent with `colours.background` by coincidence — an
      // accidental, not enforced, consistency. Setting it here once removes
      // that risk for all 22 screens that build their own `AppBar`, and
      // matches Dashboard's own explicit override exactly (now redundant
      // there, see dashboard_screen.dart).
      appBarTheme: AppBarTheme(
        backgroundColor: colours.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colours.textPrimary,
        centerTitle: false,
        titleSpacing: QaddySpacing.standard.xs,
        titleTextStyle: QaddyTypography.standard.h4.copyWith(
          color: colours.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colours.textPrimary),
      ),
      // Calm press feedback: a soft, short ripple instead of Material's bold
      // one, so a tap reads as a touch rather than an animation.
      splashFactory: InkRipple.splashFactory,
      splashColor: colours.textPrimary.withValues(alpha: 0.06),
      highlightColor: colours.textPrimary.withValues(alpha: 0.04),
      hoverColor: colours.textPrimary.withValues(alpha: 0.04),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colours.accent,
        selectionColor: colours.accent.withValues(alpha: 0.28),
        selectionHandleColor: colours.accent,
      ),
      dividerTheme: DividerThemeData(
        color: colours.divider,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colours.accent,
        linearTrackColor: colours.surface2,
        circularTrackColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colours.surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        textStyle: QaddyTypography.standard.body.copyWith(
          color: colours.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QaddyRadius.standard.medium),
          side: BorderSide(color: colours.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colours.surface1,
        modalBackgroundColor: colours.surface1,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: colours.divider,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(QaddyRadius.standard.extraLarge),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colours.surface2,
          borderRadius: BorderRadius.circular(QaddyRadius.standard.small),
          border: Border.all(color: colours.border),
        ),
        textStyle: QaddyTypography.standard.small.copyWith(
          color: colours.textPrimary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colours.accent,
        inactiveTrackColor: colours.surface2,
        thumbColor: colours.accent,
        overlayColor: colours.accent.withValues(alpha: 0.12),
      ),
      // The Forms Library's Toggle Switch: the brand green track with a white
      // thumb when on, a quiet surface when off. (Material's default uses
      // `primary`, which is near-invisible on Dark Mode surfaces.)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colours.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colours.secondary
              : colours.surface2,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colours.secondary
              : colours.border,
        ),
      ),
      // Floating, themed snackbars: the default is a light bar that clashes
      // with the dark surfaces, and every screen shows them.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colours.surface2,
        contentTextStyle: QaddyTypography.standard.body.copyWith(
          color: colours.textPrimary,
        ),
        actionTextColor: colours.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QaddyRadius.standard.medium),
          side: BorderSide(color: colours.border),
        ),
      ),
      // A calm fade-and-drift transition everywhere except Apple platforms,
      // which keep the native slide because it carries the edge-swipe-back
      // gesture every iPhone golfer expects.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      // Like the switch, these Material controls default to `primary`, which
      // is dark green in Dark Mode: picker buttons, checkboxes and the
      // selected day would be near-invisible without the readable accent.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colours.accent),
      ),
      // The Forms Library's Checkbox: brand green fill, white check.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colours.secondary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
        side: BorderSide(color: colours.textTertiary, width: 2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colours.surface1,
        surfaceTintColor: Colors.transparent,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colours.surface1,
        surfaceTintColor: Colors.transparent,
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colours.accent : null,
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colours.background : null,
        ),
        todayForegroundColor: WidgetStatePropertyAll<Color>(colours.accent),
        todayBorder: BorderSide(color: colours.accent),
      ),
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
      titleMedium: type.bodyLarge.copyWith(
        color: colours.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: type.body.copyWith(
        color: colours.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: type.button.copyWith(color: colours.textPrimary),
      labelMedium: type.small.copyWith(color: colours.textSecondary),
      labelSmall: type.caption.copyWith(color: colours.textTertiary),
    );
  }
}
