import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/authentication/logic/auth_validation.dart';

void main() {
  group('validateEmail', () {
    test('asks for one when it is empty', () {
      expect(validateEmail(''), 'Enter your email address');
      expect(validateEmail('   '), 'Enter your email address');
    });

    test('accepts an ordinary address, with spaces trimmed', () {
      expect(validateEmail('tom@club.com'), isNull);
      expect(validateEmail('  tom@club.com  '), isNull);
      expect(validateEmail('a.b+c@mail.co.uk'), isNull);
    });

    test('rejects things that are not addresses', () {
      for (final bad in <String>[
        'tom',
        'tom@',
        '@club.com',
        'tom@club',
        'a b@c.com',
      ]) {
        expect(validateEmail(bad), isNotNull, reason: bad);
      }
    });
  });

  group('passwords', () {
    test('sign-in only needs something typed', () {
      expect(validateSignInPassword(''), 'Enter your password');
      expect(validateSignInPassword('x'), isNull);
    });

    test('a new password must be long enough', () {
      expect(validateNewPassword(''), 'Choose a password');
      expect(validateNewPassword('1234567'), 'Use at least 8 characters');
      expect(validateNewPassword('12345678'), isNull);
    });
  });

  test('a name must not be blank', () {
    expect(validateName(''), isNotNull);
    expect(validateName('   '), isNotNull);
    expect(validateName('Tom'), isNull);
  });
}
