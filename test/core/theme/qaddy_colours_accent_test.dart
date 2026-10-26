import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// WCAG contrast ratio between two colours.
double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

void main() {
  test('accent is gold in Dark Mode and primary in Light Mode', () {
    expect(QaddyColours.dark.accent, QaddyColours.dark.gold);
    expect(QaddyColours.light.accent, QaddyColours.light.primary);
  });

  test('accent is readable as a foreground on its own background', () {
    for (final colours in <QaddyColours>[
      QaddyColours.dark,
      QaddyColours.light,
    ]) {
      expect(
        _contrast(colours.accent, colours.background),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('primary alone is not readable on Dark Mode — why accent exists', () {
    expect(
      _contrast(QaddyColours.dark.primary, QaddyColours.dark.background),
      lessThan(3),
    );
  });
}
