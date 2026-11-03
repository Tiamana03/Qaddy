/// Everything Qaddy keeps on this phone, and a way to clear it.
///
/// Screens never touch storage themselves; Settings uses this to say what is
/// kept and to start over. `main` overrides it with `shared_preferences`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What is kept on the device.
// An interface so tests can substitute an in-memory one.
// ignore: one_member_abstracts
abstract class LocalData {
  /// Removes everything Qaddy has saved on this device.
  Future<void> clear();
}

/// Keeps nothing, clears nothing. The default, for tests and previews.
class NoLocalData implements LocalData {
  const NoLocalData();

  @override
  Future<void> clear() async {}
}

/// Clears every `qaddy.` entry in `shared_preferences`.
class SharedPreferencesLocalData implements LocalData {
  const SharedPreferencesLocalData(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<void> clear() async {
    for (final key in _preferences.getKeys().toList()) {
      if (key.startsWith('qaddy.')) {
        await _preferences.remove(key);
      }
    }
  }
}

/// What is kept on the device. `main` overrides it.
final localDataProvider = Provider<LocalData>((ref) => const NoLocalData());
