/// Starts a test with the Sample Clubhouse already switched off, the way a
/// golfer who chose to start empty has it. Goes through the real choice (the
/// sample provider's storage), so everything that watches it agrees.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';

class _OffStorage implements DocumentStorage {
  @override
  String? read() =>
      encodeSampleChoice(const SampleChoice(enabled: false, decided: true));

  @override
  Future<void> write(String document) async {}
}

/// Overrides that start the app with the sample off. Also puts the global
/// switch back when the test ends.
List<Override> sampleOff() {
  addTearDown(resetSampleClubhouseForTests);
  return <Override>[sampleStorageProvider.overrideWithValue(_OffStorage())];
}
