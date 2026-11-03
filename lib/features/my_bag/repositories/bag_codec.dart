/// Turns the golfer's edits to their bag into JSON and back.
///
/// Only what the golfer can change (model, carry, note, confidence) is stored,
/// keyed by club id, and laid over the bag as it starts. A club added to the
/// starting bag later therefore appears for everyone, and an unreadable
/// document simply means the bag starts as new.
library;

import 'dart:convert';

import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// The current document format.
const int bagDocumentVersion = 1;

/// Encodes the golfer's edits to [clubs] as a JSON document.
String encodeBag(List<BagClub> clubs) {
  return jsonEncode(<String, Object?>{
    'version': bagDocumentVersion,
    'clubs': <String, Object?>{
      for (final club in clubs)
        club.id: <String, Object?>{
          'model': club.model,
          'carry': club.carryMetres,
          'note': club.note,
          'confidence': club.confidence,
        },
    },
  });
}

/// Lays the edits in [source] over [seed], or returns `null` if [source] is
/// not a document this app can read.
List<BagClub>? decodeBag(String source, List<BagClub> seed) {
  try {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic> ||
        root['version'] != bagDocumentVersion) {
      return null;
    }
    final edits = root['clubs'] as Map<String, dynamic>;
    return <BagClub>[
      for (final club in seed)
        if (edits[club.id] case final Map<String, dynamic> edit)
          club.copyWith(
            model: edit['model'] as String?,
            carryMetres: (edit['carry'] as num?)?.toDouble(),
            note: edit['note'] as String?,
            confidence: ((edit['confidence'] as int?) ?? club.confidence).clamp(
              0,
              5,
            ),
          )
        else
          club,
    ];
  } on Object {
    return null;
  }
}
