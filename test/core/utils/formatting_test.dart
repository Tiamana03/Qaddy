import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/utils/formatting.dart';

void main() {
  test('formatDistance switches from metres to kilometres at 1000m', () {
    expect(formatDistance(254), '254m');
    expect(formatDistance(15400), '15.4 km');
  });

  test('formatScore uses standard golf notation', () {
    expect(formatScore(-3), '-3');
    expect(formatScore(2), '+2');
    expect(formatScore(0), 'E');
  });

  test('formatDuration omits hours when zero', () {
    expect(formatDuration(const Duration(minutes: 45)), '45m');
    expect(formatDuration(const Duration(hours: 1, minutes: 23)), '1h 23m');
  });

  test('formatCurrency always shows two decimal places', () {
    expect(formatCurrency(12), r'$12.00');
    expect(formatCurrency(9.5, symbol: '€'), '€9.50');
  });
}
