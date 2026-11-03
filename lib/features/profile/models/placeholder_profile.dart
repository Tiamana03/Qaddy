/// The Profile feature's shared placeholder data.
///
/// See `docs/standards/placeholder-profile-data.md`. The current user
/// (Tiamana) is Profile's only subject. What used to live here — career
/// totals, personal bests, the achievement showcase, recent activity,
/// favourite partners — is now worked out from the rounds the golfer has
/// actually played (see `docs/features/profile-release-candidate.md`), so only
/// what no round can say remains: who the golfer is, their handicap index,
/// and their favourite courses (the bag is Golf Bag's).
library;

import 'package:qaddy/features/profile/models/profile.dart';

/// Tiamana — the current user and Profile's only subject.
final Profile profile = Profile(
  id: 'tiamana',
  displayName: 'Tiamana',
  handicap: 8.4,
  homeCourse: 'Richmond Golf Club',
  favouriteCourse: 'Royal Queensland Golf Club',
  location: 'Queensland, Australia',
  joinedDate: DateTime(2024),
  status: ProfileStatus.active,
  profileVisibility: ProfileVisibility.friendsOnly,
);

/// Favourite Courses — see placeholder-profile-data.md's "Favourite
/// Courses".
const List<String> profileFavouriteCourses = <String>[
  'Royal Queensland Golf Club',
  'Richmond Golf Club',
  'Brookwater Golf Club',
  'Virginia Golf Club',
  'Wantima Country Club',
];
