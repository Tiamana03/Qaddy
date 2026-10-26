import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/ui/widgets/forms/trip_form_helpers.dart';

void main() {
  group('parseAmount', () {
    test('reads plain, dollar-signed and comma-separated amounts', () {
      expect(parseAmount('250'), 250);
      expect(parseAmount(r'$250'), 250);
      expect(parseAmount(r' $1,250.50 '), 1250.5);
    });

    test('returns null for blank or unparseable text', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('   '), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('12.3.4'), isNull);
    });
  });
}
