/// The canonical Profile model — see `docs/architecture/profile-data-model.md`'s
/// "Profile Model", "Profile Status" and "Profile Visibility" sections.
///
/// Implements only the fields with real placeholder backing and actual
/// on-screen use — see `docs/architecture/profile-engineering-decisions.md`'s
/// "Profile Model Fields Not Yet Populated" for which fields were left out
/// and why (the same discipline already applied to the Friend model).
library;

/// A Profile's account status.
enum ProfileStatus { active, inactive, suspended, deleted }

/// Who can view a Profile's information.
enum ProfileVisibility { public, friendsOnly, private }

/// A human-readable label for [visibility] — the single source both
/// Profile's own Details card and Settings' Privacy section read from,
/// rather than each hardcoding the same string independently. See
/// `docs/architecture/settings-engineering-decisions.md`'s "Profile
/// Visibility Is Derived, Not Restated as a Second Literal".
String profileVisibilityLabel(ProfileVisibility visibility) {
  return switch (visibility) {
    ProfileVisibility.public => 'Public',
    ProfileVisibility.friendsOnly => 'Friends Only',
    ProfileVisibility.private => 'Private',
  };
}

/// The current user's own identity — personal details, summary statistics
/// and references to other features' data.
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.handicap,
    required this.homeCourse,
    required this.location,
    required this.joinedDate,
    required this.status,
    required this.profileVisibility,
    this.favouriteCourse,
  });

  /// Unique Profile ID. Release 1 has no authentication, so this is the
  /// display name in a stable, id-shaped form — matching `Friend.id` and
  /// `Trip.organiserId`'s precedent for the same limitation.
  final String id;

  /// Public display name.
  final String displayName;

  /// Current handicap.
  final double handicap;

  /// Preferred golf course.
  final String homeCourse;

  /// Optional favourite course.
  final String? favouriteCourse;

  /// City or region.
  final String location;

  /// Date joined Qaddy.
  final DateTime joinedDate;

  /// Current account status.
  final ProfileStatus status;

  /// Privacy setting.
  final ProfileVisibility profileVisibility;
}
