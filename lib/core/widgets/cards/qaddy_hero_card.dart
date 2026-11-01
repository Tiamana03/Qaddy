/// Qaddy's hero card: the large, gradient headline card at the top of a
/// screen (Friends' next round and rivalry, the Dashboard's next round).
///
/// One shell, so every hero shares the same radius, shadow, press ripple,
/// padding and screen-reader behaviour. The caller supplies the gradient, the
/// story (the tappable part) and, optionally, a footer for the main action.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// A rounded, shadowed, gradient card with a tappable story and an optional
/// footer.
class QaddyHeroCard extends StatelessWidget {
  const QaddyHeroCard({
    required this.gradient,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.footer,
    super.key,
  });

  /// The card's background.
  final Gradient gradient;

  /// What a screen reader says for the story, which is one button.
  final String semanticLabel;

  /// Opens whatever the story is about.
  final VoidCallback onTap;

  /// The story: eyebrow, headline, details.
  final Widget child;

  /// The main action, below the story and outside its tap target.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final borderRadius = BorderRadius.circular(radius.extraLarge);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows.large,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: gradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  button: true,
                  onTap: onTap,
                  excludeSemantics: true,
                  label: semanticLabel,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.xl,
                        spacing.xl,
                        spacing.xl,
                        spacing.lg,
                      ),
                      child: child,
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.xl,
                      0,
                      spacing.xl,
                      spacing.xl,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
