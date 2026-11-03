/// What the sign-in and sign-up forms check before they say anything.
///
/// Each returns the message to show, or `null` when the value is fine.
library;

/// The shortest password sign-up accepts.
const int minPasswordLength = 8;

final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// A name to call the golfer.
String? validateName(String value) =>
    value.trim().isEmpty ? 'What should we call you?' : null;

/// An email address, loosely: something, an @, a domain and a dot.
String? validateEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) {
    return 'Enter your email address';
  }
  return _email.hasMatch(email) ? null : 'That does not look like an email';
}

/// A password when signing in: just not empty.
String? validateSignInPassword(String value) =>
    value.isEmpty ? 'Enter your password' : null;

/// A new password: long enough to be worth having.
String? validateNewPassword(String value) {
  if (value.isEmpty) {
    return 'Choose a password';
  }
  return value.length < minPasswordLength
      ? 'Use at least $minPasswordLength characters'
      : null;
}
