/// Qaddy's Live Scorecard — hole-by-hole score entry during a round.
///
/// Sprint 2.3 — see `docs/sprints/sprint-02-03-live-scoring.md`. Course
/// data (par/stroke index/distance for all 18 holes) is sourced from
/// `docs/standards/placeholder-data.md`'s "Richmond Golf Club — Hole
/// Information" table. Every hole starts at its own par, per
/// `docs/architecture/round-data-model.md`'s "Hole Score Initial State".
///
/// This screen is intentionally not wired into `app_router.dart` —
/// `docs/architecture/navigation.md` defines no route for it, and neither
/// this sprint's "Build" nor "Do Not Build" sections ask for one, so none
/// is invented here.
///
/// State is plain, screen-local `StatefulWidget` state rather than a
/// Riverpod provider: nothing here persists or is shared with another
/// screen (`engineering-principles.md`'s "Riverpod only" rule governs
/// shared/app state, not ephemeral widget-local UI state), and the sprint
/// is explicit that "everything remains in memory."
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_header.dart';
import 'package:qaddy/features/rounds/ui/widgets/running_totals_card.dart';
import 'package:qaddy/features/rounds/ui/widgets/score_stepper.dart';

/// Richmond Golf Club's 18 holes (par, stroke index, distance in metres) —
/// see placeholder-data.md's "Richmond Golf Club — Hole Information" table.
const List<(int par, int strokeIndex, int distance)> _richmondGolfClub =
    <(int, int, int)>[
      (4, 11, 352),
      (5, 3, 486),
      (3, 17, 148),
      (4, 7, 371),
      (4, 1, 414),
      (5, 13, 471),
      (4, 9, 364),
      (3, 15, 163),
      (4, 5, 390),
      (4, 10, 360),
      (5, 2, 502),
      (3, 18, 141),
      (4, 6, 384),
      (4, 8, 373),
      (5, 4, 495),
      (3, 16, 158),
      (4, 12, 347),
      (4, 14, 401),
    ];

/// The Live Scorecard screen — score entry, hole navigation and running
/// totals for a round in progress.
class LiveScorecardScreen extends StatefulWidget {
  const LiveScorecardScreen({super.key});

  @override
  State<LiveScorecardScreen> createState() => _LiveScorecardScreenState();
}

class _LiveScorecardScreenState extends State<LiveScorecardScreen> {
  final List<HoleScore> _holes = <HoleScore>[
    for (final (index, hole) in _richmondGolfClub.indexed)
      HoleScore(
        holeNumber: index + 1,
        par: hole.$1,
        strokeIndex: hole.$2,
        distance: hole.$3,
        grossScore: hole.$1,
      ),
  ];

  int _currentHoleIndex = 0;

  HoleScore get _currentHole => _holes[_currentHoleIndex];

  void _incrementScore() {
    setState(() {
      _holes[_currentHoleIndex] = _currentHole.copyWithGrossScore(
        _currentHole.grossScore + 1,
      );
    });
  }

  void _decrementScore() {
    setState(() {
      _holes[_currentHoleIndex] = _currentHole.copyWithGrossScore(
        _currentHole.grossScore - 1,
      );
    });
  }

  void _goToHole(int index) {
    setState(() => _currentHoleIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Live Scorecard',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.lg),
            _HoleSelector(
              holes: _holes,
              currentIndex: _currentHoleIndex,
              onSelect: _goToHole,
            ),
            SizedBox(height: spacing.sectionGap),
            HoleHeader(hole: _currentHole),
            SizedBox(height: spacing.sectionGap),
            ScoreStepper(
              score: _currentHole.grossScore,
              onIncrement: _incrementScore,
              onDecrement: _currentHole.grossScore > 1 ? _decrementScore : null,
            ),
            SizedBox(height: spacing.sectionGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddySecondaryButton(
                    label: 'Previous Hole',
                    onPressed: _currentHoleIndex > 0
                        ? () => _goToHole(_currentHoleIndex - 1)
                        : null,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: QaddyPrimaryButton(
                    label: 'Next Hole',
                    onPressed: _currentHoleIndex < _holes.length - 1
                        ? () => _goToHole(_currentHoleIndex + 1)
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sectionGap),
            RunningTotalsCard(holes: _holes),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// A horizontal, scrollable strip of 18 numbered hole buttons — lets a
/// player jump directly to any hole while keeping the current one obvious.
class _HoleSelector extends StatelessWidget {
  const _HoleSelector({
    required this.holes,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<HoleScore> holes;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return SizedBox(
      height: spacing.iconButtonSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: holes.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final isSelected = index == currentIndex;
          final background = isSelected ? colours.primary : colours.surface1;
          final foreground = isSelected
              ? theme.colorScheme.onPrimary
              : colours.textPrimary;

          return Semantics(
            button: true,
            label: 'Jump to hole ${holes[index].holeNumber}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(index),
                customBorder: const CircleBorder(),
                child: Container(
                  width: spacing.iconButtonSize,
                  height: spacing.iconButtonSize,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${holes[index].holeNumber}',
                    style: typography.small.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
