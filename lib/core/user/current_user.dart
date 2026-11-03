/// Who the golfer is, as the rest of the app needs to know it.
///
/// Release 1 has no accounts. Until the golfer says who they are the app uses
/// the shared placeholder golfer (Tiamana, see `docs/standards/placeholder-data.md`);
/// once they have, [useGolfer] is called — at start-up from what is kept on the
/// phone, or the moment they finish setting up — and the seeded world (the
/// upcoming round, the groups, the trips) is built around *them*: every
/// scorecard, table and message says their name. See
/// `docs/features/identity.md`.
///
/// This is deliberately set once, before the seeded data is first read. A
/// golfer keeps the name they chose for as long as Qaddy holds their rounds
/// (their rounds and trips are recorded under it); "Start over" in Settings
/// begins again.
library;

import 'package:flutter/foundation.dart';
import 'package:qaddy/core/user/golfer.dart';

const String _placeholderName = 'Tiamana';
const double _placeholderHandicap = 8.4;

String _id = _placeholderName;
String _display = _placeholderName;
double? _handicap = _placeholderHandicap;
String? _homeCourse;

/// Seeded friends whose names a golfer might share. The golfer's id is made
/// different from theirs so the two never collide in a scorecard or a table.
/// (A test checks this list against the seeded friends.)
const Set<String> reservedGolferNames = <String>{
  'tom',
  'ben',
  'luke',
  'josh',
  'nick',
  'sam',
  'liam',
  'jack',
};

/// The id the golfer goes by inside the app's data. Compare with it; to show
/// the golfer's name to them it is the same text (an invisible mark is added
/// only when their name matches a seeded friend's).
String get currentUserName => _id;

/// The golfer's name as written, for places that must not carry the invisible
/// mark (the profile card, settings).
String get currentUserDisplayName => _display;

/// The golfer's handicap index, if they gave one.
double? get currentUserHandicap => _handicap;

/// The golfer's home course, if they said.
String? get currentUserHomeCourse => _homeCourse;

/// The id for a golfer called [firstName]: the name itself, unless that would
/// collide with a seeded friend, in which case an invisible zero-width space is
/// added so the two stay distinct and the name still reads the same.
String golferIdFor(String firstName) {
  final name = firstName.trim();
  return reservedGolferNames.contains(name.toLowerCase())
      ? '$name$_invisibleMark'
      : name;
}

/// Tells the app who the golfer is (or, with `null`, goes back to the
/// placeholder golfer). Call before the seeded data is first read.
void useGolfer(GolferProfile? golfer) {
  if (golfer == null) {
    _id = _placeholderName;
    _display = _placeholderName;
    _handicap = _placeholderHandicap;
    _homeCourse = null;
    return;
  }
  _id = golferIdFor(golfer.firstName);
  _display = golfer.firstName.trim();
  _handicap = golfer.handicap;
  _homeCourse = golfer.homeCourse;
}

/// Puts the placeholder golfer back. For tests.
@visibleForTesting
void resetGolferForTests() => useGolfer(null);

/// A zero-width space: it takes no room and prints nothing, but makes two
/// otherwise identical names different.
final String _invisibleMark = String.fromCharCode(0x200B);
