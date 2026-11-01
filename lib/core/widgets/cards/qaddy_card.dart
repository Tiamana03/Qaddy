/// Qaddy's base card — the app's most common elevated surface.
///
/// See `design/ui-components/cards/cards-library-v1.png` and
/// `design/design-tokens/elevation.md` (Cards → `level1`, paired with
/// `shadows.medium`, which is what actually renders here — see
/// `shadows.md`'s own Flutter Implementation example).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// Qaddy's base card — a padded, rounded, shadowed elevated surface.
class QaddyCard extends StatelessWidget {
  const QaddyCard({required this.child, this.onTap, super.key});

  /// The card's content.
  final Widget child;

  /// Optional tap handler — omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final shadows = theme.extension<QaddyShadows>()!;

    final borderRadius = BorderRadius.circular(radius.large);
    final content = Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: borderRadius,
        boxShadow: shadows.medium,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return _PressScale(
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Settles the card a touch smaller while a finger is on it, so a tap feels
/// physical. Skipped when the user has asked to reduce motion.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _set({required bool pressed}) {
    if (_pressed != pressed) {
      setState(() => _pressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return Listener(
      onPointerDown: (_) => _set(pressed: true),
      onPointerUp: (_) => _set(pressed: false),
      onPointerCancel: (_) => _set(pressed: false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
