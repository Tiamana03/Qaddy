/// Which theme the golfer wants: follow the phone, or always light or dark.
///
/// Kept on the device (see `DocumentStorage`) and applied by `QaddyApp`. The
/// launch screens ignore it on purpose and always use the dark brand stage.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/document_storage.dart';

/// The key the choice is kept under.
const String themeStorageKey = 'qaddy.theme.v1';

/// The choice's storage. `main` overrides it with on-device storage.
final themeStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// The golfer's theme choice. Follows the phone until they decide otherwise.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

/// Changes the theme choice.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.read(themeStorageProvider);
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(
        storage.write(
          jsonEncode(<String, Object?>{'version': 1, 'mode': next.name}),
        ),
      );
    });

    final stored = storage.read();
    if (stored == null) {
      return ThemeMode.system;
    }
    try {
      final json = jsonDecode(stored);
      final name = json is Map<String, dynamic> ? json['mode'] : null;
      return ThemeMode.values.firstWhere(
        (mode) => mode.name == name,
        orElse: () => ThemeMode.system,
      );
    } on FormatException {
      return ThemeMode.system;
    }
  }

  /// Chooses [mode].
  // ignore: use_setters_to_change_properties
  void choose(ThemeMode mode) => state = mode;
}

/// A short name for [mode], as Settings shows it.
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Auto',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};
