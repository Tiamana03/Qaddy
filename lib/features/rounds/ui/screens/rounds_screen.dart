/// Qaddy's Rounds destination, as the approved "My Rounds" mockup draws it: a
/// title and a line, the Upcoming and Completed tabs, and rounds as cards.
///
/// Before the round the Upcoming tab is the next round and one gold button to
/// start it, with who is playing below. During the round it is the way back to
/// the scorecard. After the round the finished round moves to Completed, one
/// tap from the celebration. See `docs/features/rounds-release-candidate.md`.
///
/// The mockup's search, Invitations tab, Create Round and Get Directions have
/// nothing behind them yet (see `docs/reviews/mockup-checklist.md`), so they
/// are not drawn.
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
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_round_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_segmented_control.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/setup_player_tile.dart';
import 'package:qaddy/features/rounds/ui/widgets/standings_preview.dart';

enum _Tab { upcoming, completed }

/// The Rounds destination (route `/rounds`).
class RoundsScreen extends ConsumerStatefulWidget {
  const RoundsScreen({super.key});

  @override
  ConsumerState<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends ConsumerState<RoundsScreen> {
  _Tab _tab = _Tab.upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final live = ref.watch(liveRoundProvider);
    final history = ref.watch(roundHistoryProvider);

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'My rounds',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Play more. Keep track. Make it count.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.lg),
            QaddySegmentedControl<_Tab>(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
              segments: <QaddySegment<_Tab>>[
                const QaddySegment<_Tab>(
                  value: _Tab.upcoming,
                  label: 'Upcoming',
                ),
                QaddySegment<_Tab>(
                  value: _Tab.completed,
                  label: history.isEmpty
                      ? 'Completed'
                      : 'Completed (${history.length})',
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            if (_tab == _Tab.upcoming)
              ..._upcoming(context, live)
            else
              ..._completed(context, history),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }

  /// The next round, who is playing and what is on the course.
  List<Widget> _upcoming(BuildContext context, Round? live) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final players = ref.watch(selectedPlayersProvider);
    final planned = upcomingRound.planned;

    return <Widget>[
      if (live != null)
        QaddyRoundCard(
          course: live.course,
          when: 'Hole ${live.currentHole + 1} of ${live.holes.length}',
          note: _liveLine(live),
          noteIcon: Icons.leaderboard_outlined,
          players: <String>[for (final p in live.players) p.name],
          total: live.players.length,
          primaryLabel: 'Continue round',
          onPrimary: () => context.push(AppRoutes.roundScorecard),
        )
      else
        QaddyRoundCard(
          course: upcomingRound.course,
          day: planned ? upcomingRound.date : null,
          teeTime: planned ? upcomingRound.teeTime : null,
          note: planned
              ? '${upcomingRound.weather} · ${upcomingRound.format}'
              : upcomingRound.format,
          noteIcon: planned
              ? Icons.wb_sunny_outlined
              : Icons.emoji_events_outlined,
          players: <String>[for (final p in players) p.name],
          total: players.length,
          showCount: players.length > 1,
          sample: planned,
          primaryLabel: 'Start round',
          onPrimary: () {
            QaddyHaptics.success();
            ref.read(roundsProvider.notifier).startRound(players);
            context.push(AppRoutes.roundScorecard);
          },
          onDetails: planned
              ? () => shareOrCopy(
                  context,
                  ref,
                  text: roundShareMessage(upcomingRound, currentUserName),
                  subject: "Who's in?",
                )
              : null,
        ),
      if (live != null && live.holesPlayed > 0) ...<Widget>[
        SizedBox(height: spacing.sectionGap),
        StandingsPreview(
          round: live,
          onOpen: () => context.push(AppRoutes.roundLeaderboard),
        ),
      ],
      if (live == null) ...<Widget>[
        SizedBox(height: spacing.sectionGap),
        QaddySectionHeading(
          title: "Who's playing",
          badge: ref.watch(roundSetupProvider).length,
        ),
        SizedBox(height: spacing.md),
        const _Players(),
      ],
      if (upcomingRoundSideGames.isNotEmpty) ...<Widget>[
        SizedBox(height: spacing.sectionGap),
        const QaddySectionHeading(title: 'On the course (sample)'),
        SizedBox(height: spacing.md),
        const _SideGames(),
      ],
      // The honest caveat, kept quiet and out of the way of the one action on
      // this screen.
      if (live == null) ...<Widget>[
        SizedBox(height: spacing.lg),
        Text(
          planned
              ? 'Hole pars and distances use a sample 18-hole layout '
                    'until course search arrives.'
              : 'Pars and stroke indexes use a standard par-72 layout '
                    'until course search arrives. Distances are left '
                    'out rather than guessed.',
          style: typography.caption.copyWith(color: colours.textTertiary),
        ),
      ],
    ];
  }

  /// Where the golfer stands, for the live card.
  String _liveLine(Round round) {
    final standings = standingsOf(round);
    final you = standings.where((s) => s.player.name == currentUserName);
    return round.holesPlayed == 0 || you.isEmpty
        ? "Let's go — the first tee is yours."
        : 'You: ${you.first.position} · ${you.first.points} pts';
  }

  /// Every finished round, newest first.
  List<Widget> _completed(BuildContext context, List<Round> history) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    if (history.isEmpty) {
      return <Widget>[
        QaddyEmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No finished rounds yet',
          message:
              'Finish a round and it is kept here, with how it went. '
              'Your statistics are built from them.',
          actionLabel: 'See upcoming',
          onAction: () => setState(() => _tab = _Tab.upcoming),
        ),
      ];
    }

    return <Widget>[
      for (final (index, round) in history.indexed) ...<Widget>[
        if (index > 0) SizedBox(height: spacing.cardGap),
        _finished(context, round, latest: index == 0),
      ],
    ];
  }

  Widget _finished(BuildContext context, Round round, {required bool latest}) {
    final standings = standingsOf(round);
    final top = standings.first;
    final headline = winnersHeadline(standings, you: currentUserName);

    return QaddyRoundCard(
      course: round.course,
      day: _dayLabel(round.completedAt ?? round.startedAt),
      note: '$headline · ${top.points} pts',
      players: <String>[for (final p in round.players) p.name],
      total: round.players.length,
      // The results screen shows the latest round; older ones have no results
      // page of their own yet.
      primaryLabel: latest ? 'View results' : null,
      onPrimary: latest ? () => context.push(AppRoutes.roundComplete) : null,
    );
  }
}

/// "Sat, 7 Nov".
String _dayLabel(DateTime when) {
  const weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[when.weekday - 1]}, ${when.day} ${months[when.month - 1]}';
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
