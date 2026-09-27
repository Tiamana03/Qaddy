/// The canonical Group model — see `docs/architecture/group-data-model.md`'s
/// "Group Model" and "Group Status" sections.
library;

/// A Group's lifecycle status.
enum GroupStatus { active, archived, hidden, deleted }

/// A collection of Qaddy users who organise recurring rounds, trips,
/// competitions and seasons together.
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.totalMembers,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.totalRounds,
    required this.totalTrips,
    this.description,
    this.homeCourse,
    this.competitionFormat,
    this.season,
  });

  /// Unique Group ID.
  final String id;

  /// Group name.
  final String name;

  /// Group owner's display name (Release 1 has no user-id lookup, so this
  /// stores the name directly — matching `Trip.organiserId`'s precedent).
  final String ownerId;

  /// Group members' display names — populated only for groups with known
  /// named members (see `Group Details`' shared placeholder group);
  /// otherwise empty, with [totalMembers] as the only known summary value.
  final List<String> memberIds;

  /// Current member count — see placeholder-group-data.md's "Groups" table.
  final int totalMembers;

  /// Current group status.
  final GroupStatus status;

  /// Date created.
  final DateTime createdAt;

  /// Last updated.
  final DateTime updatedAt;

  /// Total rounds played.
  final int totalRounds;

  /// Total trips completed.
  final int totalTrips;

  /// Optional description.
  final String? description;

  /// Preferred golf course.
  final String? homeCourse;

  /// Preferred scoring format.
  final String? competitionFormat;

  /// Current season name, e.g. "2026 Season".
  final String? season;
}
