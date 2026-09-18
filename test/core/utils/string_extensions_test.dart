import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/utils/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    test('capitalize capitalises only the first character', () {
      expect('hello'.capitalize(), 'Hello');
      expect(''.capitalize(), '');
    });

    test('toTitleCase capitalises every word', () {
      expect('hello world'.toTitleCase(), 'Hello World');
    });
  });

  group('NullableStringExtensions', () {
    test('isNullOrEmpty covers null and empty', () {
      const String? nullString = null;
      expect(nullString.isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('a'.isNullOrEmpty, isFalse);
    });

    test('orDefault falls back only when null or empty', () {
      const String? nullString = null;
      expect(nullString.orDefault('fallback'), 'fallback');
      expect(''.orDefault('fallback'), 'fallback');
      expect('value'.orDefault('fallback'), 'value');
    });
  });
}
