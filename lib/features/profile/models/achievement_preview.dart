/// A simplified stand-in for the full Achievement model — see
/// `docs/architecture/profile-engineering-decisions.md`'s "Achievements
/// Use a Simplified Preview, Not the Full Achievement Model".
///
/// The full model (`docs/architecture/profile-achievements.md`) remains
/// reserved for a future, dedicated Achievements screen.
library;

/// One achievement shown in Profile's Achievement Showcase.
class AchievementPreview {
  const AchievementPreview({required this.title, required this.unlocked});

  /// The achievement's title (e.g. "Birdie Hunter").
  final String title;

  /// Whether this achievement has been unlocked.
  final bool unlocked;
}
