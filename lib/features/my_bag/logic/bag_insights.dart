/// What the bag says about itself: the order of the clubs by distance, the
/// gaps between them, the go-to club and a sentence about the lot.
///
/// Pure functions, so every rule is tested without a screen.
library;

import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// How a gap between two neighbouring clubs reads.
enum GapKind {
  /// Close enough that one club always has the shot covered.
  tight,

  /// Getting wide: worth keeping an eye on.
  watch,

  /// A hole in the bag: a distance no club covers.
  hole,
}

/// The widest gap that still counts as [GapKind.tight], in metres.
const double tightGapMetres = 18;

/// The widest gap that is only [GapKind.watch], in metres.
const double watchGapMetres = 25;

/// Classifies a gap of [metres].
GapKind gapKind(double metres) {
  if (metres <= tightGapMetres) {
    return GapKind.tight;
  }
  return metres <= watchGapMetres ? GapKind.watch : GapKind.hole;
}

/// The distance between two clubs that are neighbours by carry.
class ClubGap {
  const ClubGap({required this.longer, required this.shorter});

  /// The longer club.
  final BagClub longer;

  /// The next club down.
  final BagClub shorter;

  /// The gap, in metres.
  double get metres => longer.carryMetres! - shorter.carryMetres!;

  /// How the gap reads.
  GapKind get kind => gapKind(metres);
}

/// The clubs that have a carry, longest first. Equal carries keep the order
/// they were given in.
List<BagClub> carryClubs(List<BagClub> clubs) {
  final indexed =
      <(int, BagClub)>[
        for (final (index, club) in clubs.indexed)
          if (club.hasCarry) (index, club),
      ]..sort((a, b) {
        final byCarry = b.$2.carryMetres!.compareTo(a.$2.carryMetres!);
        return byCarry != 0 ? byCarry : a.$1.compareTo(b.$1);
      });
  return <BagClub>[for (final entry in indexed) entry.$2];
}

/// The gap between each club and the next one down.
List<ClubGap> gapsOf(List<BagClub> clubs) {
  final ordered = carryClubs(clubs);
  return <ClubGap>[
    for (var i = 0; i < ordered.length - 1; i++)
      ClubGap(longer: ordered[i], shorter: ordered[i + 1]),
  ];
}

/// The widest gap in the bag, or `null` with fewer than two clubs to compare.
/// The first of equally wide gaps (the longer end of the bag) wins.
ClubGap? widestGap(List<BagClub> clubs) {
  ClubGap? widest;
  for (final gap in gapsOf(clubs)) {
    if (widest == null || gap.metres > widest.metres) {
      widest = gap;
    }
  }
  return widest;
}

/// How many clubs are in the bag (the ball is not a club).
int clubCount(List<BagClub> clubs) =>
    clubs.where((club) => club.family != ClubFamily.ball).length;

/// The club that goes furthest, or `null` if none has a carry.
BagClub? longestClub(List<BagClub> clubs) {
  final ordered = carryClubs(clubs);
  return ordered.isEmpty ? null : ordered.first;
}

/// The club the golfer trusts most: the highest confidence (the first of any
/// tie, in bag order). `null` until they have rated one.
BagClub? goToClub(List<BagClub> clubs) {
  BagClub? best;
  for (final club in clubs) {
    if (club.family == ClubFamily.ball || club.confidence == 0) {
      continue;
    }
    if (best == null || club.confidence > best.confidence) {
      best = club;
    }
  }
  return best;
}

/// One sentence about the bag's gapping, in a golfer's words.
String gappingStory(List<BagClub> clubs) {
  final gap = widestGap(clubs);
  if (gap == null) {
    return 'Set a carry for a couple of clubs and your gapping appears here.';
  }
  final metres = formatDistance(gap.metres);
  return switch (gap.kind) {
    GapKind.hole =>
      'A $metres hole between your ${gap.longer.name} and '
          '${gap.shorter.name}: worth a look.',
    GapKind.watch =>
      'Nicely spread. Keep an eye on the $metres gap between your '
          '${gap.longer.name} and ${gap.shorter.name}.',
    GapKind.tight =>
      'Beautifully gapped: every club is within $metres of the next.',
  };
}

/// The words for a confidence rating (1–5).
String confidenceLabel(int confidence) => switch (confidence) {
  1 => 'Shaky',
  2 => 'Getting there',
  3 => 'Reliable',
  4 => 'Confident',
  5 => 'Go-to',
  _ => 'Not rated',
};
