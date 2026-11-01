/// Where the rounds document is kept between launches, so a round in progress
/// survives the app being closed in a pocket. Screens never touch this; they
/// change rounds through `RoundsController`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A place to keep the rounds document.
// An interface (not a function pair) so tests can substitute an in-memory one.
// ignore: one_member_abstracts
abstract class RoundsStorage {
  /// The stored document, or `null` when nothing has been saved yet.
  String? read();

  /// Saves [document], replacing what was there. Failures are swallowed: a
  /// score that could not be saved is better than a crash mid-round.
  Future<void> write(String document);
}

/// Keeps nothing. The default, so tests and previews start fresh every time.
class NoRoundsStorage implements RoundsStorage {
  const NoRoundsStorage();

  @override
  String? read() => null;

  @override
  Future<void> write(String document) async {}
}

/// Keeps the document in `shared_preferences`.
class SharedPreferencesRoundsStorage implements RoundsStorage {
  const SharedPreferencesRoundsStorage(this._preferences);

  /// The preference key the document lives under.
  static const String key = 'qaddy.rounds.v1';

  final SharedPreferences _preferences;

  @override
  String? read() => _preferences.getString(key);

  @override
  Future<void> write(String document) async {
    try {
      await _preferences.setString(key, document);
    } on Object {
      // See [RoundsStorage.write].
    }
  }
}

/// The app's rounds storage. `main` overrides it with on-device storage.
final roundsStorageProvider = Provider<RoundsStorage>(
  (ref) => const NoRoundsStorage(),
);
