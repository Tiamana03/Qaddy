/// A one-shot entrance animation: fades in while sliding up a few pixels.
///
/// Built only from the `QaddyMotion` tokens (`slow` duration, `enter`
/// curve), which until now no screen used. Skips the animation entirely
/// when the platform asks for reduced motion.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';

/// Fades and slides [child] into place the first time it is built.
class QaddyFadeSlideIn extends StatelessWidget {
  const QaddyFadeSlideIn({required this.child, this.offset = 12, super.key});

  /// The content to reveal.
  final Widget child;

  /// How far below its final position the child starts, in logical pixels.
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final motion = Theme.of(context).extension<QaddyMotion>()!;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: motion.slow,
      curve: motion.enter,
      child: child,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, (1 - progress) * offset),
          child: child,
        ),
      ),
    );
  }
}
