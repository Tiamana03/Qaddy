/// The distance ladder: every club from the longest to the shortest as a bar,
/// with the gap down to the next club marked and coloured, so a hole in the
/// bag is visible at a glance. Tap a club to tune it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/my_bag/logic/bag_insights.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// The accent a club family is drawn in.
Color clubColour(QaddyColours colours, ClubFamily family) {
  return switch (family) {
    ClubFamily.wood => colours.gold,
    ClubFamily.hybrid => colours.accentOrange,
    ClubFamily.iron => colours.accentTeal,
    ClubFamily.wedge => colours.accentSky,
    ClubFamily.putter => colours.accentIndigo,
    ClubFamily.ball => colours.accentPink,
  };
}

/// The accent a gap is drawn in.
Color gapColour(QaddyColours colours, GapKind kind) {
  return switch (kind) {
    GapKind.tight => colours.accentTeal,
    GapKind.watch => colours.accentOrange,
    GapKind.hole => colours.accentPink,
  };
}

/// Small confidence dots: filled up to the rating, five in all.
class ConfidenceDots extends StatelessWidget {
  const ConfidenceDots({required this.confidence, this.size = 6, super.key});

  /// 0 (not rated) to 5.
  final int confidence;

  /// Each dot's diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 1; i <= 5; i++)
          Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(right: size * 0.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= confidence ? colours.gold : colours.border,
            ),
          ),
      ],
    );
  }
}

/// The ladder card.
class DistanceLadder extends StatelessWidget {
  const DistanceLadder({
    required this.clubs,
    required this.goTo,
    required this.onTapClub,
    super.key,
  });

  /// The whole bag; only clubs with a carry are drawn.
  final List<BagClub> clubs;

  /// The club the golfer trusts most, marked with a star.
  final BagClub? goTo;

  /// Called with the club that was tapped.
  final ValueChanged<BagClub> onTapClub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final ordered = carryClubs(clubs);
    final gaps = <String, ClubGap>{
      for (final gap in gapsOf(clubs)) gap.shorter.id: gap,
    };
    final longest = ordered.isEmpty ? 1.0 : ordered.first.carryMetres!;

    Widget legend(GapKind kind, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: gapColour(colours, kind),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: spacing.xs),
        Text(
          label,
          style: typography.caption.copyWith(color: colours.textSecondary),
        ),
      ],
    );

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final club in ordered)
            _LadderRow(
              key: ValueKey<String>(club.id),
              club: club,
              longest: longest,
              gap: gaps[club.id],
              isGoTo: club.id == goTo?.id,
              onTap: () {
                QaddyHaptics.selection();
                onTapClub(club);
              },
            ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.xs,
            children: <Widget>[
              legend(GapKind.tight, 'Tight'),
              legend(GapKind.watch, 'Watch'),
              legend(GapKind.hole, 'A hole'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({
    required this.club,
    required this.longest,
    required this.gap,
    required this.isGoTo,
    required this.onTap,
    super.key,
  });

  final BagClub club;
  final double longest;
  final ClubGap? gap;
  final bool isGoTo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final carry = club.carryMetres!;
    final fraction = (carry / longest).clamp(0.0, 1.0);
    final colour = clubColour(colours, club.family);
    final gapText = gap == null ? null : '−${gap!.metres.round()}';

    final spoken =
        '${club.name}, ${club.model}, carries ${carry.round()} metres. '
        '${club.confidence == 0 ? '' : '${confidenceLabel(club.confidence)}. '}'
        '${gap == null ? '' : '${gap!.metres.round()} metres shorter than '
                  'your ${gap!.longer.name}. '}'
        '${club.hasNote ? 'Has a note. ' : ''}'
        'Tap to tune it.';

    return Semantics(
      button: true,
      label: spoken,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.medium),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              club.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: typography.body.copyWith(
                                color: colours.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isGoTo) ...<Widget>[
                            SizedBox(width: spacing.xs),
                            Icon(Icons.star, size: 14, color: colours.gold),
                          ],
                          if (club.hasNote) ...<Widget>[
                            SizedBox(width: spacing.xs),
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 13,
                              color: colours.textTertiary,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: spacing.xs),
                      ConfidenceDots(confidence: club.confidence),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius.large),
                    child: Stack(
                      children: <Widget>[
                        Container(height: 14, color: colours.surface2),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: animate ? 0 : fraction,
                            end: fraction,
                          ),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => FractionallySizedBox(
                            widthFactor: value.clamp(0.001, 1.0),
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    colour.withValues(alpha: 0.55),
                                    colour,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                SizedBox(
                  width: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        formatDistance(carry),
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      if (gapText != null)
                        Text(
                          gapText,
                          style: typography.caption.copyWith(
                            color: gapColour(colours, gap!.kind),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
