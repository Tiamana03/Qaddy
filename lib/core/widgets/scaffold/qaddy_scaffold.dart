/// Qaddy's shared application scaffold — see
/// `docs/sprints/sprint-01-5-foundation-integration.md`'s "Shared Scaffold"
/// section.
///
/// Composes `SafeArea`, `ResponsivePadding` and `ResponsiveMaxWidth` (all
/// Sprint 1.4) around the caller's content so that no feature screen needs
/// to perform its own responsive calculations. `appBar` and
/// `bottomNavigationBar` are optional pass-throughs to the underlying
/// `Scaffold` for screens that need them.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_max_width.dart';
import 'package:qaddy/core/responsive/responsive_padding.dart';
import 'package:qaddy/core/theme/qaddy_breakpoints.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// The base page layout used by every screen in the app.
class QaddyScaffold extends StatelessWidget {
  const QaddyScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.phoneSidePadding,
    super.key,
  });

  /// Overrides the side padding on a phone (a few mockups, Statistics among
  /// them, run their cards closer to the edge). Tablets and desktops keep the
  /// responsive padding.
  final double? phoneSidePadding;

  /// The page's main content.
  final Widget body;

  /// Optional app bar. Omit for a screen with no top chrome.
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar. Omit for a screen with none of its
  /// own — the persistent tab bar in `NavigationShell` is separate and does
  /// not use this parameter.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      // The page fades from a lift at the top to the base colour, as the
      // mockups' backgrounds do.
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[colours.backgroundGlow, colours.background],
            stops: const <double>[0, 0.55],
          ),
        ),
        child: SafeArea(
          child:
              phoneSidePadding != null &&
                  !QaddyBreakpoints.isTablet(context) &&
                  !QaddyBreakpoints.isDesktop(context)
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: phoneSidePadding!),
                  child: body,
                )
              : ResponsivePadding(child: ResponsiveMaxWidth(child: body)),
        ),
      ),
    );
  }
}
