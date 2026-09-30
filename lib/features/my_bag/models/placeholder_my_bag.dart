/// The Golf Bag feature's shared placeholder data.
///
/// See `docs/standards/placeholder-golf-bag-data.md`. Per
/// `docs/architecture/golf-bag-engineering-decisions.md`'s "Golf Bag Reuses
/// Profile's Equipment List" and "Source of Truth" section, Equipment is
/// read directly from Profile's own placeholder data. The three
/// `ClubDistance` entries are the only genuinely new placeholder data this
/// feature introduces.
library;

import 'package:qaddy/features/my_bag/models/club_distance.dart';
import 'package:qaddy/features/profile/models/placeholder_profile.dart'
    as profile_data;

/// Equipment — reused in full from Profile, not duplicated.
List<profile_data.ProfileEquipmentItem> get golfBagEquipment =>
    profile_data.profileEquipment;

/// Club Distances — see placeholder-golf-bag-data.md's "New Placeholder
/// Data". Applies only to clubs where a carry distance is a meaningful
/// golfing concept (Driver, Irons, Wedges) — Putter and Ball are
/// deliberately excluded.
const List<ClubDistance> golfBagClubDistances = <ClubDistance>[
  ClubDistance(clubName: 'Driver', averageDistanceMetres: 235),
  ClubDistance(clubName: 'Irons', averageDistanceMetres: 145),
  ClubDistance(clubName: 'Wedges', averageDistanceMetres: 95),
];

/// Total clubs in the bag — computed from Equipment, not a new literal.
int get golfBagTotalClubs => golfBagEquipment.length;

/// The club with the longest average distance — computed from Club
/// Distances, not a new literal.
ClubDistance get golfBagLongestAverageDistance => golfBagClubDistances.reduce(
  (a, b) => a.averageDistanceMetres >= b.averageDistanceMetres ? a : b,
);
