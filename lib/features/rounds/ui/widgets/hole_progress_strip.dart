/// The round at a glance, as the mockup draws it: a strip of numbered circles,
/// the current hole ringed in gold, the ones played tinted green, the rest
/// plain. Tap one to jump there.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/features/rounds/models/round.dart';

/// A horizontal strip of holes that keeps the current one in view.
class HoleProgressStrip extends StatefulWidget {
  const HoleProgressStrip({
    required this.round,
    required this.onSelect,
    super.key,
  });

  /// The round being played.
  final Round round;

  /// Called with the index of the hole that was tapped.
  final ValueChanged<int> onSelect;

  @override
  State<HoleProgressStrip> createState() => _HoleProgressStripState();
}

class _HoleProgressStripState extends State<HoleProgressStrip> {
  static const double _size = 36;
  static const double _gap = 5;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centre(animate: false),
    );
  }

  @override
  void didUpdateWidget(HoleProgressStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round.currentHole != widget.round.currentHole) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centre());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Scrolls so the current hole sits in the middle of the strip.
  void _centre({bool animate = true}) {
    if (!mounted || !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    final target =
        widget.round.currentHole * (_size + _gap) -
        (position.viewportDimension - _size) / 2;
    final offset = target.clamp(0.0, position.maxScrollExtent);
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.animateTo(
        offset,
        duration: QaddyMotion.standard.pageTransition,
        curve: QaddyMotion.standard.enter,
      );
    } else {
      _controller.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final round = widget.round;

    Widget chevron(IconData icon, String tooltip, int direction) => Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 16,
        onTap: () {
          QaddyHaptics.selection();
          final position = _controller.position;
          final target = (position.pixels + direction * 3 * (_size + _gap))
              .clamp(0.0, position.maxScrollExtent);
          _controller.animateTo(
            target,
            duration: QaddyMotion.standard.fast,
            curve: QaddyMotion.standard.enter,
          );
        },
        child: SizedBox(
          width: 16,
          height: _size,
          child: Icon(icon, size: 16, color: colours.textSecondary),
        ),
      ),
    );

    final strip = SizedBox(
      height: _size + spacing.xs,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: round.holes.length,
        separatorBuilder: (context, index) => const SizedBox(width: _gap),
        itemBuilder: (context, index) {
          final current = index == round.currentHole;
          final played = round.isHolePlayed(index);
          final status = current
              ? 'current hole'
              : played
              ? 'scored'
              : 'not played yet';

          // The current hole is ringed in gold on the page colour; a hole that
          // has been played is tinted green; the rest are plain.
          final background = current
              ? Colors.transparent
              : played
              ? colours.selected.withValues(alpha: 0.28)
              : colours.surface1;
          final borderColour = current
              ? colours.gold
              : played
              ? colours.selected.withValues(alpha: 0.6)
              : colours.border;
          final foreground = current || played
              ? colours.textPrimary
              : colours.textSecondary;

          return Semantics(
            button: true,
            selected: current,
            label: 'Hole ${round.holes[index].number}, $status',
            excludeSemantics: true,
            onTap: () => widget.onSelect(index),
            child: InkResponse(
              radius: _size / 2 + 4,
              onTap: () {
                QaddyHaptics.selection();
                widget.onSelect(index);
              },
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : QaddyMotion.standard.fast,
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColour,
                    width: current ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  '${round.holes[index].number}',
                  style: typography.small.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return Row(
      children: <Widget>[
        chevron(Icons.chevron_left, 'Earlier holes', -1),
        Expanded(child: strip),
        chevron(Icons.chevron_right, 'Later holes', 1),
      ],
    );
  }
}
