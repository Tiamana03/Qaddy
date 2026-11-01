import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';

void main() {
  group('shotsReceived', () {
    test('gives nothing to a scratch golfer', () {
      expect(shotsReceived(playingHandicap: 0, strokeIndex: 1), 0);
    });

    test('spreads a handicap over the hardest holes first', () {
      expect(shotsReceived(playingHandicap: 8, strokeIndex: 8), 1);
      expect(shotsReceived(playingHandicap: 8, strokeIndex: 9), 0);
      expect(shotsReceived(playingHandicap: 18, strokeIndex: 18), 1);
    });

    test('gives a second shot on the hardest holes above 18', () {
      expect(shotsReceived(playingHandicap: 20, strokeIndex: 1), 2);
      expect(shotsReceived(playingHandicap: 20, strokeIndex: 2), 2);
      expect(shotsReceived(playingHandicap: 20, strokeIndex: 3), 1);
    });
  });

  group('stablefordPoints', () {
    test('is 2 for a net par and one more for each shot better', () {
      expect(stablefordPoints(gross: 4, par: 4, shots: 0), 2);
      expect(stablefordPoints(gross: 3, par: 4, shots: 0), 3);
      expect(stablefordPoints(gross: 2, par: 4, shots: 0), 4);
      expect(stablefordPoints(gross: 1, par: 3, shots: 0), 4);
    });

    test('counts the shots a player is given', () {
      expect(stablefordPoints(gross: 5, par: 4, shots: 1), 2);
      expect(stablefordPoints(gross: 4, par: 4, shots: 1), 3);
    });

    test('is 1 for a net bogey and 0 for a net double or worse', () {
      expect(stablefordPoints(gross: 5, par: 4, shots: 0), 1);
      expect(stablefordPoints(gross: 6, par: 4, shots: 0), 0);
      expect(stablefordPoints(gross: 9, par: 4, shots: 0), 0);
    });

    test('is nothing for a hole picked up', () {
      expect(stablefordPoints(gross: 0, par: 4, shots: 2), 0);
    });
  });

  group('scoreKind and scoreLabel', () {
    test("name each score in a golfer's words", () {
      expect(scoreLabel(1, 3), 'Hole in one!');
      expect(scoreLabel(2, 5), 'Albatross');
      expect(scoreLabel(3, 5), 'Eagle');
      expect(scoreLabel(3, 4), 'Birdie');
      expect(scoreLabel(4, 4), 'Par');
      expect(scoreLabel(5, 4), 'Bogey');
      expect(scoreLabel(6, 4), 'Double bogey');
      expect(scoreLabel(8, 4), '+4');
      expect(scoreLabel(0, 4), 'Picked up');
    });

    test('a birdie or better is worth celebrating', () {
      expect(isCelebration(3, 4), isTrue);
      expect(isCelebration(3, 5), isTrue);
      expect(isCelebration(1, 3), isTrue);
      expect(isCelebration(4, 4), isFalse);
      expect(isCelebration(0, 4), isFalse);
    });
  });
}
