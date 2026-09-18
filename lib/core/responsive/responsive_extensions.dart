/// See `docs/architecture/responsive-layout.md`'s "Responsive Extensions"
/// section: convenience extensions for accessing responsive information,
/// existing purely to make feature code cleaner. Every member delegates to
/// `QaddyBreakpoints` — nothing here calculates a breakpoint itself.
library;

import 'package:flutter/widgets.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';

/// Responsive `BuildContext` convenience accessors.
///
/// This is the single `BuildContext` extension for responsive information —
/// non-responsive `BuildContext` helpers belong in
/// `lib/core/utils/context_extensions.dart` instead.
extension ResponsiveContextExtensions on BuildContext {
  /// Whether the current width is in the mobile range.
  bool get isMobile => QaddyBreakpoints.isMobile(this);

  /// Whether the current width is in the tablet range.
  bool get isTablet => QaddyBreakpoints.isTablet(this);

  /// Whether the current width is in the desktop range.
  bool get isDesktop => QaddyBreakpoints.isDesktop(this);

  /// The current screen width, in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The current screen height, in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
