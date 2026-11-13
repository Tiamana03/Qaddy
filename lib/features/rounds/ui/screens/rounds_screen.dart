/// Qaddy's Rounds destination, as the approved "My Rounds" mockup draws it:
/// the brand bar, the title with a gold Create round button, a search bar, the
/// Upcoming / Completed / Invitations tabs and rounds as photo cards.
///
/// Before the round the Upcoming tab is the next round and its gold Start
/// round button, with who is playing below. During the round it is the way
/// back to the scorecard. After the round the finished round moves to
/// Completed, one tap from the celebration. Invitations is honest about being
/// empty: rounds are not invited to yet. The filter button keeps its place,
/// dimmed. See `docs/features/rounds-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_pill.dart';
import 'package:qaddy/core/widgets/brand/app_brand_bar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_round_list_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_bar.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_pill_tabs.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/state/course_providers.dart';
import 'package:qaddy/features/courses/ui/course_picker_sheet.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/setup_player_tile.dart';
import 'package:qaddy/features/rounds/ui/widgets/standings_preview.dart';

/// The Rounds destination (route `/rounds`).
class RoundsScreen extends ConsumerStatefulWidget {
  const RoundsScreen({super.key});

  @override
  ConsumerState<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends ConsumerState<RoundsScreen> {
  static const int _upcoming = 0;
  static const int _completed = 1;
  static const int _invitations = 2;

  int _tab = _upcoming;
  final TextEditingController _search = TextEditingController();
  final GlobalKey _playersKey = GlobalKey();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Brings the "Who's playing" list into view: what Create round and View
  /// details both mean when a round is planned here.
  void _showPlayers() {
    setState(() => _tab = _upcoming);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _playersKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  bool _matches(String course) {
    final query = _search.text.trim().toLowerCase();
    return query.isEmpty || course.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final live = ref.watch(liveRoundProvider);
    final history = ref.watch(roundHistoryProvider);

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            const SizedBox(height: 8),
            const AppBrandBar(showSearch: false),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My rounds',
                      style: QaddyText.pageTitle.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 142,
                  child: QaddyGoldButton(
                    label: 'Create round',
                    icon: Icons.add_rounded,
                    compact: true,
                    height: 40,
                    onPressed: _showPlayers,
                  ),
                ),
              ],
            ),
            Text(
              'Play more. Keep track. Make it count.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.listMeta.copyWith(color: colours.textSecondary),
            ),
            const SizedBox(height: 14),
            QaddySearchBar(
              hintText: 'Search courses…',
              controller: _search,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            QaddyPillTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
              tabs: <QaddyPillTab>[
                const QaddyPillTab(label: 'Upcoming (1)'),
                QaddyPillTab(
                  label: history.isEmpty
                      ? 'Completed'
                      : 'Completed (${history.length})',
                ),
                const QaddyPillTab(label: 'Invitations'),
              ],
            ),
            const SizedBox(height: 14),
            ...switch (_tab) {
              _completed => _completedTab(context, history),
              _invitations => _invitationsTab(),
              _ => _upcomingTab(context, live),
            },
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }

  Widget _nothingMatches() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        'No rounds match "${_search.text.trim()}".',
        style: QaddyText.listMeta.copyWith(
          color: Theme.of(context).extension<QaddyColours>()!.textSecondary,
        ),
      ),
    ),
  );

  /// The next round, who is playing and what is on the course.
  List<Widget> _upcomingTab(BuildContext context, Round? live) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final players = ref.watch(selectedPlayersProvider);
    final planned = upcomingRound.planned;
    final nextCourse = ref.watch(nextRoundCourseProvider);
    final course = live?.course ?? nextCourse.name;

    final card = live != null
        ? QaddyRoundListCard(
            course: live.course,
            date: 'Today',
            time: 'Hole ${live.currentHole + 1} of ${live.holes.length}',
            detail: _liveLine(live),
            detailIcon: Icons.leaderboard_outlined,
            players: <String>[for (final p in live.players) p.name],
            total: live.players.length,
            statusLabel: 'Live',
            tone: QaddyPillTone.success,
            statusIcon: Icons.circle,
            leading: QaddyCardAction(
              label: 'Leaderboard',
              onPressed: () => context.push(AppRoutes.roundLeaderboard),
            ),
            primary: QaddyCardAction(
              label: 'Continue round',
              onPressed: () => context.push(AppRoutes.roundScorecard),
            ),
          )
        : QaddyRoundListCard(
            course: nextCourse.name,
            date: planned ? upcomingRound.date : 'Ready when you are',
            time: planned ? upcomingRound.teeTime : null,
            detail: upcomingRound.format,
            weather: planned ? upcomingRound.weather : null,
            players: <String>[for (final p in players) p.name],
            total: players.length,
            sample: planned,
            statusLabel: 'Planned',
            statusIcon: Icons.schedule,
            leading: QaddyCardAction(
              label: 'View details',
              onPressed: _showPlayers,
            ),
            middle: planned
                ? QaddyCardAction(
                    label: 'Share',
                    icon: Icons.ios_share_rounded,
                    onPressed: () => shareOrCopy(
                      context,
                      ref,
                      text: roundShareMessage(upcomingRound, currentUserName),
                      subject: "Who's in?",
                    ),
                  )
                : null,
            primary: QaddyCardAction(
              label: 'Start round',
              onPressed: () {
                QaddyHaptics.success();
                ref.read(roundsProvider.notifier).startRound(players);
                context.push(AppRoutes.roundScorecard);
              },
            ),
          );

    if (!_matches(course)) {
      return <Widget>[_nothingMatches()];
    }

    return <Widget>[
      card,
      if (live != null && live.holesPlayed > 0) ...<Widget>[
        SizedBox(height: spacing.sectionGap),
        StandingsPreview(
          round: live,
          onOpen: () => context.push(AppRoutes.roundLeaderboard),
        ),
      ],
      if (live == null) ...<Widget>[
        SizedBox(height: spacing.sectionGap),
        const QaddySectionHeading(title: 'Course'),
        SizedBox(height: spacing.md),
        const _CourseChoice(),
        SizedBox(height: spacing.sectionGap),
        KeyedSubtree(
          key: _playersKey,
          child: QaddySectionHeading(
            title: "Who's playing",
            badge: ref.watch(roundSetupProvider).length,
          ),
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
          style: QaddyText.tagline.copyWith(color: colours.textTertiary),
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
  List<Widget> _completedTab(BuildContext context, List<Round> history) {
    if (history.isEmpty) {
      return <Widget>[
        QaddyEmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No finished rounds yet',
          message:
              'Finish a round and it is kept here, with how it went. '
              'Your statistics are built from them.',
          actionLabel: 'See upcoming',
          onAction: () => setState(() => _tab = _upcoming),
        ),
      ];
    }
    final shown = <(int, Round)>[
      for (final (index, round) in history.indexed)
        if (_matches(round.course)) (index, round),
    ];
    if (shown.isEmpty) {
      return <Widget>[_nothingMatches()];
    }

    return <Widget>[
      for (final (position, entry) in shown.indexed) ...<Widget>[
        if (position > 0) const SizedBox(height: 12),
        _finished(context, entry.$2, latest: entry.$1 == 0),
      ],
    ];
  }

  Widget _finished(BuildContext context, Round round, {required bool latest}) {
    final standings = standingsOf(round);
    final top = standings.first;
    final headline = winnersHeadline(standings, you: currentUserName);

    return QaddyRoundListCard(
      course: round.course,
      date: _dayLabel(round.completedAt ?? round.startedAt),
      detail: '$headline · ${top.points} pts',
      players: <String>[for (final p in round.players) p.name],
      total: round.players.length,
      statusLabel: 'Finished',
      tone: QaddyPillTone.success,
      statusIcon: Icons.check_rounded,
      // The results screen shows the latest round; older ones have no results
      // page of their own yet.
      primary: latest
          ? QaddyCardAction(
              label: 'View results',
              onPressed: () => context.push(AppRoutes.roundComplete),
            )
          : null,
    );
  }

  List<Widget> _invitationsTab() => <Widget>[
    QaddyEmptyState(
      icon: Icons.mail_outline_rounded,
      title: 'No invitations yet',
      message:
          'When a mate invites you to a round, it shows up here for you to '
          'accept.',
      actionLabel: 'See upcoming',
      onAction: () => setState(() => _tab = _upcoming),
    ),
  ];
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
/// The course the next round is on, with a way to change it.
class _CourseChoice extends ConsumerWidget {
  const _CourseChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final course = ref.watch(nextRoundCourseProvider);
    final detail = switch (course.origin) {
      CourseOrigin.generic =>
        'Standard layout: par and stroke index only. Choose your course for '
            'its holes and distances.',
      CourseOrigin.sample => 'Sample course',
      CourseOrigin.database => <String>[
        if (course.location.label.isNotEmpty) course.location.label,
        '${course.holeCount} holes',
      ].join(' · '),
    };

    return CourseRow(
      name: course.name,
      detail: detail,
      logoUrl: course.logoUrl,
      onTap: () => showCoursePicker(context),
      trailing: Text(
        'Change',
        style: QaddyText.listMeta.copyWith(color: colours.gold),
      ),
    );
  }
}

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
