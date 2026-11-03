/// The score between two golfers in one card: you, the tally, them, and who is
/// ahead: a quiet cousin of the Friends Home rivalry card, for a friend page.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';

/// A tappable head-to-head summary: "You 6 – 5 Tom", "You lead by 1" and the
/// split bar. Tapping it opens the whole rivalry.
class RivalryStrip extends StatelessWidget {
  const RivalryStrip({
    required this.summary,
    required this.yourName,
    required this.onOpen,
    super.key,
  });

  /// The record to show.
  final RivalrySummary summary;

  /// The golfer's own name.
  final String yourName;

  /// Opens the full Rivalries screen.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    Widget face(String name, Color ring) => Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: FittedBox(child: QaddyAvatar(name: name)),
    );

    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: onOpen,
      label:
          'Head to head with ${summary.friendName}: ${summary.youWins} wins '
          'to ${summary.theirWins}, ${summary.draws} halved. '
          '${summary.headline}. Opens the rivalry.',
      child: QaddyCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                face(yourName, colours.gold),
                Expanded(
                  child: Center(
                    child: Text(
                      '${summary.youWins} – ${summary.theirWins}',
                      style: typography.h1.copyWith(
                        color: colours.textPrimary,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ),
                face(summary.friendName, colours.accentSky),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    summary.headline,
                    style: typography.h3.copyWith(color: colours.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right, color: colours.textTertiary),
              ],
            ),
            SizedBox(height: spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.large),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: animate ? 0.5 : summary.youShare,
                  end: summary.youShare,
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, share, _) => SizedBox(
                  height: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: (share * 1000).round().clamp(1, 999),
                        child: ColoredBox(color: colours.gold),
                      ),
                      Expanded(
                        flex: ((1 - share) * 1000).round().clamp(1, 999),
                        child: ColoredBox(color: colours.accentSky),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              '${summary.rounds} rounds · ${summary.draws} halved',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
