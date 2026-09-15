/// Qaddy motion tokens — see `design/design-tokens/animations.md`.
///
/// The `loading` duration is sourced from the Loaders Library asset
/// (600-1000ms range, 800ms implementation default); every other value is
/// an Engineering Decision documented in that file. Motion does not change
/// between Light and Dark Mode, so there is a single shared instance:
/// [QaddyMotion.standard].
library;

import 'package:flutter/material.dart';

/// Qaddy's animation durations and easing curves, as a [ThemeExtension].
///
/// Named `QaddyMotion` (not `QaddyAnimations`) to match the class name used
/// throughout `design/design-tokens/animations.md`.
class QaddyMotion extends ThemeExtension<QaddyMotion> {
  const QaddyMotion({
    required this.instant,
    required this.fast,
    required this.normal,
    required this.slow,
    required this.pageTransition,
    required this.loading,
    required this.enter,
    required this.exit,
    required this.transition,
    required this.continuous,
  });

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — motion does not vary by theme.
  static const QaddyMotion standard = QaddyMotion(
    instant: Duration(milliseconds: 100),
    fast: Duration(milliseconds: 150),
    normal: Duration(milliseconds: 250),
    slow: Duration(milliseconds: 400),
    pageTransition: Duration(milliseconds: 300),
    loading: Duration(milliseconds: 800),
    enter: Curves.easeOut,
    exit: Curves.easeIn,
    transition: Curves.easeInOut,
    continuous: Curves.linear,
  );

  /// Button press feedback, small state toggles.
  final Duration instant;

  /// Icon/scale feedback, dialog entrance.
  final Duration fast;

  /// The default for most UI motion: fade in/out, slide up/down.
  final Duration normal;

  /// Large surface transitions (e.g. a bottom sheet's full expansion).
  final Duration slow;

  /// Screen-to-screen navigation.
  final Duration pageTransition;

  /// Loading indicators. Sourced from the Loaders Library's 600-1000ms
  /// guideline (800ms is the midpoint, used as the concrete default) — see
  /// animations.md's "Sourced from the Asset Library" section.
  final Duration loading;

  /// An element entering the screen: fade in, slide in, dialog opening.
  final Curve enter;

  /// An element leaving the screen: fade out, slide out, dialog closing.
  final Curve exit;

  /// Both start and end states are stable, on-screen states: page
  /// transitions, tab switches.
  final Curve transition;

  /// Motion that loops indefinitely: the loading spinner's rotation.
  final Curve continuous;

  @override
  QaddyMotion copyWith({
    Duration? instant,
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Duration? pageTransition,
    Duration? loading,
    Curve? enter,
    Curve? exit,
    Curve? transition,
    Curve? continuous,
  }) {
    return QaddyMotion(
      instant: instant ?? this.instant,
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
      pageTransition: pageTransition ?? this.pageTransition,
      loading: loading ?? this.loading,
      enter: enter ?? this.enter,
      exit: exit ?? this.exit,
      transition: transition ?? this.transition,
      continuous: continuous ?? this.continuous,
    );
  }

  @override
  QaddyMotion lerp(ThemeExtension<QaddyMotion>? other, double t) {
    if (other is! QaddyMotion) {
      return this;
    }
    // Curves aren't interpolatable, so — per Flutter's own ThemeExtension
    // guidance for non-continuous fields — snap to whichever side of the
    // transition `t` is closer to.
    return QaddyMotion(
      instant: _lerpDuration(instant, other.instant, t),
      fast: _lerpDuration(fast, other.fast, t),
      normal: _lerpDuration(normal, other.normal, t),
      slow: _lerpDuration(slow, other.slow, t),
      pageTransition: _lerpDuration(pageTransition, other.pageTransition, t),
      loading: _lerpDuration(loading, other.loading, t),
      enter: t < 0.5 ? enter : other.enter,
      exit: t < 0.5 ? exit : other.exit,
      transition: t < 0.5 ? transition : other.transition,
      continuous: t < 0.5 ? continuous : other.continuous,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      microseconds:
          (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
              .round(),
    );
  }
}
