/// The canonical Friend model — see `docs/architecture/friend-data-model.md`'s
/// "Friend Model" and "Friend Status" sections.
library;

/// A friendship's lifecycle status.
enum FriendStatus { pending, confirmed, declined, blocked, removed }

/// Another Qaddy user connected to the current user.
class Friend {
  const Friend({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.handicap,
    required this.homeClub,
    required this.location,
    required this.status,
    required this.favourite,
    required this.lastPlayed,
    required this.roundsPlayed,
    required this.createdAt,
    this.favouriteCourse,
  });

  /// Unique Friend identifier. Release 1 has no user-id lookup, so this is
  /// the friend's display name in a stable, id-shaped form — matching
  /// `Trip.organiserId`'s precedent for the same limitation.
  final String id;

  /// Preferred display name.
  final String displayName;

  /// Avatar initials — see placeholder-friend-data.md's "Avatar Initials".
  final String initials;

  /// Current golf handicap.
  final double handicap;

  /// Home golf club.
  final String homeClub;

  /// Optional favourite course to play.
  final String? favouriteCourse;

  /// City or suburb.
  final String location;

  /// Friendship status.
  final FriendStatus status;

  /// Whether this is a favourite friend — favourite friends appear first
  /// throughout the application (see friend-data-model.md's Business Rules).
  final bool favourite;

  /// Most recent round played together.
  final DateTime lastPlayed;

  /// Total rounds played together.
  final int roundsPlayed;

  /// Friendship created date (placeholder-friend-data.md's "Member Since").
  final DateTime createdAt;
}
