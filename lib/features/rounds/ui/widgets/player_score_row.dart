/// One golfer's score on the hole being played, as a row of the "Enter scores"
/// panel in the approved Live Scoring mockup: the face, the name, a boxed
/// stepper (minus, the score, plus) and the golfer's running score against par
/// at the right. The score's colour says how it went (gold for an eagle or
/// better, teal for a birdie); a birdie or better gets a little celebration.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

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
    this.toPar = 0,
    this.leads = false,
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

  /// The golfer's running score against par over the holes played.
  final int toPar;

  /// Whether the golfer is leading, for the crown beside the name.
  final bool leads;

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
      ScoreKind.par || ScoreKind.bogey => colours.textPrimary,
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

    final recorded = widget.gross != null;
    final label = scoreLabel(_shown, widget.par);
    final scoreColour = _scoreColour(colours);
    final shown = _shown == 0 ? '–' : '$_shown';
    final name = widget.isYou ? 'You' : widget.name;
    final scoreWord = _shown == 0 ? 'picked up' : '$_shown';
    final totalWord = widget.toPar == 0 ? 'level' : formatScore(widget.toPar);

    Widget stepButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
    }) => SizedBox(
      width: 34,
      height: 32,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          foregroundColor: colours.textPrimary,
          shape: const RoundedRectangleBorder(),
        ),
        icon: Icon(icon, size: 18),
      ),
    );

    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: colours.border,
    );

    final shotsChip = widget.shots > 0
        ? Semantics(
            label: '${widget.shots} shot${widget.shots == 1 ? '' : 's'} given',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colours.gold.withValues(alpha: 0.6)),
              ),
              child: Text(
                '+${widget.shots}',
                style: TextStyle(
                  color: colours.gold,
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        : null;

    return AnimatedBuilder(
      animation: _burst,
      builder: (context, child) {
        final glow = 1 - QaddyMotion.standard.enter.transform(_burst.value);
        final pop = 1 + 0.18 * (glow * glow);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _burst.isAnimating
                ? colours.gold.withValues(alpha: 0.16 * glow)
                : Colors.transparent,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.md,
                      spacing.xs,
                      spacing.sm,
                      spacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Positioned.fill(
                                child: FittedBox(
                                  child: QaddyAvatar(name: widget.name),
                                ),
                              ),
                              if (shotsChip != null)
                                Positioned(
                                  right: -6,
                                  bottom: -4,
                                  child: shotsChip,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing.md - 2),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: QaddyText.panelName.copyWith(
                                    color: colours.textPrimary,
                                  ),
                                ),
                              ),
                              if (widget.leads) ...<Widget>[
                                SizedBox(width: spacing.xs),
                                Icon(
                                  Icons.workspace_premium,
                                  size: 16,
                                  color: colours.gold,
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colours.surface1,
                            borderRadius: BorderRadius.circular(
                              radius.medium - 4,
                            ),
                            border: Border.all(color: colours.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              radius.medium - 5,
                            ),
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
                                        '$name: '
                                        '$scoreWord, $label, '
                                        '${widget.points} points',
                                    excludeSemantics: true,
                                    onTap: widget.onTapScore,
                                    hint: 'Pick the score',
                                    child: InkWell(
                                      onTap: widget.onTapScore,
                                      child: Container(
                                        width: 38,
                                        alignment: Alignment.center,
                                        color: colours.backgroundBase
                                            .withValues(alpha: 0.35),
                                        child: Opacity(
                                          opacity: recorded ? 1 : 0.75,
                                          child: Transform.scale(
                                            scale: pop,
                                            child: Text(
                                              shown,
                                              style: QaddyText.stepperFigure
                                                  .copyWith(
                                                    color: scoreColour,
                                                    fontFeatures: _tabular,
                                                  ),
                                            ),
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
                ),
                // The running score against par, set off by a hairline.
                Container(
                  width: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: colours.border)),
                  ),
                  child: Semantics(
                    label: '$totalWord for the round',
                    excludeSemantics: true,
                    child: Text(
                      formatScore(widget.toPar),
                      style: QaddyText.runningTotal.copyWith(
                        color: colours.textPrimary,
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
