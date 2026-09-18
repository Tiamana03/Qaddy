/// See `docs/architecture/responsive-layout.md`'s "ResponsivePadding"
/// section and `design/design-tokens/breakpoints.md`'s Layout Rules table
/// (Side padding: `lg` on mobile, `xl` on tablet, `xxl` on desktop).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// Applies the correct horizontal padding for the current breakpoint.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({required this.child, super.key});

  /// The padded content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final double horizontal;
    if (QaddyBreakpoints.isDesktop(context)) {
      horizontal = spacing.xxl;
    } else if (QaddyBreakpoints.isTablet(context)) {
      horizontal = spacing.xl;
    } else {
      horizontal = spacing.lg;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: child,
    );
  }
}
