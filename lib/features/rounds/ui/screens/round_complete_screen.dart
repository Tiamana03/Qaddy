/// The celebration: the round is over, someone has won, and everyone gets to
/// see how it went.
///
/// A burst of confetti, the winner, the golfer's own round in a few numbers,
/// the final table and one button to tell the group. See
/// `docs/features/rounds-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/achievements/models/achievement.dart';
import 'package:qaddy/features/achievements/ui/widgets/achievement_shelf.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/standing_row.dart';

/// The Round Complete screen (route `/rounds/complete`).
class RoundCompleteScreen extends ConsumerWidget {
  const RoundCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final round = ref.watch(completedRoundProvider);
    if (round == null) {
      return QaddyScaffold(
        appBar: AppBar(title: const Text('Results')),
        body: Center(
          child: QaddyEmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'No finished round yet',
            message: 'Finish a round and the results land here.',
            actionLabel: 'Go to Rounds',
            onAction: () => context.go(AppRoutes.rounds),
          ),
        ),
      );
    }
    return _Results(round: round);
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.round});

  final Round round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);

    final standings = standingsOf(round);
    final leaders = leadersOf(standings);
    final top = standings.first;
    final recap = recapOf(round, currentUserName);
    final chase = chaseLine(standings, currentUserName);
    final played = round.holesPlayed;
    final unlocked = newlyUnlocked(
      ref.watch(roundHistoryProvider),
      round,
      you: currentUserName,
    );

    // Last place gets a good-natured label, but only when there is a proper
    // field and the last player is genuinely behind the one above.
    final woodenSpoon =
        standings.length >= 3 &&
            played > 0 &&
            standings.last.position != standings[standings.length - 2].position
        ? standings.last.player.name
        : null;

    final hero = QaddyHeroCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.lerp(colours.gold, colours.backgroundBase, 0.62)!,
          Color.lerp(colours.accentTeal, colours.backgroundBase, 0.72)!,
        ],
      ),
      footer: QaddyGoldButton(
        label: 'Share the result',
        icon: Icons.ios_share_rounded,
        tall: true,
        onPressed: () => shareOrCopy(
          context,
          ref,
          text: roundResultMessage(round, you: currentUserName),
          subject: '${round.course} — the result',
        ),
      ),
      child: Column(
        children: <Widget>[
          QaddyEyebrow(
            'ROUND COMPLETE · ${round.course.toUpperCase()}',
            maxLines: 1,
          ),
          SizedBox(height: spacing.lg),
          Icon(Icons.emoji_events, color: colours.gold, size: 56),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (final leader in leaders.take(3))
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                  child: Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colours.gold, width: 2.5),
                    ),
                    child: FittedBox(
                      child: QaddyAvatar(name: leader.player.name),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            winnersHeadline(standings, you: currentUserName),
            textAlign: TextAlign.center,
            style: typography.h1.copyWith(color: onGradient),
          ),
          SizedBox(height: spacing.xs),
          Text(
            '${top.points} points · ${formatScore(top.toPar)} · '
            '$played ${played == 1 ? 'hole' : 'holes'}',
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: muted),
          ),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        QaddyScaffold(
          appBar: AppBar(
            title: const Text('Results'),
            leading: IconButton(
              tooltip: 'Done',
              icon: const Icon(Icons.close),
              onPressed: () => context.go(AppRoutes.home),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: staggered(<Widget>[
                SizedBox(height: spacing.md),
                hero,
                if (unlocked.isNotEmpty) ...<Widget>[
                  SizedBox(height: spacing.sectionGap),
                  _Unlocked(achievements: unlocked),
                ],
                if (recap != null) ...<Widget>[
                  SizedBox(height: spacing.sectionGap),
                  _YourRound(
                    recap: recap,
                    chase: chase,
                    total: standings.length,
                  ),
                ],
                SizedBox(height: spacing.sectionGap),
                const QaddySectionHeading(title: 'Final standings'),
                SizedBox(height: spacing.md),
                for (final (index, standing) in standings.indexed) ...<Widget>[
                  if (index > 0) SizedBox(height: spacing.cardGap),
                  StandingRow(
                    standing: standing,
                    isYou: standing.player.name == currentUserName,
                    leaderPoints: top.points,
                    holesPlayed: played,
                    tag: woodenSpoon == standing.player.name
                        ? 'Wooden spoon'
                        : null,
                  ),
                ],
                SizedBox(height: spacing.sectionGap),
                QaddySecondaryButton(
                  label: 'Back to Home',
                  onPressed: () {
                    QaddyHaptics.light();
                    context.go(AppRoutes.home);
                  },
                ),
                SizedBox(height: spacing.xl),
              ]),
            ),
          ),
        ),
        const Positioned.fill(child: QaddyConfetti()),
      ],
    );
  }
}

/// "Achievement unlocked": the badges this round earned, lit in gold.
class _Unlocked extends StatelessWidget {
  const _Unlocked({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      container: true,
      label:
          'Achievement unlocked: '
          '${achievements.map((a) => a.title).join(', ')}.',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.all(spacing.cardPadding),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(
              theme.extension<QaddyRadius>()!.large,
            ),
            border: Border.all(color: colours.gold, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              QaddyEyebrow(
                achievements.length == 1
                    ? 'ACHIEVEMENT UNLOCKED'
                    : 'ACHIEVEMENTS UNLOCKED',
              ),
              SizedBox(height: spacing.md),
              for (final (index, achievement)
                  in achievements.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.md),
                Row(
                  children: <Widget>[
                    AchievementBadge(achievement: achievement),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            achievement.title,
                            style: typography.h3.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                          Text(
                            achievement.blurb,
                            style: typography.small.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The golfer's own round: their place, points and the numbers behind it.
class _YourRound extends StatelessWidget {
  const _YourRound({
    required this.recap,
    required this.chase,
    required this.total,
  });

  final RoundRecap recap;
  final String? chase;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final standing = recap.standing;

    Widget stat(String value, String label) => Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing.md,
          horizontal: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: colours.surface2,
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Column(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: typography.h2.copyWith(color: colours.textPrimary),
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: typography.caption.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
    );

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const QaddyEyebrow('YOUR ROUND'),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
                  end: 1,
                ),
                duration: const Duration(milliseconds: 1200),
                curve: QaddyMotion.standard.enter,
                builder: (context, t, _) => Text(
                  '${(standing.points * t).round()}',
                  style: typography.display.copyWith(
                    color: colours.textPrimary,
                    fontSize: 56,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'points · ${standing.position} of $total',
                        style: typography.body.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                      if (chase != null)
                        Text(
                          chase!,
                          style: typography.small.copyWith(
                            color: colours.accent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Row(
            children: <Widget>[
              stat('${standing.birdies}', 'Birdies or better'),
              SizedBox(width: spacing.cardGap),
              stat('${recap.pars}', 'Pars'),
              SizedBox(width: spacing.cardGap),
              stat('${recap.bogeysOrWorse}', 'Bogeys or worse'),
            ],
          ),
          SizedBox(height: spacing.cardGap),
          Row(
            children: <Widget>[
              stat('${recap.frontNine}', 'Front nine pts'),
              SizedBox(width: spacing.cardGap),
              stat('${recap.backNine}', 'Back nine pts'),
              SizedBox(width: spacing.cardGap),
              stat(
                recap.bestHole == null ? '–' : '${recap.bestHole}',
                recap.bestHoleLabel == null
                    ? 'Best hole'
                    : 'Best hole · ${recap.bestHoleLabel}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
