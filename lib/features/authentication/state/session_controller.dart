/// The store behind the launch experience: has the golfer seen the
/// introduction, and are they playing as a guest?
///
/// It lives on the device (see `DocumentStorage`): the store loads the state
/// when the app starts and saves after every change. Screens read through
/// [sessionProvider] and change it only through [SessionController].
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/features/authentication/models/session.dart';

/// The session's storage. `main` overrides it with on-device storage.
final sessionStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// The golfer's launch state.
final sessionProvider = NotifierProvider<SessionController, AuthSession>(
  SessionController.new,
);

/// The key the session is kept under.
const String sessionStorageKey = 'qaddy.session.v1';

/// Changes the launch state.
class SessionController extends Notifier<AuthSession> {
  @override
  AuthSession build() {
    final storage = ref.read(sessionStorageProvider);
    // Save after every change from here on (the starting state is not one).
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(storage.write(encodeSession(next)));
    });

    final stored = storage.read();
    return (stored == null ? null : decodeSession(stored)) ??
        const AuthSession();
  }

  /// Remembers that the introduction has been seen.
  void completeOnboarding() {
    if (!state.onboardingComplete) {
      state = state.copyWith(onboardingComplete: true);
    }
  }

  /// Remembers that the golfer is playing as a guest (which also means the
  /// introduction is done).
  void continueAsGuest() {
    state = state.copyWith(onboardingComplete: true, isGuest: true);
  }
}

/// The session as the JSON document kept on the device.
String encodeSession(AuthSession session) => jsonEncode(<String, Object?>{
  'version': 1,
  'onboardingComplete': session.onboardingComplete,
  'guest': session.isGuest,
});

/// Reads a document written by [encodeSession]; `null` when it cannot be
/// read, so the golfer simply starts from the introduction.
AuthSession? decodeSession(String document) {
  try {
    final json = jsonDecode(document);
    if (json is! Map<String, dynamic>) {
      return null;
    }
    return AuthSession(
      onboardingComplete: json['onboardingComplete'] == true,
      isGuest: json['guest'] == true,
    );
  } on FormatException {
    return null;
  }
}
