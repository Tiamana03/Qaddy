import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/statistics/logic/stat_trend_formatting.dart';
import 'package:qaddy/features/statistics/models/stat_trend.dart';

void main() {
  test('delta and isImprovement when lower is better and value decreased', () {
    const trend = StatTrend(
      label: 'Handicap',
      currentValue: 8.4,
      previousValue: 9.6,
      period: 'Last 3 months',
      lowerIsBetter: true,
    );

    expect(trend.delta, closeTo(-1.2, 0.0001));
    expect(trend.isImprovement, isTrue);
    expect(formatTrendText(trend), '↓1.2 (Last 3 months)');
  });

  test('isImprovement is false when a lower-is-better value increased', () {
    const trend = StatTrend(
      label: 'Average Score',
      currentValue: 86,
      previousValue: 83,
      period: 'Last 3 months',
      lowerIsBetter: true,
    );

    expect(trend.isImprovement, isFalse);
    expect(formatTrendText(trend), '↑3 (Last 3 months)');
  });

  test('isImprovement is true when a higher-is-better value increased', () {
    const trend = StatTrend(
      label: 'Average Stableford',
      currentValue: 36,
      previousValue: 34,
      period: 'Last 3 months',
      lowerIsBetter: false,
    );

    expect(trend.isImprovement, isTrue);
  });

  test('formatStatValue drops a trailing .0 but keeps real decimals', () {
    expect(formatStatValue(83), '83');
    expect(formatStatValue(8.4), '8.4');
  });
}
