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
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// The base page layout used by every screen in the app.
class QaddyScaffold extends StatelessWidget {
  const QaddyScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    super.key,
  });

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
      body: SafeArea(
        child: ResponsivePadding(child: ResponsiveMaxWidth(child: body)),
      ),
    );
  }
}
