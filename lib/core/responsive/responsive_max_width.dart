/// See `docs/architecture/responsive-layout.md`'s "ResponsiveMaxWidth"
/// section and `design/design-tokens/breakpoints.md`'s Layout Rules table
/// (Maximum content width: none on mobile/tablet, 1440px on desktop,
/// centred).
library;

import 'package:flutter/widgets.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';

/// Constrains content to the maximum width defined by `breakpoints.md`,
/// centring it on desktop.
class ResponsiveMaxWidth extends StatelessWidget {
  const ResponsiveMaxWidth({required this.child, super.key});

  /// The constrained content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!QaddyBreakpoints.isDesktop(context)) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: QaddyBreakpoints.desktopMaxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
