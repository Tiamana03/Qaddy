/// Qaddy's Golf Bag — the golfer's personal equipment locker.
///
/// It is the bag you would want to open before every round: how many clubs you
/// carry and how they are gapped, a ladder of every club's distance, the clubs
/// you trust and the notes you have written to yourself. Tap any club to tune
/// it. The golfer's edits are saved on the device. See
/// `docs/features/golf-bag-release-candidate.md`.
///
/// The feature folder is `my_bag`; only the folder name differs from the
/// public "Golf Bag" name used everywhere else.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_underline_tabs.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_app_bar.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/my_bag/logic/bag_insights.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/models/placeholder_my_bag.dart';
import 'package:qaddy/features/my_bag/state/bag_controller.dart';
import 'package:qaddy/features/my_bag/ui/widgets/club_picture.dart';
import 'package:qaddy/features/my_bag/ui/widgets/club_sheet.dart';
import 'package:qaddy/features/my_bag/ui/widgets/distance_ladder.dart';

/// Golf Bag (route `/profile/bag`).
class GolfBagScreen extends ConsumerStatefulWidget {
  const GolfBagScreen({super.key});

  @override
  ConsumerState<GolfBagScreen> createState() => _GolfBagScreenState();
}

class _GolfBagScreenState extends ConsumerState<GolfBagScreen> {
  static const List<String> _tabs = <String>[
    'My clubs',
    'Distances',
    'Insights',
  ];
  int _tab = 0;

  Future<void> _addClub() => showQaddyNotice(
    context,
    title: 'Adding clubs is coming',
    message:
        'For now, tap any club to tune its model, distance, trust and notes. '
        'Your starter set already covers a full bag.',
    icon: Icons.sports_golf,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final bag = ref.watch(bagProvider);
    final goTo = goToClub(bag);

    void open(BagClub club) => showClubSheet(context, club.id);

    final kit = <BagClub>[
      for (final club in bag)
        if (!club.family.hasCarry) club,
    ];
    final noted = <BagClub>[
      for (final club in bag)
        if (club.hasNote) club,
    ];

    return QaddyScaffold(
      appBar: QaddyAppBar(
        title: 'My golf bag',
        centerTitle: true,
        actions: <Widget>[
          Tooltip(
            message: 'Add a club',
            child: InkResponse(
              onTap: _addClub,
              radius: 24,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: colours.gradientGold,
                ),
                child: Icon(Icons.add, size: 22, color: colours.backgroundBase),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 6),
          QaddyUnderlineTabs(
            labels: _tabs,
            selected: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: staggered(<Widget>[
                  const SizedBox(height: 14),
                  if (_tab == 0) ...<Widget>[
                    for (final (index, club) in bag.indexed) ...<Widget>[
                      if (index > 0) const SizedBox(height: 10),
                      _ClubRow(club: club, onTap: () => open(club)),
                    ],
                  ] else if (_tab == 1) ...<Widget>[
                    const QaddySectionHeading(title: 'Your distances'),
                    SizedBox(height: spacing.xs),
                    _Hint(
                      starterClubCount(bag) == 0
                          ? 'Tap a club to tune its distance, trust and notes.'
                          : 'Starter distances: typical carries so you can see '
                                'how this works. Tap a club and set yours.',
                    ),
                    SizedBox(height: spacing.md),
                    DistanceLadder(clubs: bag, goTo: goTo, onTapClub: open),
                  ] else ...<Widget>[
                    _Hero(bag: bag, goTo: goTo),
                    if (kit.isNotEmpty) ...<Widget>[
                      SizedBox(height: spacing.sectionGap),
                      const QaddySectionHeading(title: 'Putter and ball'),
                      SizedBox(height: spacing.md),
                      _Kit(kit: kit, onTap: open),
                    ],
                    SizedBox(height: spacing.sectionGap),
                    const QaddySectionHeading(title: 'Notes to self'),
                    SizedBox(height: spacing.md),
                    if (noted.isNotEmpty)
                      _Notes(clubs: noted, onTap: open)
                    else
                      const _NotesInvite(),
                  ],
                  SizedBox(height: spacing.xl),
                ]),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: colours.background,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.pagePadding,
              spacing.sm,
              spacing.pagePadding,
              spacing.md,
            ),
            child: QaddyGoldButton(
              label: 'Add club',
              pill: true,
              height: 52,
              onPressed: _addClub,
            ),
          ),
        ),
      ),
    );
  }
}

/// "220m average distance. " for a club that has a carry.
String _distance(BagClub club) =>
    '${formatDistance(club.carryMetres!)} average distance. ';

/// A club in the list, as the mockup draws it: its picture, its name and
/// model, and how far it goes at the right.
class _ClubRow extends StatelessWidget {
  const _ClubRow({required this.club, required this.onTap});

  final BagClub club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;

    return Semantics(
      button: true,
      label:
          '${club.name}. ${club.hasModel ? club.model : 'Model not set'}. '
          '${club.hasCarry ? _distance(club) : ''}'
          'Tap to tune it.',
      excludeSemantics: true,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(color: colours.border),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius.medium),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              QaddyHaptics.selection();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
              child: Row(
                children: <Widget>[
                  ClubPicture(family: club.family, width: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: QaddyText.listTitle.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                        Text(
                          club.hasModel
                              ? club.model
                              : 'Add your ${club.name.toLowerCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: QaddyText.meta.copyWith(
                            height: 17 / 12,
                            color: club.hasModel
                                ? colours.textSecondary
                                : colours.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (club.hasCarry)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: club.carryMetres!.round().toString(),
                              ),
                              const TextSpan(
                                text: 'm',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          style: QaddyText.tileFigure.copyWith(
                            fontSize: 22,
                            height: 28 / 22,
                            color: colours.textPrimary,
                          ),
                        ),
                        Text(
                          'Avg distance',
                          style: QaddyText.weatherCondition.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else if (club.family == ClubFamily.putter)
                    ConfidenceDots(confidence: club.confidence),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Text(
      text,
      style: typography.small.copyWith(color: colours.textSecondary),
    );
  }
}

/// The headline: how many clubs, how they are gapped, and what stands out.
class _Hero extends StatelessWidget {
  const _Hero({required this.bag, required this.goTo});

  final List<BagClub> bag;
  final BagClub? goTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.88);
    final animate = !MediaQuery.disableAnimationsOf(context);

    final count = clubCount(bag);
    final longest = longestClub(bag);
    final ball = bag.where((c) => c.family == ClubFamily.ball && c.hasModel);
    final starter = starterClubCount(bag);

    // Warm, like worn leather and brass.
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.lerp(colours.accentOrange, colours.backgroundBase, 0.68)!,
        Color.lerp(colours.gold, colours.backgroundBase, 0.82)!,
      ],
    );

    return QaddyHeroCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyEyebrow(starter == 0 ? 'Your bag' : 'Starter bag'),
          SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: animate ? 0 : count.toDouble(),
                  end: count.toDouble(),
                ),
                duration: QaddyMotion.standard.loading,
                curve: QaddyMotion.standard.enter,
                builder: (context, value, _) => Text(
                  '${value.round()}',
                  style: typography.display.copyWith(
                    color: onGradient,
                    height: 1,
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
                  child: Text(
                    count == 1 ? 'club in\nthe bag' : 'clubs in\nthe bag',
                    style: typography.h3.copyWith(color: onGradient),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            starter == 0
                ? gappingStory(bag)
                : 'A typical set to get you started. ${gappingStory(bag)}',
            style: typography.body.copyWith(color: muted),
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              if (longest != null)
                QaddyInfoChip(
                  icon: Icons.rocket_launch_outlined,
                  text:
                      '${longest.name} ${formatDistance(longest.carryMetres!)}',
                ),
              if (goTo != null)
                QaddyInfoChip(
                  icon: Icons.star_outline,
                  text: 'Go-to: ${goTo!.name}',
                ),
              if (ball.isNotEmpty)
                QaddyInfoChip(
                  icon: Icons.circle_outlined,
                  text: ball.first.model,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The putter and the ball: no distance, but a model, a note and trust.
class _Kit extends StatelessWidget {
  const _Kit({required this.kit, required this.onTap});

  final List<BagClub> kit;
  final ValueChanged<BagClub> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    Widget tile(BagClub club) => Expanded(
      child: Semantics(
        button: true,
        label:
            '${club.name}, ${club.hasModel ? club.model : 'model not set'}.'
            '${club.hasNote ? ' ${club.note}.' : ''} Tap to tune it.',
        excludeSemantics: true,
        onTap: () => onTap(club),
        child: QaddyCard(
          onTap: () {
            QaddyHaptics.selection();
            onTap(club);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              QaddyIconBadge(
                icon: club.family == ClubFamily.putter
                    ? Icons.flag_outlined
                    : Icons.circle_outlined,
                colour: clubColour(colours, club.family),
              ),
              SizedBox(height: spacing.md),
              Text(
                club.name,
                style: typography.h3.copyWith(color: colours.textPrimary),
              ),
              SizedBox(height: spacing.xs),
              Text(
                club.hasModel
                    ? club.model
                    : 'Add your ${club.name.toLowerCase()}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(
                  color: club.hasModel
                      ? colours.textSecondary
                      : colours.textTertiary,
                ),
              ),
              if (club.family == ClubFamily.putter) ...<Widget>[
                SizedBox(height: spacing.sm),
                ConfidenceDots(confidence: club.confidence),
              ],
            ],
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (index, club) in kit.indexed) ...<Widget>[
            if (index > 0) SizedBox(width: spacing.cardGap),
            tile(club),
          ],
        ],
      ),
    );
  }
}

/// The golfer's own words about their clubs, as quotes.
class _Notes extends StatelessWidget {
  const _Notes({required this.clubs, required this.onTap});

  final List<BagClub> clubs;
  final ValueChanged<BagClub> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, club) in clubs.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.lg),
            Semantics(
              button: true,
              label: '${club.name}: ${club.note}. Tap to edit.',
              excludeSemantics: true,
              onTap: () => onTap(club),
              child: InkWell(
                onTap: () => onTap(club),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    QaddyIconBadge(
                      icon: Icons.format_quote,
                      colour: clubColour(colours, club.family),
                      size: 36,
                      iconSize: 20,
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            club.name,
                            style: typography.small.copyWith(
                              color: colours.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            club.note,
                            style: typography.body.copyWith(
                              color: colours.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown until the golfer writes a first note: what notes are for.
class _NotesInvite extends StatelessWidget {
  const _NotesInvite();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyIconBadge(
            icon: Icons.edit_note,
            colour: colours.accentTeal,
            size: 36,
            iconSize: 20,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              'Nothing here yet. Tap a club to leave yourself a note, like '
              '"plays a club longer into the wind", and it shows up here.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
