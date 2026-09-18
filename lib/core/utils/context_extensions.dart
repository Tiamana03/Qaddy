/// See `docs/sprints/sprint-01-4-responsive-layout.md`'s
/// `context_extensions.dart` section: general `BuildContext` convenience
/// helpers that are **not related to responsive layout** — theme, colour,
/// typography and scaffold access. Responsive `BuildContext` extensions
/// belong exclusively in `lib/core/responsive/responsive_extensions.dart`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// General, non-responsive `BuildContext` convenience accessors.
extension ContextExtensions on BuildContext {
  /// Shortcut for `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Shortcut for the `QaddyColours` theme extension.
  QaddyColours get colours => Theme.of(this).extension<QaddyColours>()!;

  /// Shortcut for the `QaddyTypography` theme extension.
  QaddyTypography get typography =>
      Theme.of(this).extension<QaddyTypography>()!;

  /// Shortcut for `ScaffoldMessenger.of(this)`.
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
}
