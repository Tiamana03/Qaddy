import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/repositories/rounds_codec.dart';

Round _round(String id, String course, List<dynamic> holes) => Round.start(
  id: id,
  course: course,
  format: 'Stableford',
  holes: holes.cast(),
  players: const <RoundPlayer>[RoundPlayer(name: 'Zed', handicap: 12)],
  now: DateTime(2026, 10, 1, 8),
);

void main() {
  tearDown(resetSampleClubhouseForTests);

  test('a round comes back as it was saved', () {
    final live = _round('a', 'Richmond Golf Club', richmondHoles);

    final back = decodeRounds(encodeRounds(live: live))!.live!;

    expect(back.course, 'Richmond Golf Club');
    expect(back.holes, richmondHoles);
  });

  test("a round on the golfer's own course keeps the standard layout", () {
    final live = _round('a', 'Royal Perth', standardHoles);

    final back = decodeRounds(encodeRounds(live: live))!.live!;

    expect(back.holes, standardHoles);
    expect(back.holes.every((hole) => hole.metres == null), isTrue);
  });

  test('rounds on other courses survive a change of home course', () {
    // The golfer played the sample round, then started over with no sample and
    // another home course: nothing they played may be dropped.
    final stored = encodeRounds(
      live: _round('live', 'Royal Perth', standardHoles),
      history: <Round>[
        _round('one', 'Richmond Golf Club', richmondHoles),
        _round('two', 'Somewhere Else', standardHoles),
      ],
    );
    useSampleClubhouse(on: false);

    final back = decodeRounds(stored)!;

    expect(back.live!.course, 'Royal Perth');
    expect(back.history.map((r) => r.course), <String>[
      'Richmond Golf Club',
      'Somewhere Else',
    ]);
  });

  test('a round saved before layouts were recorded is the sample one', () {
    final saved =
        jsonDecode(
              encodeRounds(
                live: _round('a', 'Richmond Golf Club', richmondHoles),
              ),
            )
            as Map<String, dynamic>;
    final live = saved['live'] as Map<String, dynamic>
      ..remove('holes')
      ..remove('courseId')
      ..['layout'] = 'sample';

    expect(live['layout'], 'sample');
    expect(decodeRounds(jsonEncode(saved))!.live!.holes, richmondHoles);
  });

  test("a round keeps the course's own holes, whatever the app knows", () {
    // A course from the catalogue: its holes are saved with the round, so the
    // round still reads right when the catalogue changes or is offline.
    const holes = <CourseHole>[
      CourseHole(number: 1, par: 5, strokeIndex: 3, metres: 501),
      CourseHole(number: 2, par: 3, strokeIndex: 1, metres: 144),
    ];
    final live = Round.start(
      id: 'a',
      course: 'Some Course',
      courseId: 'gc-123',
      format: 'Stableford',
      holes: holes,
      players: const <RoundPlayer>[RoundPlayer(name: 'Zed', handicap: 12)],
      now: DateTime(2026, 10, 1, 8),
    );

    final back = decodeRounds(encodeRounds(live: live))!.live!;

    expect(back.holes, holes);
    expect(back.courseId, 'gc-123');
  });

  test('a round on no chosen course has no course id', () {
    final live = _round('a', 'Royal Perth', standardHoles);

    expect(decodeRounds(encodeRounds(live: live))!.live!.courseId, isNull);
  });

  test('an unreadable document decodes to nothing', () {
    expect(decodeRounds('{not json'), isNull);
    expect(decodeRounds('[]'), isNull);
  });
}
