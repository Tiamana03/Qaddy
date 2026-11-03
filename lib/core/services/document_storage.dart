/// Where a feature keeps one small JSON document on the device.
///
/// Features read the document once at start-up and write it after every
/// change; screens never touch storage themselves. Trips and Rounds have their
/// own near-identical copies of this (see `docs/reviews/technical-debt.md`'s
/// TD-017); new features use this one.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// A place to keep one document.
// An interface (not a function pair) so tests can substitute an in-memory one.
// ignore: one_member_abstracts
abstract class DocumentStorage {
  /// The stored document, or `null` when nothing has been saved yet.
  String? read();

  /// Saves [document], replacing what was there. Failures are swallowed: a
  /// change that could not be saved is better than a crash mid-edit.
  Future<void> write(String document);
}

/// Keeps nothing. The default, so tests and previews start fresh every time.
class NoDocumentStorage implements DocumentStorage {
  const NoDocumentStorage();

  @override
  String? read() => null;

  @override
  Future<void> write(String document) async {}
}

/// Keeps the document in `shared_preferences` under [key].
class SharedPreferencesDocumentStorage implements DocumentStorage {
  const SharedPreferencesDocumentStorage(this._preferences, this.key);

  /// The preference key the document lives under.
  final String key;

  final SharedPreferences _preferences;

  @override
  String? read() => _preferences.getString(key);

  @override
  Future<void> write(String document) async {
    try {
      await _preferences.setString(key, document);
    } on Object {
      // See [DocumentStorage.write].
    }
  }
}
