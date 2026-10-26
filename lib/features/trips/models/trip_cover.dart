/// The cover presets a trip can choose from.
///
/// Release 1 has no image upload or storage, so a "cover image" is one of a
/// handful of designed placeholders (a coloured gradient and an icon). The
/// choice is stored on `Trip.coverImage` as the preset's `id`; the colours
/// live in `ui/widgets/trip_cover_tile.dart` because they come from the
/// theme.
library;

import 'package:flutter/material.dart';

/// One selectable cover.
class TripCoverPreset {
  const TripCoverPreset({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// Stable key stored on the trip.
  final String id;

  /// Display name.
  final String label;

  /// The icon drawn on the cover.
  final IconData icon;
}

/// Every cover preset, in picker order. The first is the default.
const List<TripCoverPreset> tripCoverPresets = <TripCoverPreset>[
  TripCoverPreset(id: 'fairway', label: 'Fairway', icon: Icons.sports_golf),
  TripCoverPreset(
    id: 'coast',
    label: 'Coast',
    icon: Icons.beach_access_outlined,
  ),
  TripCoverPreset(
    id: 'sunset',
    label: 'Sunset',
    icon: Icons.wb_twilight_outlined,
  ),
  TripCoverPreset(
    id: 'city',
    label: 'City',
    icon: Icons.location_city_outlined,
  ),
  TripCoverPreset(id: 'highlands', label: 'Highlands', icon: Icons.terrain),
  TripCoverPreset(id: 'links', label: 'Links', icon: Icons.flag_outlined),
];

/// The preset for [id], or the default when [id] is `null` or unknown.
TripCoverPreset tripCoverFor(String? id) => tripCoverPresets.firstWhere(
  (preset) => preset.id == id,
  orElse: () => tripCoverPresets.first,
);
