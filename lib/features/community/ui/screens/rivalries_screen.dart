/// Qaddy's Rivalries screen — the whole story of you against a mate: the score,
/// who has the edge and the last time you met.
///
/// See `docs/architecture/rivalries.md` and
/// `docs/features/friends-profile-and-rivalries.md`. Displays the shared
/// placeholder rivalry: the current user (Tiamana) against Tom.
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
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/rivalry_spotlight.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

/// Rivalries (route `/friends/rivalries`).
class RivalriesScreen extends ConsumerWidget {
  const RivalriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final summary = RivalrySummary.of(tomRivalry);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Rivalries')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            RivalrySpotlight(
              summary: summary,
              yourName: currentUserName,
              onChallenge: () => shareOrCopy(
                context,
                ref,
                text: summary.challengeMessage(currentUserName),
                subject: 'Rematch?',
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'The scoreboard'),
            SizedBox(height: spacing.md),
            _Scoreboard(summary: summary),
            SizedBox(height: spacing.sectionGap),
            QaddySecondaryButton(
              label: 'Plan the rematch with ${summary.friendName}',
              icon: Icons.sports_golf,
              onPressed: () {
                QaddyHaptics.light();
                ref.read(roundSetupProvider.notifier).pick(<String>[
                  summary.friendName,
                ]);
                context.go(AppRoutes.rounds);
              },
            ),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// Wins, halved and losses as three counting-up numbers, with how much of the
/// decided rounds the golfer has taken.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.summary});

  final RivalrySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final decided = summary.youWins + summary.theirWins;
    final percent = decided == 0 ? 0 : (summary.youShare * 100).round();
    final verdict = decided == 0
        ? ''
        : 'You have taken $percent percent of decided rounds.';

    Widget tile(String label, int value, Color colour) => Expanded(
      child: Column(
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => Text(
              '${(value * t).round()}',
              style: typography.display.copyWith(
                color: colour,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      label:
          'You have won ${summary.youWins}, ${summary.friendName} has won '
          '${summary.theirWins}, ${summary.draws} halved. '
          '$verdict',
      child: ExcludeSemantics(
        child: QaddyCard(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  tile('You won', summary.youWins, colours.gold),
                  tile('Halved', summary.draws, colours.textSecondary),
                  tile(
                    '${summary.friendName} won',
                    summary.theirWins,
                    colours.accentSky,
                  ),
                ],
              ),
              if (decided > 0) ...<Widget>[
                SizedBox(height: spacing.lg),
                Text(
                  'You have taken $percent% of the rounds with a winner.',
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
