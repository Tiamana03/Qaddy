/// The stage for Qaddy's launch screens: deep brand green with a soft gold
/// glow, in the dark theme whatever the phone's setting — so the first
/// moments of the app always look the same and always look like Qaddy.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';

/// A full-screen brand backdrop around [child]. When [onBack] is given a back
/// arrow sits in the top-left corner.
class LaunchScaffold extends StatelessWidget {
  const LaunchScaffold({required this.child, this.onBack, super.key});

  /// The screen's content, laid out inside the safe area.
  final Widget child;

  /// Called by the back arrow; omit for a screen with nowhere to go back to.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: QaddyTheme.dark,
      child: Builder(
        builder: (context) {
          final colours = Theme.of(context).extension<QaddyColours>()!;
          final top = colours.gradientGreen.colors.first;

          return Scaffold(
            backgroundColor: colours.backgroundBase,
            body: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[top, colours.backgroundBase],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.55),
                        radius: 0.85,
                        colors: <Color>[
                          colours.gold.withValues(alpha: 0.10),
                          colours.gold.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(child: child),
                if (onBack != null)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
