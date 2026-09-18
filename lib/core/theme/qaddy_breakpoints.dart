/// Qaddy responsive breakpoints — see `design/design-tokens/breakpoints.md`.
///
/// Not a `ThemeExtension` like the other `Qaddy*` classes in this
/// directory — breakpoints are plain width thresholds compared against
/// `MediaQuery`, not a themed value to look up (see breakpoints.md's own
/// "Flutter Implementation" section, which gives this exact class).
///
/// `desktopMaxContentWidth` extends the literal sample with one additional
/// constant: breakpoints.md's own "Layout Rules" table documents 1440px as
/// the Desktop maximum content width, but the sample class in that document
/// only covers the three width thresholds. Adding the already-documented
/// value here (rather than as a literal in `responsive_max_width.dart`) is
/// what keeps it from being duplicated or hardcoded.
library;

import 'package:flutter/widgets.dart';

/// Qaddy's three responsive breakpoints and the checks built on them.
class QaddyBreakpoints {
  const QaddyBreakpoints._();

  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1024;

  /// Desktop's maximum content width, per breakpoints.md's Layout Rules.
  static const double desktopMaxContentWidth = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet &&
      MediaQuery.sizeOf(context).width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
