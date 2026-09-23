import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';

void main() {
  test('copyWithGrossScore replaces only the gross score', () {
    const hole = HoleScore(
      holeNumber: 1,
      par: 4,
      strokeIndex: 11,
      distance: 352,
      grossScore: 4,
    );

    final updated = hole.copyWithGrossScore(5);

    expect(updated.grossScore, 5);
    expect(updated.holeNumber, hole.holeNumber);
    expect(updated.par, hole.par);
    expect(updated.strokeIndex, hole.strokeIndex);
    expect(updated.distance, hole.distance);
  });
}
