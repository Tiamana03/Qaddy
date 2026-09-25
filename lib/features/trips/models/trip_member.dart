/// A Trip's participants — see `docs/architecture/trip-data-model.md`'s
/// "Trip Participants," "Participant Status" and "Trip Roles" sections.
library;

/// A participant's role on a trip. Spectator/Guest are documented as future
/// releases, not implemented here.
enum TripRole { organiser, player }

/// A participant's invitation status — mirrors
/// `round-data-model.md`'s Player Status precedent.
enum ParticipantStatus { confirmed, pending, declined }

/// One trip participant.
class TripMember {
  const TripMember({
    required this.displayName,
    required this.handicap,
    required this.role,
    required this.status,
  });

  /// The participant's name.
  final String displayName;

  /// The participant's handicap.
  final double handicap;

  /// The participant's role on this trip.
  final TripRole role;

  /// The participant's invitation status.
  final ParticipantStatus status;
}
