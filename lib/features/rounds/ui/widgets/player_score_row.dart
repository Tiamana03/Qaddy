/// One golfer's score on the hole being played: a big number you can tap up or
/// down with a thumb, what it is called ("Birdie"), and the Stableford points
/// it earns. A birdie or better gets a little celebration.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

/// A player's row on the scorecard.
class PlayerScoreRow extends StatefulWidget {
  const PlayerScoreRow({
    required this.name,
    required this.isYou,
    required this.par,
    required this.shots,
    required this.gross,
    required this.points,
    required this.onNudge,
    this.onTapScore,
    this.onBigMoment,
    super.key,
  });

  /// The golfer's name.
  final String name;

  /// Whether this is the golfer keeping the score.
  final bool isYou;

  /// The hole's par.
  final int par;

  /// The shots this golfer is given on the hole.
  final int shots;

  /// The recorded score, or `null` while it is still the untouched default.
  final int? gross;

  /// The Stableford points the current score earns.
  final int points;

  /// Adds (`1`) or takes away (`-1`) a stroke.
  final ValueChanged<int> onNudge;

  /// Called when the score itself is tapped, to pick it in golf's words.
  final VoidCallback? onTapScore;

  /// Called when an eagle or better is recorded, for the bigger celebration.
  final VoidCallback? onBigMoment;

  @override
  State<PlayerScoreRow> createState() => _PlayerScoreRowState();
}

class _PlayerScoreRowState extends State<PlayerScoreRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// The score shown: what was recorded, or par until something is.
  int get _shown => widget.gross ?? widget.par;

  @override
  void didUpdateWidget(PlayerScoreRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final now = widget.gross;
    if (now != null &&
        now != oldWidget.gross &&
        isCelebration(now, widget.par)) {
      QaddyHaptics.success();
      final kind = scoreKind(now, widget.par);
      if (kind == ScoreKind.ace ||
          kind == ScoreKind.albatross ||
          kind == ScoreKind.eagle) {
        // After this frame: the parent cannot rebuild while its child builds.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onBigMoment?.call();
          }
        });
      }
      if (!MediaQuery.disableAnimationsOf(context)) {
        _burst.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  Color _scoreColour(QaddyColours colours) {
    return switch (scoreKind(_shown, widget.par)) {
      ScoreKind.ace || ScoreKind.albatross || ScoreKind.eagle => colours.gold,
      ScoreKind.birdie => colours.accentTeal,
      ScoreKind.par => colours.textPrimary,
      ScoreKind.bogey => colours.textSecondary,
      ScoreKind.double ||
      ScoreKind.worse ||
      ScoreKind.pickedUp => colours.accentOrange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final recorded = widget.gross != null;
    final label = scoreLabel(_shown, widget.par);
    final scoreColour = _scoreColour(colours);
    final shown = _shown == 0 ? '–' : '$_shown';

    final meta = <String>[
      '${widget.points} pt${widget.points == 1 ? '' : 's'}',
      if (widget.shots > 0)
        '+${widget.shots} shot${widget.shots == 1 ? '' : 's'}',
    ].join(' · ');

    Widget stepButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
    }) => SizedBox(
      width: 40,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          foregroundColor: colours.textPrimary,
          shape: const RoundedRectangleBorder(),
        ),
        icon: Icon(icon, size: 20),
      ),
    );

    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: colours.border,
    );

    // One row of the "Enter scores" panel: the face, who and how many points,
    // and the stepper (minus, the score in golf's words, plus).
    return AnimatedBuilder(
      animation: _burst,
      builder: (context, child) {
        final glow = 1 - QaddyMotion.standard.enter.transform(_burst.value);
        final pop = 1 + 0.18 * (glow * glow);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.medium),
            color: _burst.isAnimating
                ? colours.gold.withValues(alpha: 0.16 * glow)
                : Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 36,
                  height: 36,
                  child: FittedBox(child: QaddyAvatar(name: widget.name)),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.isYou ? 'You' : widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colours.surface1,
                    borderRadius: BorderRadius.circular(radius.medium),
                    border: Border.all(color: colours.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius.medium),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          stepButton(
                            icon: Icons.remove,
                            tooltip: 'Take a stroke off ${widget.name}',
                            onPressed: _shown > 0
                                ? () => widget.onNudge(-1)
                                : null,
                          ),
                          divider,
                          Semantics(
                            liveRegion: true,
                            label:
                                '${widget.isYou ? 'You' : widget.name}: '
                                '${_shown == 0 ? 'picked up' : '$_shown'}, '
                                '$label, ${widget.points} points',
                            excludeSemantics: true,
                            onTap: widget.onTapScore,
                            hint: 'Pick the score',
                            child: InkWell(
                              onTap: widget.onTapScore,
                              child: SizedBox(
                                width: 56,
                                child: Opacity(
                                  opacity: recorded ? 1 : 0.6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Transform.scale(
                                        scale: pop,
                                        child: Text(
                                          shown,
                                          style: typography.h3.copyWith(
                                            color: scoreColour,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                            fontFeatures: const <FontFeature>[
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: typography.caption.copyWith(
                                          color: scoreColour,
                                          fontSize: 10,
                                          height: 1.1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          divider,
                          stepButton(
                            icon: Icons.add,
                            tooltip: 'Add a stroke for ${widget.name}',
                            onPressed: _shown < maxStrokes
                                ? () => widget.onNudge(1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
