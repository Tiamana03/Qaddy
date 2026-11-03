/// The Sample Clubhouse: the pretend mates, group, trip and season table Qaddy
/// comes with so a new golfer can see what it does.
///
/// It is **sample content, never the golfer's own**: everywhere it appears it
/// is labelled Sample, the app never presents Tom, Ben or the Saturday Boys as
/// real people the golfer made, and the golfer chooses on first launch whether
/// to have it. They can keep it, edit it (trips and rounds are theirs to
/// change) or remove it in Settings at any time. See
/// `docs/features/sample-clubhouse.md`.
///
/// Like the golfer's own identity, the choice is set once at start-up and when
/// it changes, and every seeded list reads it, so what is hidden is hidden
/// everywhere at once.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/document_storage.dart';

bool _on = true;

/// Whether the Sample Clubhouse is switched on. On by default (and in tests);
/// a golfer who chose to start empty has it off.
bool get sampleClubhouseOn => _on;

/// Switches the Sample Clubhouse on or off everywhere.
void useSampleClubhouse({required bool on}) => _on = on;

/// Puts the default back (on). For tests.
@visibleForTesting
void resetSampleClubhouseForTests() => _on = true;

/// The key the choice is kept under.
const String sampleStorageKey = 'qaddy.sample.v1';

/// The choice's storage. `main` overrides it with on-device storage.
final sampleStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// Whether the golfer wants the Sample Clubhouse, and whether they have been
/// asked yet.
class SampleChoice {
  const SampleChoice({this.enabled = true, this.decided = false});

  /// Whether the Sample Clubhouse is on.
  final bool enabled;

  /// Whether the golfer has made the choice (on first launch).
  final bool decided;
}

/// The golfer's choice about the Sample Clubhouse.
final sampleClubhouseProvider =
    NotifierProvider<SampleClubhouseController, SampleChoice>(
      SampleClubhouseController.new,
    );

/// Whether the Sample Clubhouse is on, for providers and widgets that should
/// react when it changes.
final sampleOnProvider = Provider<bool>(
  (ref) => ref.watch(sampleClubhouseProvider.select((c) => c.enabled)),
);

/// Changes the choice.
class SampleClubhouseController extends Notifier<SampleChoice> {
  @override
  SampleChoice build() {
    final storage = ref.read(sampleStorageProvider);
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(storage.write(encodeSampleChoice(next)));
    });

    final stored = storage.read();
    final choice =
        (stored == null ? null : decodeSampleChoice(stored)) ??
        const SampleChoice();
    useSampleClubhouse(on: choice.enabled);
    return choice;
  }

  /// Turns the Sample Clubhouse on or off, and records that the golfer chose.
  void choose({required bool enabled}) {
    useSampleClubhouse(on: enabled);
    state = SampleChoice(enabled: enabled, decided: true);
  }
}

/// The choice as the JSON document kept on the device.
String encodeSampleChoice(SampleChoice choice) => jsonEncode(<String, Object?>{
  'version': 1,
  'enabled': choice.enabled,
  'decided': choice.decided,
});

/// Reads a document written by [encodeSampleChoice]; `null` when it cannot be
/// read, so the golfer simply gets the default.
SampleChoice? decodeSampleChoice(String document) {
  try {
    final json = jsonDecode(document);
    if (json is! Map<String, dynamic>) {
      return null;
    }
    return SampleChoice(
      enabled: json['enabled'] != false,
      decided: json['decided'] == true,
    );
  } on FormatException {
    return null;
  }
}
