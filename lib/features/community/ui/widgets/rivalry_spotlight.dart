/// The rivalry, as the headline of Friends: you, your biggest rival and the
/// score between you, with a one-tap challenge to send to your mate.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';

/// The head-to-head card. Tapping the story opens the full rivalry; the
/// challenge button sends the score to the rival.
class RivalrySpotlight extends StatelessWidget {
  const RivalrySpotlight({
    required this.summary,
    required this.yourName,
    required this.onChallenge,
    this.onOpen,
    super.key,
  });

  /// The record to show.
  final RivalrySummary summary;

  /// The golfer's own name.
  final String yourName;

  /// Opens the full Rivalries screen. Omit on that screen itself.
  final VoidCallback? onOpen;

  /// Shares a challenge with the rival.
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.78);
    final animate = !MediaQuery.disableAnimationsOf(context);

    // Two sides of one card: the golfer's gold-tinted green against the
    // rival's cool blue, meeting in the middle.
    final gradient = LinearGradient(
      colors: <Color>[
        Color.lerp(colours.gold, colours.backgroundBase, 0.72)!,
        Color.lerp(colours.accentSky, colours.backgroundBase, 0.72)!,
      ],
    );

    Widget side(String name, {required bool you}) => Expanded(
      flex: 3,
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: you ? colours.gold : colours.accentSky,
                width: 2.5,
              ),
            ),
            child: FittedBox(child: QaddyAvatar(name: name)),
          ),
          SizedBox(height: spacing.sm),
          Text(
            you ? 'You' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.body.copyWith(
              color: onGradient,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final score = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Text(
        '${(summary.youWins * t).round()} – ${(summary.theirWins * t).round()}',
        style: typography.display.copyWith(
          color: onGradient,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );

    final winBar = ClipRRect(
      borderRadius: BorderRadius.circular(radius.large),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: animate ? 0.5 : summary.youShare,
          end: summary.youShare,
        ),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, share, _) => SizedBox(
          height: 10,
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
    );

    // The story is read as one thing; the challenge button stays its own
    // control for screen readers.
    return QaddyHeroCard(
      gradient: gradient,
      onTap: onOpen,
      semanticLabel:
          'Rivalry: you versus ${summary.friendName}. '
          '${summary.youWins} wins to ${summary.theirWins}, '
          '${summary.draws} halved, ${summary.rounds} rounds. '
          '${summary.headline}. Last: ${summary.lastResult}.',
      footer: QaddyGoldButton(
        label: 'Send ${summary.friendName} a challenge',
        icon: Icons.send_rounded,
        onPressed: onChallenge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(child: QaddyEyebrow('RIVALRY')),
              Text(
                '${summary.rounds} rounds',
                style: typography.small.copyWith(color: muted),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              side(yourName, you: true),
              // The score shrinks to fit rather than overflowing a narrow
              // screen or a long score like 12 – 10.
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      children: <Widget>[
                        score,
                        if (summary.draws > 0)
                          Text(
                            '${summary.draws} halved',
                            style: typography.small.copyWith(color: muted),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              side(summary.friendName, you: false),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(
            summary.headline,
            style: typography.h3.copyWith(color: onGradient),
          ),
          SizedBox(height: spacing.sm),
          winBar,
          SizedBox(height: spacing.md),
          Text(
            'Last: ${summary.lastResult}',
            style: typography.small.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}
