/// Tune one club: the model, how far it carries (with a live look at the gaps
/// either side), how much you trust it and a note to self.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/features/my_bag/logic/bag_insights.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/state/bag_controller.dart';
import 'package:qaddy/features/my_bag/ui/widgets/distance_ladder.dart';

/// Opens the sheet for the club with [clubId].
Future<void> showClubSheet(BuildContext context, String clubId) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (context) => ClubSheet(clubId: clubId),
  );
}

/// The content of the club sheet.
class ClubSheet extends ConsumerStatefulWidget {
  const ClubSheet({required this.clubId, super.key});

  /// Which club is being tuned.
  final String clubId;

  @override
  ConsumerState<ClubSheet> createState() => _ClubSheetState();
}

class _ClubSheetState extends ConsumerState<ClubSheet> {
  late final BagClub _original = ref
      .read(bagProvider)
      .firstWhere((club) => club.id == widget.clubId);
  late final TextEditingController _model = TextEditingController(
    text: _original.model,
  );
  late final TextEditingController _note = TextEditingController(
    text: _original.note,
  );
  late double _carry = _original.carryMetres ?? 0;
  late int _confidence = _original.confidence;

  @override
  void dispose() {
    _model.dispose();
    _note.dispose();
    super.dispose();
  }

  void _nudge(double delta) {
    QaddyHaptics.selection();
    setState(
      () => _carry = (_carry + delta).clamp(minCarryMetres, maxCarryMetres),
    );
  }

  void _save() {
    QaddyHaptics.success();
    ref
        .read(bagProvider.notifier)
        .update(
          _original.id,
          model: _model.text,
          carryMetres: _original.family.hasCarry ? _carry : null,
          note: _note.text,
          confidence: _confidence,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final bag = ref.watch(bagProvider);
    final hasCarry = _original.family.hasCarry;

    // The bag as it would be with this carry, to show the gaps either side.
    final preview = <BagClub>[
      for (final club in bag)
        club.id == _original.id ? club.copyWith(carryMetres: _carry) : club,
    ];
    final ordered = carryClubs(preview);
    final index = ordered.indexWhere((club) => club.id == _original.id);
    final above = hasCarry && index > 0 ? ordered[index - 1] : null;
    final below = hasCarry && index >= 0 && index < ordered.length - 1
        ? ordered[index + 1]
        : null;

    Widget gapLine(String text, double metres) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: gapColour(colours, gapKind(metres)),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: spacing.sm),
        Flexible(
          child: Text(
            text,
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
        ),
      ],
    );

    Widget stepper(String label, double delta) => OutlinedButton(
      onPressed: () => _nudge(delta),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(52, 48),
        padding: EdgeInsets.zero,
        side: BorderSide(color: colours.border),
        foregroundColor: colours.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.medium),
        ),
      ),
      child: Semantics(
        label: delta > 0
            ? 'Add ${delta.abs().round()} metres'
            : 'Take ${delta.abs().round()} metres off',
        excludeSemantics: true,
        child: Text(label),
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.pagePadding,
          0,
          spacing.pagePadding,
          spacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _original.name,
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.lg),
            TextField(
              controller: _model,
              textCapitalization: TextCapitalization.words,
              style: typography.body.copyWith(color: colours.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'The one you play',
              ),
            ),
            if (hasCarry) ...<Widget>[
              SizedBox(height: spacing.xl),
              Text(
                'How far it carries',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: <Widget>[
                  stepper('−5', -5),
                  SizedBox(width: spacing.sm),
                  stepper('−1', -1),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      label: '${_carry.round()} metres',
                      excludeSemantics: true,
                      child: Center(
                        child: Text(
                          formatDistance(_carry),
                          style: typography.display.copyWith(
                            color: colours.textPrimary,
                            fontSize: 40,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  stepper('+1', 1),
                  SizedBox(width: spacing.sm),
                  stepper('+5', 5),
                ],
              ),
              SizedBox(height: spacing.md),
              if (above != null)
                gapLine(
                  '${formatDistance(above.carryMetres! - _carry)} '
                  'shorter than your ${above.name}',
                  above.carryMetres! - _carry,
                ),
              if (below != null) ...<Widget>[
                SizedBox(height: spacing.xs),
                gapLine(
                  '${formatDistance(_carry - below.carryMetres!)} '
                  'longer than your ${below.name}',
                  _carry - below.carryMetres!,
                ),
              ],
            ],
            SizedBox(height: spacing.xl),
            Text(
              'How much do you trust it?',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.sm),
            Row(
              children: <Widget>[
                for (var i = 1; i <= 5; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: _confidence == i,
                      label: '$i of 5, ${confidenceLabel(i)}',
                      excludeSemantics: true,
                      child: InkResponse(
                        onTap: () {
                          QaddyHaptics.selection();
                          // Tapping the current rating again clears it.
                          setState(
                            () => _confidence = _confidence == i ? 0 : i,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(spacing.xs),
                          child: AnimatedContainer(
                            duration: QaddyMotion.standard.fast,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= _confidence
                                  ? colours.gold
                                  : colours.surface2,
                              border: Border.all(
                                color: i <= _confidence
                                    ? colours.gold
                                    : colours.border,
                              ),
                            ),
                            child: Text(
                              '$i',
                              style: typography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: i <= _confidence
                                    ? colours.backgroundBase
                                    : colours.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: spacing.xs),
            Center(
              child: Text(
                confidenceLabel(_confidence),
                style: typography.small.copyWith(
                  color: _confidence == 0 ? colours.textTertiary : colours.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            TextField(
              controller: _note,
              maxLength: maxNoteLength,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: typography.body.copyWith(color: colours.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Note to self',
                hintText: 'Plays a touch longer downhill…',
              ),
            ),
            SizedBox(height: spacing.lg),
            QaddyGoldButton(label: 'Save', tall: true, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
