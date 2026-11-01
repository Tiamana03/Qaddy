/// Where the trips document is kept between launches.
///
/// The store reads it once at start-up and writes it after every change.
/// Screens never touch this; they change trips through `TripsController`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A place to keep the trips document.
// An interface (not a function pair) so tests can substitute an in-memory one.
// ignore: one_member_abstracts
abstract class TripsStorage {
  /// The stored document, or `null` when nothing has been saved yet.
  String? read();

  /// Saves [document], replacing what was there. Failures are swallowed: a
  /// trip that could not be saved is better than a crash mid-edit.
  Future<void> write(String document);
}

/// Keeps nothing. The default, so tests and previews start from the seed
/// trips every time.
class NoTripsStorage implements TripsStorage {
  const NoTripsStorage();

  @override
  String? read() => null;

  @override
  Future<void> write(String document) async {}
}

/// Keeps the document in `shared_preferences` (on-device storage; browser
/// local storage on web).
class SharedPreferencesTripsStorage implements TripsStorage {
  const SharedPreferencesTripsStorage(this._preferences);

  /// The preference key the document lives under.
  static const String key = 'qaddy.trips.v1';

  final SharedPreferences _preferences;

  @override
  String? read() => _preferences.getString(key);

  @override
  Future<void> write(String document) async {
    try {
      await _preferences.setString(key, document);
    } on Object {
      // See [TripsStorage.write].
    }
  }
}

/// The app's trips storage. `main` overrides it with on-device storage.
final tripsStorageProvider = Provider<TripsStorage>(
  (ref) => const NoTripsStorage(),
);
