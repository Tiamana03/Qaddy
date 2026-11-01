/// Tiny physical feedback for the moments that deserve it.
///
/// Haptics make taps feel real — ticking a box, choosing a chip, sending a
/// message, finishing something. They are no-ops where the device has no
/// haptic engine (desktop, web) and never throw.
library;

import 'dart:async';

import 'package:flutter/services.dart';

/// Named haptic moments, so screens say what happened, not how it feels.
abstract final class QaddyHaptics {
  /// A choice was made: a chip, a tab, a checkbox.
  static void selection() => _run(HapticFeedback.selectionClick);

  /// A small action completed: a message sent, a value copied.
  static void light() => _run(HapticFeedback.lightImpact);

  /// Something worth celebrating: a trip created, a debt settled.
  static void success() => _run(HapticFeedback.mediumImpact);

  static void _run(Future<void> Function() feedback) {
    unawaited(feedback().catchError((Object _) {}));
  }
}
