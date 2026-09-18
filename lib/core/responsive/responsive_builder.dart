/// See `docs/architecture/responsive-layout.md`'s "ResponsiveBuilder"
/// section: chooses the appropriate widget for the current breakpoint,
/// delegating all breakpoint calculations to `QaddyBreakpoints`.
library;

import 'package:flutter/widgets.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';

/// Builds a different widget per breakpoint.
///
/// [tablet] falls back to [mobile] when omitted; [desktop] falls back to
/// [tablet] and then [mobile] — per responsive-layout.md's "Mobile First"
/// principle, additional screen space is additive, not required.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  /// Builder used on mobile, and as the fallback for tablet/desktop.
  final WidgetBuilder mobile;

  /// Builder used on tablet. Falls back to [mobile] when omitted.
  final WidgetBuilder? tablet;

  /// Builder used on desktop. Falls back to [tablet], then [mobile].
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    if (QaddyBreakpoints.isDesktop(context)) {
      return (desktop ?? tablet ?? mobile)(context);
    }
    if (QaddyBreakpoints.isTablet(context)) {
      return (tablet ?? mobile)(context);
    }
    return mobile(context);
  }
}
