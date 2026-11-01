/// Turns the rounds store into JSON and back.
///
/// Versioned (`version`). A document this app cannot understand decodes to
/// `null` and the app starts with no round rather than crashing on launch.
library;

import 'dart:convert';

import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

/// The current document format.
const int roundsDocumentVersion = 1;

/// The round being played and the last finished one, as stored.
class StoredRounds {
  const StoredRounds({this.live, this.completed});

  /// The round in progress, if any.
  final Round? live;

  /// The last finished round, if any.
  final Round? completed;
}

/// Encodes the two rounds as a JSON document.
String encodeRounds({Round? live, Round? completed}) {
  return jsonEncode(<String, Object?>{
    'version': roundsDocumentVersion,
    'live': live == null ? null : _round(live),
    'completed': completed == null ? null : _round(completed),
  });
}

/// Decodes a document written by [encodeRounds], or `null` if this app cannot
/// read it.
StoredRounds? decodeRounds(String source) {
  try {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic> ||
        root['version'] != roundsDocumentVersion) {
      return null;
    }
    final live = root['live'];
    final completed = root['completed'];
    return StoredRounds(
      live: live is Map<String, dynamic> ? _decodeRound(live) : null,
      completed: completed is Map<String, dynamic>
          ? _decodeRound(completed)
          : null,
    );
  } on Object {
    return null;
  }
}

Map<String, Object?> _round(Round round) => <String, Object?>{
  'id': round.id,
  'course': round.course,
  'format': round.format,
  'players': <Object?>[
    for (final player in round.players)
      <String, Object?>{'name': player.name, 'handicap': player.handicap},
  ],
  'scores': <String, Object?>{
    for (final entry in round.scores.entries) entry.key: entry.value,
  },
  'currentHole': round.currentHole,
  'status': round.status.name,
  'startedAt': round.startedAt.toIso8601String(),
  'completedAt': round.completedAt?.toIso8601String(),
};

Round _decodeRound(Map<String, dynamic> json) {
  final course = json['course'] as String;
  // Release 1 has one course; a round on any other is not understood.
  if (course != upcomingRound.course) {
    throw const FormatException('Unknown course');
  }
  final players = <RoundPlayer>[
    for (final p in json['players'] as List<dynamic>)
      RoundPlayer(
        name: (p as Map<String, dynamic>)['name'] as String,
        handicap: (p['handicap'] as num).toDouble(),
      ),
  ];
  final scores = <String, List<int?>>{
    for (final entry in (json['scores'] as Map<String, dynamic>).entries)
      entry.key: <int?>[
        for (final value in entry.value as List<dynamic>) value as int?,
      ],
  };
  final completedAt = json['completedAt'] as String?;
  return Round(
    id: json['id'] as String,
    course: course,
    format: json['format'] as String,
    holes: richmondHoles,
    players: players,
    scores: scores,
    currentHole: (json['currentHole'] as int).clamp(
      0,
      richmondHoles.length - 1,
    ),
    status: RoundStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => RoundStatus.inProgress,
    ),
    startedAt: DateTime.parse(json['startedAt'] as String),
    completedAt: completedAt == null ? null : DateTime.parse(completedAt),
  );
}
