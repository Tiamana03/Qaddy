/// The scorecard you keep in your pocket on a Saturday: one hole at a time,
/// everyone's score under your thumb, the leaderboard a tap away.
///
/// It replaces the paper card. Scores are saved as they are entered, so a
/// round survives the app being closed. See
/// `docs/features/rounds-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/responsive/responsive_max_width.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_banner.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_progress_strip.dart';
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
    final controller = ref.read(roundsProvider.notifier);
    final onLast = round.currentHole == round.holes.length - 1;
    final holes = round.holesPlayed == 1
        ? 'the 1 hole'
        : 'the ${round.holesPlayed} holes';

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

    Future<void> onMenu(_MenuAction action) async {
      switch (action) {
        case _MenuAction.finish:
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

    return QaddyScaffold(
      appBar: AppBar(
        title: Text(round.course),
        actions: <Widget>[
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.leaderboard_outlined),
            onPressed: () => context.push(AppRoutes.roundLeaderboard),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'Round options',
            onSelected: onMenu,
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
                SizedBox(height: spacing.md),
                HoleProgressStrip(round: round, onSelect: controller.goToHole),
                SizedBox(height: spacing.lg),
                HoleBanner(
                  hole: round.hole,
                  total: round.holes.length,
                  greeting: firstTee
                      ? 'Enjoy it out there, ${round.players.first.name}.'
                      : null,
                ),
                SizedBox(height: spacing.lg),
                for (final (position, index) in players.indexed) ...<Widget>[
                  if (position > 0) SizedBox(height: spacing.cardGap),
                  _ScoreRow(
                    round: round,
                    playerIndex: index,
                    onBigMoment: () => setState(() => _burst++),
                  ),
                ],
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
        color: colours.surface1,
        child: SafeArea(
          top: false,
          child: ResponsiveMaxWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.pagePadding,
                vertical: spacing.md,
              ),
              child: Row(
                children: <Widget>[
                  IconButton.outlined(
                    tooltip: 'Previous hole',
                    onPressed: round.currentHole > 0
                        ? () {
                            QaddyHaptics.selection();
                            controller.previousHole();
                          }
                        : null,
                    style: IconButton.styleFrom(
                      minimumSize: Size(spacing.display, spacing.display),
                      side: BorderSide(color: colours.border),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: QaddyGoldButton(
                      label: onLast ? 'Finish round' : 'Next hole',
                      icon: onLast
                          ? Icons.flag_rounded
                          : Icons.arrow_forward_rounded,
                      tall: true,
                      onPressed: onLast ? finish : advance,
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

/// One player's row, wired to the store.
class _ScoreRow extends ConsumerWidget {
  const _ScoreRow({
    required this.round,
    required this.playerIndex,
    required this.onBigMoment,
  });

  final Round round;
  final int playerIndex;
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
