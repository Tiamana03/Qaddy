/// Pick a score in golf's own words: Eagle, Birdie, Par, Bogey, Double bogey —
/// or pick up. One tap instead of counting strokes up or down.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';

/// Opens the picker for [name] on a hole of [par] where they are given
/// [shots]. Resolves to the strokes chosen (0 = picked up), or `null` if the
/// sheet was dismissed.
Future<int?> showScorePicker(
  BuildContext context, {
  required String name,
  required int holeNumber,
  required int par,
  required int shots,
  required int current,
}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (sheetContext) => ScorePickerSheet(
      name: name,
      holeNumber: holeNumber,
      par: par,
      shots: shots,
      current: current,
    ),
  );
}

/// The content of the score picker.
class ScorePickerSheet extends StatelessWidget {
  const ScorePickerSheet({
    required this.name,
    required this.holeNumber,
    required this.par,
    required this.shots,
    required this.current,
    super.key,
  });

  /// Whose score it is.
  final String name;

  /// The hole being scored.
  final int holeNumber;

  /// The hole's par.
  final int par;

  /// The shots this golfer is given on the hole.
  final int shots;

  /// The score now (0 = picked up).
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    // Eagle down to double bogey, never below a hole in one.
    final options = <int>[
      for (var gross = par - 2; gross <= par + 2; gross++)
        if (gross >= 1) gross,
      0,
    ];

    Widget option(int gross) {
      final selected = gross == current;
      final label = scoreLabel(gross, par);
      final points = stablefordPoints(gross: gross, par: par, shots: shots);
      final celebrate = gross > 0 && isCelebration(gross, par);
      final accent = celebrate ? colours.gold : colours.textPrimary;

      return Semantics(
        button: true,
        selected: selected,
        label:
            '$label, ${gross == 0 ? 'no score' : '$gross strokes'}, '
            '$points points',
        excludeSemantics: true,
        child: Material(
          color: selected ? colours.surface2 : colours.card,
          borderRadius: BorderRadius.circular(radius.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              QaddyHaptics.selection();
              Navigator.of(context).pop(gross);
            },
            child: Container(
              width: 104,
              padding: EdgeInsets.symmetric(
                vertical: spacing.md,
                horizontal: spacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius.large),
                border: Border.all(
                  color: selected ? colours.gold : colours.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    gross == 0 ? '–' : '$gross',
                    style: typography.display.copyWith(
                      color: accent,
                      fontSize: 32,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: typography.small.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$points pt${points == 1 ? '' : 's'}',
                    style: typography.caption.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.pagePadding,
          0,
          spacing.pagePadding,
          spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              name,
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Hole $holeNumber · Par $par'
              '${shots > 0 ? ' · +$shots shot${shots == 1 ? '' : 's'}' : ''}',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing.cardGap,
              runSpacing: spacing.cardGap,
              children: <Widget>[for (final gross in options) option(gross)],
            ),
          ],
        ),
      ),
    );
  }
}
