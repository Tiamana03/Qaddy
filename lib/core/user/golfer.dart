/// The golfer using this copy of Qaddy: a first name and, if they wish, a
/// handicap and a home course — kept on the device.
///
/// Release 1 has no accounts, so this is a lightweight guest profile. It is the
/// one place the golfer's own details live; screens read it rather than the old
/// placeholder profile. See `docs/features/identity.md`.
library;

import 'dart:convert';

/// The lowest handicap index accepted (a "plus" handicap).
const double minHandicap = -10;

/// The highest handicap index accepted.
const double maxHandicap = 54;

/// The longest name or course the profile keeps.
const int maxProfileTextLength = 40;

/// A golfer's own details.
class GolferProfile {
  const GolferProfile({
    required this.firstName,
    required this.joinedAt,
    this.handicap,
    this.homeCourse,
  });

  /// What the app calls the golfer.
  final String firstName;

  /// Their handicap index, when they have one to give.
  final double? handicap;

  /// Where they usually play, when they said.
  final String? homeCourse;

  /// When the golfer set Qaddy up.
  final DateTime joinedAt;
}

/// "Add your name" — or `null` when [value] is a fine first name.
String? validateFirstName(String value) {
  final name = value.trim();
  if (name.isEmpty) {
    return 'What should we call you?';
  }
  return name.length > maxProfileTextLength ? 'That is a long name' : null;
}

/// A handicap is optional; when given it must be a number in range.
String? validateHandicapText(String value) {
  final text = value.trim();
  if (text.isEmpty) {
    return null;
  }
  final parsed = parseHandicap(text);
  if (parsed == null) {
    return 'Enter a number like 12 or 8.4';
  }
  if (parsed < minHandicap || parsed > maxHandicap) {
    final from = minHandicap.round();
    final to = maxHandicap.round();
    return 'Handicaps run from $from to $to';
  }
  return null;
}

/// Reads a handicap as typed ("8.4", "8,4", "+2" meaning plus two, which is
/// below scratch and so stored as -2); `null` if it is not a number.
double? parseHandicap(String text) {
  var value = text.trim().replaceAll(',', '.');
  if (value.isEmpty) {
    return null;
  }
  var plus = false;
  if (value.startsWith('+')) {
    plus = true;
    value = value.substring(1);
  }
  final parsed = double.tryParse(value);
  if (parsed == null) {
    return null;
  }
  return plus ? -parsed : parsed;
}

/// The profile as the JSON document kept on the device.
String encodeGolfer(GolferProfile golfer) => jsonEncode(<String, Object?>{
  'version': 1,
  'firstName': golfer.firstName,
  'handicap': golfer.handicap,
  'homeCourse': golfer.homeCourse,
  'joinedAt': golfer.joinedAt.toIso8601String(),
});

/// Reads a document written by [encodeGolfer]; `null` when it cannot be read,
/// so the golfer is simply asked again.
GolferProfile? decodeGolfer(String document) {
  try {
    final json = jsonDecode(document);
    if (json is! Map<String, dynamic>) {
      return null;
    }
    final name = json['firstName'];
    final joined = DateTime.tryParse('${json['joinedAt']}');
    if (name is! String || name.trim().isEmpty || joined == null) {
      return null;
    }
    final handicap = json['handicap'];
    final course = json['homeCourse'];
    return GolferProfile(
      firstName: name,
      handicap: handicap is num ? handicap.toDouble() : null,
      homeCourse: course is String && course.trim().isNotEmpty ? course : null,
      joinedAt: joined,
    );
  } on FormatException {
    return null;
  }
}
