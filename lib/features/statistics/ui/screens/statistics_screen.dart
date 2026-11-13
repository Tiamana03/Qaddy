/// Qaddy's Statistics screen — the story of the rounds the golfer has
/// actually played.
///
/// It is laid out as the approved Profile mockup's Stats page: a handicap
/// card, the scoring overview, driving and approach, and performance by hole,
/// then the rest of the story (form, how they score, their holes, rivals and
/// highlights). Everything on it is worked out from finished rounds (see
/// `logic/career_stats.dart`); what Qaddy cannot know yet (drive length,
/// greens hit, putts) is drawn in its place with a dash and says why when
/// tapped. With no rounds yet it invites them to play one. See
/// `docs/features/statistics-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_stat_tiles.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_pill_tabs.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_app_bar.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_chart.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_sparkline.dart';
import 'package:qaddy/features/statistics/ui/widgets/hole_bars.dart';
import 'package:qaddy/features/statistics/ui/widgets/rival_row.dart';
import 'package:qaddy/features/statistics/ui/widgets/score_mix_bar.dart';
import 'package:qaddy/features/statistics/ui/widgets/stats_panel.dart';

/// Statistics (route `/profile/statistics`).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);

    return QaddyScaffold(
      phoneSidePadding: 9,
      appBar: const QaddyAppBar(title: 'Statistics'),
      body: stats == null
          ? Center(
              child: QaddyEmptyState(
                icon: Icons.insights_outlined,
                title: 'Your story starts on the first tee',
                message:
                    'Play a round and this fills with your scoring, your '
                    'form, your best holes and who you keep beating.',
                actionLabel: 'Start a round',
                onAction: () => context.go(AppRoutes.rounds),
              ),
            )
          : _Story(stats: stats),
    );
  }
}

class _Story extends ConsumerStatefulWidget {
  const _Story({required this.stats});

  final CareerStats stats;

  @override
  ConsumerState<_Story> createState() => _StoryState();
}

class _StoryState extends ConsumerState<_Story> {
  static const List<QaddyPillTab> _tabs = <QaddyPillTab>[
    QaddyPillTab(label: 'Overview'),
    QaddyPillTab(label: 'Stats'),
    QaddyPillTab(label: 'Equipment'),
    QaddyPillTab(label: 'Activity'),
    QaddyPillTab(label: 'Achievements'),
  ];

  final GlobalKey _formKey = GlobalKey();
  final GlobalKey _mixKey = GlobalKey();
  final GlobalKey _holesKey = GlobalKey();

  void _openTab(int index) {
    switch (index) {
      case 0 || 4:
        context.go(AppRoutes.profile);
      case 2:
        context.push(AppRoutes.profileGolfBag);
      case 3:
        context.go(AppRoutes.rounds);
    }
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.02,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _needsShots(String what) => showQaddyNotice(
    context,
    title: '$what needs shot tracking',
    message:
        'Qaddy scores your rounds in Stableford points, hole by hole. Drive '
        'length, fairways, greens and putts arrive with shot tracking, so '
        'nothing is guessed here in the meantime.',
    icon: Icons.insights_outlined,
  );

  Future<void> _aboutHandicap() => showQaddyNotice(
    context,
    title: 'About your handicap',
    message:
        'This is the handicap you set in your profile. The line beside it '
        'is your points a round, oldest first, so you can see your form '
        'moving.',
    icon: Icons.info_outline,
  );

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final stats = widget.stats;
    final hasResults = ref.watch(completedRoundProvider) != null;
    final handicap = ref.watch(golferDetailsProvider).handicap;
    final mix = stats.mix;

    const gap = SizedBox(height: 8);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: staggered(<Widget>[
          QaddyPillTabs(
            tabs: _tabs,
            selected: 1,
            proportional: true,
            dense: true,
            onChanged: _openTab,
          ),
          const SizedBox(height: 11),
          _HandicapPanel(
            stats: stats,
            handicap: handicap,
            onInfo: _aboutHandicap,
            onHistory: () => context.go(AppRoutes.rounds),
          ),
          gap,
          StatsPanel(
            title: 'Scoring Overview',
            actionLabel: 'View Details',
            onAction: () => _scrollTo(_mixKey),
            child: QaddyStatTiles(
              layout: QaddyStatLayout.compact,
              height: 58,
              tintFirst: false,
              semanticPrefix: 'Scoring overview',
              semanticAction: 'Shows how you score.',
              onOpen: () => _scrollTo(_mixKey),
              stats: <QaddyStat>[
                QaddyStat(
                  figure: '${stats.averagePoints.round()}',
                  label: 'Avg points',
                ),
                QaddyStat(
                  figure: '${stats.bestRound.points}',
                  label: 'Best round',
                ),
                QaddyStat(
                  figure: '${mix.birdies + mix.eagleOrBetter}',
                  label: 'Birdies',
                ),
                QaddyStat(
                  figure: '${(mix.parOrBetterRate * 100).round()}%',
                  label: 'Par or better',
                ),
              ],
            ),
          ),
          gap,
          StatsPanel(
            title: 'Driving',
            actionLabel: 'View Details',
            onAction: () => _needsShots('Driving'),
            child: _DrivingRow(onOpen: () => _needsShots('Driving')),
          ),
          gap,
          StatsPanel(
            title: 'Approach',
            actionLabel: 'View Details',
            onAction: () => _needsShots('Approach'),
            child: QaddyStatTiles(
              layout: QaddyStatLayout.compact,
              height: 70,
              tintFirst: false,
              semanticPrefix: 'Approach',
              semanticAction: 'Explains what is needed.',
              onOpen: () => _needsShots('Approach'),
              stats: const <QaddyStat>[
                QaddyStat(
                  figure: '–',
                  label: 'Greens in Reg.',
                  icon: Icons.gps_fixed,
                ),
                QaddyStat(
                  figure: '–',
                  label: 'Avg. Proximity',
                  icon: Icons.flag_outlined,
                ),
                QaddyStat(
                  figure: '–',
                  label: 'Avg. Putts',
                  icon: Icons.sports_golf,
                ),
              ],
            ),
          ),
          gap,
          StatsPanel(
            title: 'Performance by Hole',
            actionLabel: 'View Full',
            onAction: () =>
                _scrollTo(stats.favouriteHole != null ? _holesKey : _formKey),
            child: HoleBars(holes: stats.holeStats),
          ),
          SizedBox(height: spacing.sectionGap),
          KeyedSubtree(
            key: _formKey,
            child: const QaddySectionHeading(title: 'Your form'),
          ),
          SizedBox(height: spacing.xs),
          _FormStory(stats: stats),
          SizedBox(height: spacing.md),
          _FormCard(stats: stats),
          SizedBox(height: spacing.sectionGap),
          KeyedSubtree(
            key: _mixKey,
            child: const QaddySectionHeading(title: 'How you score'),
          ),
          SizedBox(height: spacing.md),
          _MixCard(stats: stats),
          if (stats.favouriteHole != null) ...<Widget>[
            SizedBox(height: spacing.sectionGap),
            KeyedSubtree(
              key: _holesKey,
              child: const QaddySectionHeading(title: 'Your holes'),
            ),
            SizedBox(height: spacing.md),
            _HolesCard(stats: stats),
          ],
          if (stats.rivals.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Head to head'),
            SizedBox(height: spacing.md),
            _RivalsCard(rivals: stats.rivals.take(5).toList()),
          ],
          SizedBox(height: spacing.sectionGap),
          const QaddySectionHeading(title: 'Highlights'),
          SizedBox(height: spacing.md),
          _HighlightsCard(stats: stats),
          if (hasResults) ...<Widget>[
            SizedBox(height: spacing.lg),
            QaddyGoldButton(
              label: 'See your last round',
              icon: Icons.emoji_events_outlined,
              onPressed: () => context.push(AppRoutes.roundComplete),
            ),
          ],
          SizedBox(height: spacing.xl),
        ]),
      ),
    );
  }
}

/// The mockup's Handicap card: the figure, how form is moving, and the line.
class _HandicapPanel extends StatelessWidget {
  const _HandicapPanel({
    required this.stats,
    required this.handicap,
    required this.onInfo,
    required this.onHistory,
  });

  final CareerStats stats;
  final double? handicap;
  final VoidCallback onInfo;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;

    final trend = stats.formTrend;
    final up = trend != null && trend >= 1.5;
    final down = trend != null && trend <= -1.5;
    final pillLabel = trend == null
        ? 'Early days'
        : up
        ? 'On the up'
        : down
        ? 'Quiet patch'
        : 'Holding steady';
    final pillColour = up
        ? Color.lerp(colours.success, Colors.white, 0.2)!
        : down
        ? colours.gold
        : colours.surface2;
    final pillText = up || down ? colours.backgroundBase : colours.textPrimary;
    final points = trend?.abs().round() ?? 0;
    final more = roundsForForm - stats.rounds;
    final subline = trend == null
        ? (more == 1 ? '1 more round' : '$more more rounds')
        : (up || down)
        ? '$points ${points == 1 ? 'pt' : 'pts'} a round'
        : 'On your usual numbers';

    return StatsPanel(
      title: 'Handicap',
      actionLabel: 'View History',
      onAction: onHistory,
      titleTrailing: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Semantics(
          button: true,
          label: 'About your handicap',
          excludeSemantics: true,
          onTap: onInfo,
          child: InkResponse(
            onTap: onInfo,
            radius: 18,
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: colours.textPrimary,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
      gap: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 122,
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    handicap == null ? '–' : handicapLabel(handicap!),
                    style: QaddyText.heroName.copyWith(
                      fontSize: 30,
                      height: 1,
                      color: colours.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillColour,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pillLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QaddyText.pillLabel.copyWith(
                        color: pillText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      if (up || down) ...<Widget>[
                        Icon(
                          up ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: up ? colours.success : colours.gold,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          subline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: QaddyText.listMeta.copyWith(
                            fontSize: 11.5,
                            color: colours.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 76,
                child: FormSparkline(
                  values: <double>[
                    for (final round in stats.form()) round.pointsPer18,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Driving: two tiles that wait for shot tracking and a hole picture, as the
/// mockup lays them out.
class _DrivingRow extends StatelessWidget {
  const _DrivingRow({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 186,
          child: QaddyStatTiles(
            layout: QaddyStatLayout.compact,
            height: 64,
            tintFirst: false,
            semanticPrefix: 'Driving',
            semanticAction: 'Explains what is needed.',
            onOpen: onOpen,
            stats: const <QaddyStat>[
              QaddyStat(
                figure: '–',
                label: 'Avg. Drive',
                icon: Icons.sports_golf,
              ),
              QaddyStat(figure: '–', label: 'Fairways', icon: Icons.gps_fixed),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          flex: 150,
          child: SizedBox(
            height: 64,
            child: _HolePreview(radius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

/// The hole picture beside the driving tiles: the course from above, dimmed,
/// with the line of a drive drawn over it. A placeholder for the final
/// artwork; the line is the picture's, not the golfer's.
class _HolePreview extends StatelessWidget {
  const _HolePreview({required this.radius});

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const QaddyMediaPlaceholder(aerial: true, tone: 2),
            const ColoredBox(color: Color(0x80001A0C)),
            CustomPaint(painter: _DrivePainter(colours.gold)),
          ],
        ),
      ),
    );
  }
}

class _DrivePainter extends CustomPainter {
  const _DrivePainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.16, size.height * 0.64);
    final end = Offset(size.width * 0.82, size.height * 0.4);
    canvas
      ..drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * 0.08,
            end.dx,
            end.dy,
          ),
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(start, 3, Paint()..color = const Color(0xFFF2F4F3))
      ..drawCircle(end, 3, Paint()..color = const Color(0xFFC9D0CC));
  }

  @override
  bool shouldRepaint(_DrivePainter old) => old.colour != colour;
}

/// The one line of the form guide, under its heading.
class _FormStory extends StatelessWidget {
  const _FormStory({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final typography = Theme.of(context).extension<QaddyTypography>()!;

    return Text(
      formStory(stats),
      style: typography.small.copyWith(color: colours.textSecondary),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final shown = stats.form();

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            shown.length == 1
                ? 'Points in your round'
                : 'Points over your last ${shown.length} rounds',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.md),
          FormChart(rounds: shown),
        ],
      ),
    );
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            parOrBetterLine(stats.mix),
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Across ${stats.holesPlayed} holes',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          ScoreMixBar(mix: stats.mix),
        ],
      ),
    );
  }
}

class _HolesCard extends StatelessWidget {
  const _HolesCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final favourite = stats.favouriteHole!;
    final toughest = stats.toughestHole!;

    Widget spotlight(
      String label,
      HoleStat hole,
      Color colour,
      IconData icon,
    ) => Expanded(
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colours.surface2,
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 16, color: colour),
                SizedBox(width: spacing.xs),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(color: colour),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Hole ${hole.number}',
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            Text(
              'Par ${hole.par} · ${pointsAverage(hole.averagePoints)} pts',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
    );

    Widget average(String label, double? value) => Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value == null ? '–' : pointsAverage(value),
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              spotlight(
                'Your favourite',
                favourite,
                colours.gold,
                Icons.favorite_border,
              ),
              SizedBox(width: spacing.cardGap),
              spotlight(
                'Your nemesis',
                toughest,
                colours.accentOrange,
                Icons.sentiment_dissatisfied_outlined,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Average points a hole',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Row(
            children: <Widget>[
              average('Par 3s', stats.parThreeAverage),
              average('Par 4s', stats.parFourAverage),
              average('Par 5s', stats.parFiveAverage),
              average('Front 9', stats.frontNineAverage),
              average('Back 9', stats.backNineAverage),
            ],
          ),
        ],
      ),
    );
  }
}

class _RivalsCard extends StatelessWidget {
  const _RivalsCard({required this.rivals});

  final List<Rival> rivals;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, rival) in rivals.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.lg),
            RivalRow(rival: rival),
          ],
        ],
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final best = stats.bestRound;
    final rows = <({IconData icon, Color colour, String title, String detail})>[
      (
        icon: Icons.emoji_events,
        colour: colours.gold,
        title: 'Best round: ${best.points} points',
        detail:
            '${best.round.course} · '
            '${best.date.day} ${best.date.monthAbbreviation}'
            '${best.holes < 18 ? ' · ${best.holes} holes' : ''}',
      ),
      (
        icon: Icons.military_tech_outlined,
        colour: colours.success,
        title: stats.wins == 1
            ? '1 win · ${winRateLabel(stats)}'
            : '${stats.wins} wins · ${winRateLabel(stats)}',
        detail: 'Of ${roundsLabel(stats.rounds)}',
      ),
      if (stats.mostBirdiesInARound > 0)
        (
          icon: Icons.local_fire_department_outlined,
          colour: colours.accentTeal,
          title: 'Most birdies in a round: ${stats.mostBirdiesInARound}',
          detail: 'Birdies or better',
        ),
      if (stats.longestWinStreak >= 2)
        (
          icon: Icons.bolt,
          colour: colours.accentOrange,
          title: 'Longest win streak: ${stats.longestWinStreak} rounds',
          detail: 'Back to back',
        ),
      (
        icon: Icons.golf_course,
        colour: colours.accentSky,
        title: '${stats.holesPlayed} holes played',
        detail: roundsLabel(stats.rounds),
      ),
    ];

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, row) in rows.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                QaddyIconBadge(icon: row.icon, colour: row.colour),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        row.title,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        row.detail,
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
    );
  }
}
