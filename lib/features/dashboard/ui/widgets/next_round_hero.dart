/// The Dashboard's headline: how long until the next round, where, and who is
/// playing — with one tap to get ready and one to tell the group.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
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

  /// How many faces are shown before "+N".
  static const int _faces = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);
    final borderRadius = BorderRadius.circular(radius.extraLarge);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final count = countdown;
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

    Widget chip(IconData icon, String text) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: onGradient.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colours.gold),
          SizedBox(width: spacing.xs),
          Text(text, style: typography.small.copyWith(color: onGradient)),
        ],
      ),
    );

    final shown = players.take(_faces).toList();
    final more = round.players - shown.length;
    const faceSize = 34.0;
    const faceStep = 24.0;

    final headline = count == null
        ? FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${round.date}, ${round.teeTime}',
              style: typography.display.copyWith(color: onGradient),
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // The figure counts up from nothing, so the card greets the
              // golfer with a little movement. A word ("Today") shrinks to
              // fit rather than crowding out its caption.
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: animate && figure != null ? 0 : 1,
                      end: 1,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => Text(
                      figure == null ? count.value : '${(figure * t).round()}',
                      style: typography.display.copyWith(
                        color: onGradient,
                        fontSize: 64,
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
                flex: 3,
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

    final story = Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          '${count?.eyebrow ?? 'Next round'}. '
          '${count == null ? '' : '${count.value} ${count.label}. '}'
          '${round.date} at ${round.teeTime}, ${round.course}. '
          '${round.weather}. ${round.format}. ${round.players} playing.',
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.xl,
            spacing.xl,
            spacing.xl,
            spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                count?.eyebrow ?? 'NEXT ROUND',
                style: typography.caption.copyWith(
                  color: colours.gold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: spacing.sm),
              headline,
              SizedBox(height: spacing.xs),
              Text(
                '${round.course} · ${round.date}, ${round.teeTime}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.body.copyWith(color: muted),
              ),
              SizedBox(height: spacing.lg),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: <Widget>[
                  chip(Icons.wb_sunny_outlined, round.weather),
                  chip(Icons.emoji_events_outlined, round.format),
                  chip(Icons.golf_course, '${round.holes} holes'),
                ],
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: faceSize + faceStep * (shown.length - 1),
                    height: faceSize,
                    child: Stack(
                      children: <Widget>[
                        for (final (index, name) in shown.indexed)
                          Positioned(
                            left: faceStep * index,
                            child: Container(
                              width: faceSize,
                              height: faceSize,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colours.backgroundBase,
                              ),
                              child: FittedBox(child: QaddyAvatar(name: name)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      more > 0
                          ? '+$more more · ${round.players} playing'
                          : '${round.players} playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows.large,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: gradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                story,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.xl,
                    0,
                    spacing.xl,
                    spacing.xl,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colours.gold,
                            foregroundColor: colours.backgroundBase,
                            minimumSize: Size.fromHeight(spacing.display),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                radius.medium,
                              ),
                            ),
                          ),
                          onPressed: onOpen,
                          icon: const Icon(Icons.flag_rounded, size: 18),
                          label: Text(
                            'Get ready',
                            overflow: TextOverflow.ellipsis,
                            style: typography.button,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing.sm),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
