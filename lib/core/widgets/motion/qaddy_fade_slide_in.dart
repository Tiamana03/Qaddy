/// A one-shot entrance: the child fades in while sliding up a few pixels.
///
/// Give consecutive items increasing `delay`s (see `staggerDelay`) and a list
/// of cards arrives as a gentle cascade rather than appearing all at once.
/// Skipped entirely when the user has asked the system to reduce motion.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';

/// The delay for the [index]th item of a staggered group. Capped so a long
/// list never makes the last item wait noticeably.
Duration staggerDelay(int index, {int stepMs = 50, int maxSteps = 5}) =>
    Duration(milliseconds: stepMs * (index < maxSteps ? index : maxSteps));

/// Fades and slides [child] in once, when it first appears.
class QaddyFadeSlideIn extends StatelessWidget {
  const QaddyFadeSlideIn({
    required this.child,
    this.offset = 12,
    this.delay = Duration.zero,
    super.key,
  });

  /// The content to bring in.
  final Widget child;

  /// How far below its final position the child starts, in logical pixels.
  final double offset;

  /// How long to wait before the entrance begins.
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final motion = Theme.of(context).extension<QaddyMotion>()!;
    final total = delay + motion.normal;
    // The wait is the first part of one animation (rather than a timer), so
    // nothing is left pending if the widget is removed early.
    final waitFraction = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(waitFraction, 1, curve: motion.enter),
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

/// Wraps each of [children] in a [QaddyFadeSlideIn] with a growing delay, so a
/// column of cards arrives as a cascade. Plain spacers are left alone (and
/// don't use up a step).
List<Widget> staggered(List<Widget> children, {int startAt = 0}) {
  var step = startAt;
  return <Widget>[
    for (final child in children)
      if (child is SizedBox && child.child == null)
        child
      else
        QaddyFadeSlideIn(delay: staggerDelay(step++), child: child),
  ];
}
