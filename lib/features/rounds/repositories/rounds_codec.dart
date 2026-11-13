/// Turns the rounds store into JSON and back.
///
/// Versioned (`version`). A document this app cannot understand decodes to
/// `null` and the app starts with no round rather than crashing on launch.
library;

import 'dart:convert';

import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

/// The current document format.
const int roundsDocumentVersion = 2;

/// The round being played and every finished one, as stored.
class StoredRounds {
  const StoredRounds({this.live, this.history = const <Round>[]});

  /// The round in progress, if any.
  final Round? live;

  /// Every finished round, newest first.
  final List<Round> history;
}

/// Encodes the live round and the history as a JSON document.
String encodeRounds({Round? live, List<Round> history = const <Round>[]}) {
  return jsonEncode(<String, Object?>{
    'version': roundsDocumentVersion,
    'live': live == null ? null : _round(live),
    'history': <Object?>[for (final round in history) _round(round)],
  });
}

/// Decodes a document written by [encodeRounds], or `null` if this app cannot
/// read it.
StoredRounds? decodeRounds(String source) {
  try {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic>) {
      return null;
    }
    final version = root['version'];
    if (version != roundsDocumentVersion && version != 1) {
      return null;
    }
    final live = root['live'];
    // Version 1 kept only the last finished round, under 'completed'.
    final stored = version == 1
        ? <Object?>[root['completed']]
        : (root['history'] as List<dynamic>? ?? const <dynamic>[]);
    return StoredRounds(
      live: live is Map<String, dynamic> ? _decodeRound(live) : null,
      history: <Round>[
        for (final json in stored)
          if (json is Map<String, dynamic>) _decodeRound(json),
      ],
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
  'courseId': round.courseId,
  // The holes are kept with the round, so it still reads right whatever the
  // course database says later.
  'holes': <Object?>[
    for (final hole in round.holes)
      <String, Object?>{
        'number': hole.number,
        'par': hole.par,
        'strokeIndex': hole.strokeIndex,
        'metres': hole.metres,
      },
  ],
};

Round _decodeRound(Map<String, dynamic> json) {
  // A round keeps the course it was played on, whatever the golfer's home
  // course or Sample Clubhouse choice is now.
  final course = json['course'] as String;
  final stored = json['holes'];
  final holes = stored is List<dynamic>
      ? <CourseHole>[
          for (final h in stored)
            CourseHole(
              number: (h as Map<String, dynamic>)['number'] as int,
              par: h['par'] as int,
              strokeIndex: h['strokeIndex'] as int,
              metres: h['metres'] as int?,
            ),
        ]
      // Rounds saved before holes were kept recorded which of the two layouts
      // the app then knew they were played on.
      : json['layout'] == 'standard'
      ? standardHoles
      : richmondHoles;
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
    holes: holes,
    players: players,
    scores: scores,
    currentHole: (json['currentHole'] as int).clamp(0, holes.length - 1),
    status: RoundStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => RoundStatus.inProgress,
    ),
    startedAt: DateTime.parse(json['startedAt'] as String),
    completedAt: completedAt == null ? null : DateTime.parse(completedAt),
    courseId: json['courseId'] as String?,
  );
}
