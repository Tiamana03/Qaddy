/// The store behind Golf Bag.
///
/// The bag lives on the device: the store loads the golfer's edits when the
/// app starts and saves after every change (see `DocumentStorage`). Screens
/// read through [bagProvider] and change a club only through [BagController].
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/features/my_bag/models/bag_club.dart';
import 'package:qaddy/features/my_bag/models/placeholder_my_bag.dart';
import 'package:qaddy/features/my_bag/repositories/bag_codec.dart';

/// The bag's storage. `main` overrides it with on-device storage.
final bagStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// The golfer's bag.
final bagProvider = NotifierProvider<BagController, List<BagClub>>(
  BagController.new,
);

/// The shortest carry a golfer can set, in metres.
const double minCarryMetres = 20;

/// The longest carry a golfer can set, in metres.
const double maxCarryMetres = 350;

/// The longest note a club can carry.
const int maxNoteLength = 160;

/// Changes clubs in the bag.
class BagController extends Notifier<List<BagClub>> {
  @override
  List<BagClub> build() {
    final storage = ref.read(bagStorageProvider);
    // Save after every change from here on (the starting state is not one).
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(storage.write(encodeBag(next)));
    });

    final stored = storage.read();
    return (stored == null ? null : decodeBag(stored, seedBagClubs)) ??
        List<BagClub>.of(seedBagClubs);
  }

  /// Updates the club with [id]. Only what is given changes; a carry is kept
  /// within a believable range, a confidence within 0–5 and a note to
  /// [maxNoteLength] characters.
  void update(
    String id, {
    String? model,
    double? carryMetres,
    String? note,
    int? confidence,
  }) {
    state = <BagClub>[
      for (final club in state)
        if (club.id == id)
          club.copyWith(
            model: model == null || model.trim().isEmpty ? null : model.trim(),
            carryMetres: club.family.hasCarry && carryMetres != null
                ? carryMetres.clamp(minCarryMetres, maxCarryMetres)
                : null,
            note: note == null
                ? null
                : note.trim().length > maxNoteLength
                ? note.trim().substring(0, maxNoteLength)
                : note.trim(),
            confidence: confidence?.clamp(0, 5),
          )
        else
          club,
    ];
  }
}
