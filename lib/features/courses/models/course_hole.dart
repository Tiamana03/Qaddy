/// One hole of a course: what a golfer needs to know standing on the tee.
library;

import 'package:flutter/foundation.dart' show immutable;

/// A hole's number, par, difficulty ranking and length.
@immutable
class CourseHole {
  const CourseHole({
    required this.number,
    required this.par,
    required this.strokeIndex,
    this.metres,
  });

  /// The hole number (1–18).
  final int number;

  /// Par (3, 4 or 5).
  final int par;

  /// The difficulty ranking (1 is the hardest hole). Handicap shots are given
  /// on the lowest stroke indexes first.
  final int strokeIndex;

  /// The length, in metres, or `null` when it is not known (a golfer's own
  /// course has no distances until course search arrives).
  final int? metres;

  @override
  bool operator ==(Object other) =>
      other is CourseHole &&
      other.number == number &&
      other.par == par &&
      other.strokeIndex == strokeIndex &&
      other.metres == metres;

  @override
  int get hashCode => Object.hash(number, par, strokeIndex, metres);
}
