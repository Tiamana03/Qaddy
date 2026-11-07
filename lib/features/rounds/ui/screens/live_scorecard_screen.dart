/// The scorecard you keep in your pocket on a Saturday: one hole at a time,
/// everyone's score under your thumb, the leaderboard a tap away.
///
/// Composed as the approved Live Scoring mockup draws it: a top bar with the
/// players' faces, the strip of holes, "Hole N" with its facts and the pill to
/// the next hole, the hole view, the "Enter scores" panel and, at the foot, a
/// quiet button and a gold one. It replaces the paper card. Scores are saved as
/// they are entered, so a round survives the app being closed. See
/// `docs/features/rounds-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/responsive/responsive_max_width.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_face_stack.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_app_bar.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_header.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_progress_strip.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_view.dart';
import 'package:qaddy/features/rounds/ui/widgets/player_score_row.dart';
import 'package:qaddy/features/rounds/ui/widgets/score_picker_sheet.dart';
import 'package:qaddy/features/rounds/ui/widgets/standings_preview.dart';

/// What the menu in the corner can do.
enum _MenuAction { finish, discard }

/// The Live Scorecard (route `/rounds/scorecard`).
class LiveScorecardScreen extends ConsumerStatefulWidget {
  const LiveScorecardScreen({super.key});

  @override
  ConsumerState<LiveScorecardScreen> createState() =>
      _LiveScorecardScreenState();
}

class _LiveScorecardScreenState extends ConsumerState<LiveScorecardScreen> {
  /// Counts eagle-or-better moments; each new value plays a fresh burst of
  /// confetti.
  int _burst = 0;

  @override
  Widget build(BuildContext context) {
    final round = ref.watch(liveRoundProvider);
    if (round == null) {
      return const _NoRound();
    }

    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final controller = ref.read(roundsProvider.notifier);
    final onLast = round.currentHole == round.holes.length - 1;
    final holes = round.holesPlayed == 1
        ? 'the 1 hole'
        : 'the ${round.holesPlayed} holes';
    final standings = standingsOf(round);
    final byName = <String, PlayerStanding>{
      for (final s in standings) s.player.name: s,
    };

    void finish() {
      QaddyHaptics.success();
      // The hole banter must not linger over the results.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      controller.finishRound();
      context.pushReplacement(AppRoutes.roundComplete);
    }

    // On to the next hole, with a word about who took the one just played.
    void advance() {
      QaddyHaptics.light();
      final from = round.currentHole;
      controller.nextHole();
      final after = ref.read(liveRoundProvider);
      final line = after == null
          ? null
          : holeResultLine(after, from, you: currentUserName);
      if (line != null) {
        tellUser(context, line);
      }
    }

    // A hole is "fresh" until anyone has a score on it or any hole is played.
    final firstTee =
        round.currentHole == 0 &&
        round.holesPlayed == 0 &&
        !round.hasScore(round.players.first.name, 0);

    Future<void> confirmFinish() async {
      final ok = await showQaddyConfirm(
        context,
        title: 'Finish the round?',
        message: round.holesPlayed == 0
            ? 'Nothing has been scored yet, so there are no results to '
                  'show. You may want to discard it instead.'
            : 'Only $holes everyone has played will count.',
        confirmLabel: 'Finish round',
      );
      if (ok && round.holesPlayed > 0 && context.mounted) {
        finish();
      }
    }

    Future<void> onMenu(_MenuAction action) async {
      switch (action) {
        case _MenuAction.finish:
          await confirmFinish();
        case _MenuAction.discard:
          final ok = await showQaddyConfirm(
            context,
            title: 'Discard this round?',
            message:
                'The scores you have entered will be lost. This can’t be '
                'undone.',
            confirmLabel: 'Discard',
            destructive: true,
          );
          if (ok && context.mounted) {
            controller.discardRound();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.rounds);
            }
          }
      }
    }

    // You first, then everyone else in the order they were picked.
    final players = <int>[for (var i = 0; i < round.players.length; i++) i]
      ..sort((a, b) {
        final aYou = round.players[a].name == currentUserName ? 0 : 1;
        final bYou = round.players[b].name == currentUserName ? 0 : 1;
        return aYou != bYou ? aYou.compareTo(bYou) : a.compareTo(b);
      });
    final names = <String>[for (final p in round.players) p.name];

    return QaddyScaffold(
      appBar: QaddyAppBar(
        title: 'Live scoring',
        subtitle: round.course,
        actions: <Widget>[
          if (round.players.length > 1)
            Tooltip(
              message: 'Leaderboard',
              child: InkWell(
                onTap: () => context.push(AppRoutes.roundLeaderboard),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: QaddyFaceStack(
                    names: names,
                    total: names.length,
                    size: 30,
                    step: 24,
                    ringColour: colours.background,
                  ),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Leaderboard',
              icon: const Icon(Icons.leaderboard_outlined),
              onPressed: () => context.push(AppRoutes.roundLeaderboard),
            ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'Round options',
            onSelected: onMenu,
            padding: EdgeInsets.zero,
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colours.surface1,
                border: Border.all(color: colours.border),
              ),
              child: Icon(
                Icons.more_horiz,
                size: 18,
                color: colours.textPrimary,
              ),
            ),
            itemBuilder: (context) => const <PopupMenuEntry<_MenuAction>>[
              PopupMenuItem<_MenuAction>(
                value: _MenuAction.finish,
                child: Text('Finish round now'),
              ),
              PopupMenuItem<_MenuAction>(
                value: _MenuAction.discard,
                child: Text('Discard round'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                HoleProgressStrip(round: round, onSelect: controller.goToHole),
                const SizedBox(height: 14),
                HoleHeader(
                  hole: round.hole,
                  total: round.holes.length,
                  onNext: onLast ? null : advance,
                ),
                const SizedBox(height: 12),
                _Bleed(
                  child: HoleView(
                    hole: round.hole,
                    greeting: firstTee
                        ? 'Enjoy it out there, ${round.players.first.name}.'
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                const QaddySectionHeading(title: 'Enter scores'),
                const SizedBox(height: 8),
                _Bleed(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colours.card,
                      borderRadius: BorderRadius.circular(radius.medium),
                      border: Border.all(color: colours.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius.medium),
                      child: Column(
                        children: <Widget>[
                          for (final (position, index)
                              in players.indexed) ...<Widget>[
                            if (position > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 56),
                                child: Divider(
                                  height: 1,
                                  color: colours.border,
                                ),
                              ),
                            _ScoreRow(
                              round: round,
                              playerIndex: index,
                              toPar:
                                  byName[round.players[index].name]?.toPar ?? 0,
                              leads:
                                  round.holesPlayed > 0 &&
                                  round.players.length > 1 &&
                                  (byName[round.players[index].name]
                                          ?.isLeader ??
                                      false),
                              onBigMoment: () => setState(() => _burst++),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (round.holesPlayed > 0 &&
                    round.players.length > 1) ...<Widget>[
                  SizedBox(height: spacing.sectionGap),
                  QaddyFadeSlideIn(
                    child: StandingsPreview(
                      round: round,
                      onOpen: () => context.push(AppRoutes.roundLeaderboard),
                    ),
                  ),
                ],
                SizedBox(height: spacing.xl),
              ],
            ),
          ),
          if (_burst > 0)
            Positioned.fill(
              child: QaddyConfetti(key: ValueKey<int>(_burst), pieces: 90),
            ),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: colours.background,
        child: SafeArea(
          top: false,
          child: ResponsiveMaxWidth(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.pagePadding,
                spacing.sm,
                spacing.pagePadding,
                spacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Tooltip(
                      message: 'Previous hole',
                      child: QaddySecondaryButton(
                        label: 'Previous',
                        icon: Icons.arrow_back_rounded,
                        iconBefore: true,
                        onPressed: round.currentHole > 0
                            ? () {
                                QaddyHaptics.selection();
                                controller.previousHole();
                              }
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.sm + 1),
                  Expanded(
                    flex: 5,
                    child: QaddyGoldButton(
                      label: 'Finish round',
                      icon: Icons.flag_rounded,
                      onPressed: onLast ? finish : confirmFinish,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets a block run a little wider than the page's text, as the mockup's hole
/// view and score panel do (they sit closer to the screen edge than the
/// headings above them).
class _Bleed extends StatelessWidget {
  const _Bleed({required this.child});

  final Widget child;

  static const double _bleed = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FractionallySizedBox(
        widthFactor: (constraints.maxWidth + _bleed * 2) / constraints.maxWidth,
        child: child,
      ),
    );
  }
}

/// One player's row, wired to the store.
class _ScoreRow extends ConsumerWidget {
  const _ScoreRow({
    required this.round,
    required this.playerIndex,
    required this.toPar,
    required this.leads,
    required this.onBigMoment,
  });

  final Round round;
  final int playerIndex;
  final int toPar;
  final bool leads;
  final VoidCallback onBigMoment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = round.players[playerIndex];
    final hole = round.hole;
    final gross = round.grossAt(player.name, round.currentHole);
    final shots = shotsReceived(
      playingHandicap: player.playingHandicap,
      strokeIndex: hole.strokeIndex,
    );

    return PlayerScoreRow(
      name: player.name,
      isYou: player.name == currentUserName,
      par: hole.par,
      shots: shots,
      gross: gross,
      toPar: toPar,
      leads: leads,
      points: stablefordPoints(
        gross: gross ?? hole.par,
        par: hole.par,
        shots: shots,
      ),
      onNudge: (delta) {
        QaddyHaptics.selection();
        ref.read(roundsProvider.notifier).nudgeScore(player.name, delta);
      },
      onBigMoment: onBigMoment,
      onTapScore: () async {
        final picked = await showScorePicker(
          context,
          name: player.name == currentUserName ? 'You' : player.name,
          holeNumber: hole.number,
          par: hole.par,
          shots: shots,
          current: gross ?? hole.par,
        );
        if (picked != null) {
          ref.read(roundsProvider.notifier).setScore(player.name, picked);
        }
      },
    );
  }
}

/// Shown when the scorecard is opened with no round to score.
class _NoRound extends StatelessWidget {
  const _NoRound();

  @override
  Widget build(BuildContext context) {
    return QaddyScaffold(
      appBar: AppBar(title: const Text('Scorecard')),
      body: Center(
        child: QaddyEmptyState(
          icon: Icons.sports_golf,
          title: 'No round in progress',
          message:
              'Pick who is playing and start a round, and your scorecard '
              'appears here.',
          actionLabel: 'Go to Rounds',
          onAction: () => context.go(AppRoutes.rounds),
        ),
      ),
    );
  }
}
