/// The Dashboard's headline: how long until the next round, where, and who is
/// playing — with one tap to get ready and one to tell the group.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar_huddle.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// A full-width card for the upcoming round.
class NextRoundHero extends StatelessWidget {
  const NextRoundHero({
    required this.round,
    required this.countdown,
    required this.players,
    required this.onOpen,
    required this.onShare,
    this.inProgressHole,
    super.key,
  });

  /// The round to show.
  final UpcomingRound round;

  /// The countdown to it, or `null` when its day isn't a weekday name.
  final RoundCountdown? countdown;

  /// Names to show faces for, the golfer first.
  final List<String> players;

  /// Opens the round.
  final VoidCallback onOpen;

  /// Tells the group about the round.
  final VoidCallback onShare;

  /// The hole being played (1-based) when a round is under way; the card then
  /// says so and offers to continue instead of to get ready.
  final int? inProgressHole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final count = inProgressHole == null && round.planned ? countdown : null;
    final live = inProgressHole;
    final figure = int.tryParse(count?.value ?? '');

    // A clear morning: sky into the deep green of the course.
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.lerp(colours.accentSky, colours.backgroundBase, 0.52)!,
        Color.lerp(colours.accentTeal, colours.backgroundBase, 0.72)!,
      ],
    );

    final planned = round.planned;
    final headline = !planned && live == null
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Ready when you are',
              style: typography.display.copyWith(color: onGradient),
            ),
          )
        : count == null
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              live == null
                  ? '${round.date}, ${round.teeTime}'
                  : 'Hole $live of ${round.holes}',
              style: typography.display.copyWith(color: onGradient),
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // The figure counts up from nothing, so the card greets the
              // golfer with a little movement. A word ("Today") shrinks to
              // fit rather than crowding out its caption.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: spacing.hero * 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: animate && figure != null ? 0 : 1,
                      end: 1,
                    ),
                    duration: QaddyMotion.standard.loading,
                    curve: QaddyMotion.standard.enter,
                    builder: (context, t, _) => Text(
                      figure == null ? count.value : '${countedUp(figure, t)}',
                      style: typography.display.copyWith(
                        color: onGradient,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: Text(
                    count.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.h3.copyWith(color: onGradient),
                  ),
                ),
              ),
            ],
          );

    final spokenEyebrow = live == null
        ? (count?.eyebrow ?? 'Next round')
        : 'Round in progress, hole $live';

    return QaddyHeroCard(
      gradient: gradient,
      onTap: onOpen,
      semanticLabel:
          '$spokenEyebrow. '
          '${count == null ? '' : '${count.value} ${count.label}. '}'
          '${round.planned ? 'Sample round. ${round.date} at '
                    '${round.teeTime}, ' : ''}'
          '${round.course}. ${round.format}. '
          '${round.planned ? '${round.players} playing.' : ''}',
      footer: Row(
        children: <Widget>[
          Expanded(
            child: QaddyGoldButton(
              label: live == null
                  ? (planned ? 'Get ready' : 'Start a round')
                  : 'Continue round',
              icon: live == null
                  ? Icons.flag_rounded
                  : Icons.play_arrow_rounded,
              onPressed: onOpen,
            ),
          ),
          if (planned) SizedBox(width: spacing.sm),
          if (planned)
            IconButton.filled(
              tooltip: 'Tell the group',
              onPressed: onShare,
              style: IconButton.styleFrom(
                backgroundColor: onGradient.withValues(alpha: 0.16),
                foregroundColor: onGradient,
                minimumSize: Size(spacing.display, spacing.display),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius.medium),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyEyebrow(
            live != null
                ? 'ROUND IN PROGRESS'
                : !planned
                ? 'YOUR NEXT ROUND'
                : 'SAMPLE ROUND · ${count?.eyebrow ?? 'NEXT ROUND'}',
            maxLines: 1,
          ),
          SizedBox(height: spacing.sm),
          headline,
          SizedBox(height: spacing.xs),
          Text(
            round.course,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.body.copyWith(color: muted),
          ),
          if (planned)
            Text(
              '${round.date}, ${round.teeTime}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.copyWith(color: muted),
            ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              if (planned)
                QaddyInfoChip(
                  icon: Icons.wb_sunny_outlined,
                  text: round.weather,
                ),
              QaddyInfoChip(
                icon: Icons.emoji_events_outlined,
                text: round.format,
              ),
              QaddyInfoChip(
                icon: Icons.golf_course,
                text: '${round.holes} holes',
              ),
            ],
          ),
          if (planned) ...<Widget>[
            SizedBox(height: spacing.lg),
            QaddyAvatarHuddle(
              names: players,
              total: round.players,
              textColour: muted,
            ),
          ],
        ],
      ),
    );
  }
}
