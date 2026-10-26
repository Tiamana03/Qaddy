/// Trip cover placeholders: a themed gradient and an icon.
///
/// Release 1 has no image upload, so each [TripCoverPreset] is rendered as a
/// designed placeholder. The gradient is derived from a theme accent blended
/// towards the app background, which keeps white text readable on every
/// preset (the hero card draws its text straight over this gradient).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/features/trips/models/trip_cover.dart';

/// The gradient for the cover preset with the given [id] (the default preset
/// for `null` or an unknown id).
Gradient tripCoverGradient(QaddyColours colours, String? id) {
  final preset = tripCoverFor(id);
  if (preset.id == tripCoverPresets.first.id) {
    return colours.gradientGreen;
  }
  final accent = switch (preset.id) {
    'coast' => colours.accentSky,
    'sunset' => colours.accentOrange,
    'city' => colours.accentIndigo,
    'highlands' => colours.accentTeal,
    _ => colours.gold,
  };
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color.lerp(accent, colours.backgroundBase, 0.30)!,
      Color.lerp(accent, colours.backgroundBase, 0.70)!,
    ],
  );
}

/// A square cover thumbnail for [presetId].
class TripCoverTile extends StatelessWidget {
  const TripCoverTile({
    required this.presetId,
    this.size,
    this.selected = false,
    super.key,
  });

  /// Which preset to draw.
  final String? presetId;

  /// Edge length; defaults to `spacing.hero`.
  final double? size;

  /// Whether to draw the "chosen" ring.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final edge = size ?? spacing.hero;
    final preset = tripCoverFor(presetId);

    return Container(
      width: edge,
      height: edge,
      decoration: BoxDecoration(
        gradient: tripCoverGradient(colours, presetId),
        borderRadius: BorderRadius.circular(radius.medium),
        border: selected ? Border.all(color: colours.accent, width: 2) : null,
      ),
      child: Icon(
        preset.icon,
        size: edge * 0.45,
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
      ),
    );
  }
}

/// A row of selectable cover thumbnails.
class TripCoverPicker extends StatelessWidget {
  const TripCoverPicker({
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  /// The chosen preset id (`null` selects the default).
  final String? selectedId;

  /// Called with the preset the user taps.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final current = tripCoverFor(selectedId).id;

    return SizedBox(
      height: spacing.hero + spacing.sm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tripCoverPresets.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing.md),
        itemBuilder: (context, index) {
          final preset = tripCoverPresets[index];
          return Semantics(
            button: true,
            selected: preset.id == current,
            label: '${preset.label} cover',
            excludeSemantics: true,
            onTap: () => onChanged(preset.id),
            child: GestureDetector(
              onTap: () => onChanged(preset.id),
              child: Padding(
                padding: EdgeInsets.all(spacing.xs),
                child: TripCoverTile(
                  presetId: preset.id,
                  selected: preset.id == current,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
