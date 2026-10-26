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

  /// The participant's name. Release 1 has no user-id lookup, so this is
  /// also the member's identity within a trip.
  final String displayName;

  /// The participant's handicap.
  final double handicap;

  /// The participant's role on this trip.
  final TripRole role;

  /// The participant's invitation status.
  final ParticipantStatus status;

  /// A copy with the given fields replaced.
  TripMember copyWith({TripRole? role, ParticipantStatus? status}) {
    return TripMember(
      displayName: displayName,
      handicap: handicap,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
