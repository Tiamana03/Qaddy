/// What the app remembers about the golfer between launches.
///
/// Release 1 has no accounts: the golfer either has not finished the
/// introduction yet, or has and is playing as a guest on this phone. See
/// `docs/features/launch-experience.md`.
library;

/// The golfer's launch state.
class AuthSession {
  const AuthSession({this.onboardingComplete = false, this.isGuest = false});

  /// Whether the introduction has been seen, so returning golfers go straight
  /// into the app.
  final bool onboardingComplete;

  /// Whether the golfer chose to continue as a guest.
  final bool isGuest;

  /// A copy with the given fields changed.
  AuthSession copyWith({bool? onboardingComplete, bool? isGuest}) =>
      AuthSession(
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        isGuest: isGuest ?? this.isGuest,
      );
}
