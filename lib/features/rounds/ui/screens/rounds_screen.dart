/// Qaddy's Rounds destination — the round, from the first-tee nerves to the
/// final putt.
///
/// Before the round it is an invitation: when, where, who is playing and one
/// gold button to start. During the round it is the way back to the
/// scorecard. After the round it keeps the result, one tap from the
/// celebration. See `docs/features/rounds-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar_huddle.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/setup_player_tile.dart';
import 'package:qaddy/features/rounds/ui/widgets/standings_preview.dart';

/// The Rounds destination (route `/rounds`).
class RoundsScreen extends ConsumerWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final live = ref.watch(liveRoundProvider);
    final completed = ref.watch(completedRoundProvider);
    final picked = ref.watch(roundSetupProvider);

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Rounds',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            Text(
              live == null
                  ? (upcomingRound.planned
                        ? 'Sample round · ${upcomingRound.date} at '
                              '${upcomingRound.course}'
                        : upcomingRound.course)
                  : 'Round in progress',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.xl),
            if (live != null) _LiveHero(round: live) else const _SetupHero(),
            if (live != null && live.holesPlayed > 0) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              StandingsPreview(
                round: live,
                onOpen: () => context.push(AppRoutes.roundLeaderboard),
              ),
            ],
            if (live == null && completed != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              _LastRound(round: completed),
            ],
            if (live == null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(title: "Who's playing", badge: picked.length),
              SizedBox(height: spacing.md),
              const _Players(),
            ],
            if (upcomingRoundSideGames.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'On the course (sample)'),
              SizedBox(height: spacing.md),
              const _SideGames(),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// Before the round: the invitation and the one button that starts it.
class _SetupHero extends ConsumerWidget {
  const _SetupHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);
    final players = ref.watch(selectedPlayersProvider);

    return QaddyHeroCard(
      gradient: colours.gradientGreen,
      footer: QaddyGoldButton(
        label: 'Start round',
        icon: Icons.sports_golf,
        tall: true,
        onPressed: () {
          QaddyHaptics.success();
          ref.read(roundsProvider.notifier).startRound(players);
          context.push(AppRoutes.roundScorecard);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyEyebrow(
            upcomingRound.planned ? 'SAMPLE ROUND · FIRST TEE' : 'YOUR ROUND',
          ),
          SizedBox(height: spacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              upcomingRound.planned
                  ? '${upcomingRound.date}, ${upcomingRound.teeTime}'
                  : 'Ready when you are',
              style: typography.display.copyWith(color: onGradient),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            upcomingRound.course,
            style: typography.body.copyWith(color: muted),
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              if (upcomingRound.planned)
                QaddyInfoChip(
                  icon: Icons.wb_sunny_outlined,
                  text: upcomingRound.weather,
                ),
              QaddyInfoChip(
                icon: Icons.emoji_events_outlined,
                text: upcomingRound.format,
              ),
              QaddyInfoChip(
                icon: Icons.golf_course,
                text: '${upcomingRound.holes} holes',
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          QaddyAvatarHuddle(
            names: <String>[for (final p in players) p.name],
            total: players.length,
            textColour: muted,
          ),
          SizedBox(height: spacing.md),
          Text(
            upcomingRound.planned
                ? 'Hole pars and distances use a sample 18-hole layout until '
                      'course search arrives.'
                : 'Pars and stroke indexes use a standard par-72 layout until '
                      'course search arrives. Distances are left out rather '
                      'than guessed.',
            style: typography.small.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// During the round: where you are, and the way back to the scorecard.
class _LiveHero extends ConsumerWidget {
  const _LiveHero({required this.round});

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
    final you = standings.where((s) => s.player.name == currentUserName);
    final line = round.holesPlayed == 0 || you.isEmpty
        ? "Let's go — the first tee is yours."
        : 'You: ${you.first.position} · ${you.first.points} pts';

    return QaddyHeroCard(
      gradient: colours.gradientGreen,
      onTap: () => context.push(AppRoutes.roundScorecard),
      semanticLabel:
          'Round in progress at ${round.course}. '
          'Hole ${round.currentHole + 1} of ${round.holes.length}. $line. '
          'Opens the scorecard.',
      footer: QaddyGoldButton(
        label: 'Continue round',
        icon: Icons.play_arrow_rounded,
        tall: true,
        onPressed: () => context.push(AppRoutes.roundScorecard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const QaddyEyebrow('ROUND IN PROGRESS'),
          SizedBox(height: spacing.sm),
          Text(
            'Hole ${round.currentHole + 1} of ${round.holes.length}',
            style: typography.display.copyWith(color: onGradient),
          ),
          SizedBox(height: spacing.xs),
          Text(round.course, style: typography.body.copyWith(color: muted)),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              QaddyInfoChip(
                icon: Icons.emoji_events_outlined,
                text: round.format,
              ),
              QaddyInfoChip(
                icon: Icons.groups_outlined,
                text: '${round.players.length} playing',
              ),
              QaddyInfoChip(icon: Icons.leaderboard_outlined, text: line),
            ],
          ),
        ],
      ),
    );
  }
}

/// The last finished round, one tap from the celebration.
class _LastRound extends StatelessWidget {
  const _LastRound({required this.round});

  final Round round;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final standings = standingsOf(round);
    final headline = winnersHeadline(standings, you: currentUserName);
    final top = standings.first;

    return Semantics(
      button: true,
      onTap: () => context.push(AppRoutes.roundComplete),
      excludeSemantics: true,
      label:
          'Last round at ${round.course}. $headline with ${top.points} '
          'points. Opens the results.',
      child: QaddyCard(
        onTap: () => context.push(AppRoutes.roundComplete),
        child: Row(
          children: <Widget>[
            QaddyIconBadge(
              icon: Icons.emoji_events,
              colour: colours.gold,
              size: 48,
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const QaddyEyebrow('LAST ROUND'),
                  SizedBox(height: spacing.xs),
                  Text(
                    '$headline · ${top.points} pts',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'View the results',
                    style: typography.small.copyWith(color: colours.accent),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colours.accent),
          ],
        ),
      ),
    );
  }
}

/// Everyone invited, each with a switch.
class _Players extends ConsumerWidget {
  const _Players();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final picked = ref.watch(roundSetupProvider);

    return Column(
      children: <Widget>[
        for (final (index, invitee)
            in upcomingRoundInvitees.indexed) ...<Widget>[
          if (index > 0) SizedBox(height: spacing.cardGap),
          SetupPlayerTile(
            player: invitee.player,
            isYou: invitee.player.name == currentUserName,
            included: picked.contains(invitee.player.name),
            confirmed: invitee.confirmed,
            onToggle: () => ref
                .read(roundSetupProvider.notifier)
                .toggle(invitee.player.name),
          ),
        ],
      ],
    );
  }
}

/// The side games, each on its hole.
class _SideGames extends StatelessWidget {
  const _SideGames();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, game)
              in upcomingRoundSideGames.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                QaddyIconBadge(
                  icon: Icons.flag_outlined,
                  colour: colours.accentSky,
                  size: 36,
                  iconSize: 20,
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    game.name,
                    style: typography.body.copyWith(color: colours.textPrimary),
                  ),
                ),
                Text(
                  'Hole ${game.hole}',
                  style: typography.body.copyWith(
                    color: colours.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
