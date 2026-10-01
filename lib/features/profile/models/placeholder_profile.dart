/// The Profile feature's shared placeholder data.
///
/// See `docs/standards/placeholder-profile-data.md`. Per
/// `docs/architecture/profile-engineering-decisions.md`'s "Tiamana Is the
/// Shared Placeholder Subject", the current user (Tiamana) is Profile's
/// only subject — there is no list of profiles to choose from.
///
/// Friends/Groups/Trips counts, the Current Season card, and
/// `profileRoundsPlayed`/`profileAverageScore`/`profileBestRound` are all
/// computed from each owning feature's own placeholder data rather than
/// duplicated as new literals (see that same document's "Friends, Groups
/// and Rounds-Played Counts Are Computed, Not Duplicated", and
/// `docs/reviews/technical-debt.md`'s TD-005) — these are the only things
/// in this file that are not plain literals.
library;

import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart'
    as friends_data;
import 'package:qaddy/features/dashboard/models/placeholder_dashboard.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart'
    as groups_data;
import 'package:qaddy/features/profile/models/achievement_preview.dart';
import 'package:qaddy/features/profile/models/profile.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart'
    as trips_data;

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

/// Friends count — computed from `placeholder_friends.dart`, not duplicated.
int get profileFriendsCount => friends_data.totalFriendsCount;

/// Groups count — computed from `placeholder_groups.dart`, not duplicated.
int get profileGroupsCount => groups_data.groups.length;

/// Trips count — computed from `placeholder_trips.dart`, not duplicated.
int get profileTripsCount =>
    trips_data.upcomingTripsCount + trips_data.pastTripsCount;

/// Rounds played — computed from `placeholder_dashboard.dart`, not
/// duplicated (resolves TD-005; see `docs/reviews/technical-debt.md`).
const int profileRoundsPlayed = dashboardRoundsPlayed;

/// Courses played — see placeholder-profile-data.md's "Profile Summary".
const int profileCoursesPlayed = 18;

/// Seasons completed.
const int profileSeasonsCompleted = 1;

/// Total unlocked achievements.
const int profileAchievementsCount = 12;

/// Playing Statistics. `profileAverageScore` and `profileBestRound` are
/// computed from `placeholder_dashboard.dart`, not duplicated (resolves
/// TD-005); the rest have no Dashboard equivalent and remain literals here.
const int profileAverageScore = dashboardAverageScore;
const int profileAverageStableford = 34;
const int profileBestRound = dashboardBestRound;
const int profileBestStableford = 42;
const int profileBirdies = 37;
const int profileEagles = 2;
const int profilePars = 298;
const int profileFairwaysHitPercent = 62;
const int profileGreensInRegulationPercent = 48;
const int profileAveragePutts = 31;

/// Personal Bests.
const int profileBestFrontNine = 37;
const int profileBestBackNine = 38;
const int profileMostBirdies = 5;
const double profileLongestDriveMetres = 312;
const double profileLongestPuttMetres = 18;

/// Lifetime Statistics.
const int profileTotalStablefordPoints = 1428;

/// Tiamana's Current Season standing — read directly from Saturday Boys'
/// own placeholder leaderboard rather than restated here.
///
/// Falls back to an unranked entry rather than throwing if Saturday Boys'
/// leaderboard is ever changed without a matching entry for Tiamana —
/// Profile depends on Groups' placeholder data staying in sync, but should
/// degrade gracefully rather than crash if it doesn't.
GroupLeaderboardEntry get profileCurrentSeasonStanding =>
    groups_data.saturdayBoysLeaderboard.firstWhere(
      (entry) => entry.player == profile.displayName,
      orElse: () => GroupLeaderboardEntry(
        rank: 0,
        player: profile.displayName,
        points: 0,
      ),
    );

/// Tiamana's current season name and group — see
/// placeholder-group-data.md's "Saturday Boys".
String get profileCurrentSeasonName =>
    groups_data.saturdayBoysSeasonSummary.season;
String get profileCurrentSeasonGroup => groups_data.saturdayBoys.name;

/// One entry in Profile's Recent Activity list.
class ProfileActivityEntry {
  const ProfileActivityEntry({required this.when, required this.description});

  /// When the activity happened, as display text (e.g. "Yesterday").
  final String when;

  /// The activity's description.
  final String description;
}

/// Recent Activity — see placeholder-profile-data.md's "Recent Activity".
const List<ProfileActivityEntry> profileRecentActivity = <ProfileActivityEntry>[
  ProfileActivityEntry(
    when: 'Yesterday',
    description: 'Completed Richmond Golf Club',
  ),
  ProfileActivityEntry(
    when: '3 Days Ago',
    description: 'Joined Wednesday Warriors',
  ),
  ProfileActivityEntry(
    when: 'Last Week',
    description: 'Earned "Course Collector"',
  ),
  ProfileActivityEntry(
    when: '2 Weeks Ago',
    description: 'Planned Gold Coast Golf Escape',
  ),
  ProfileActivityEntry(
    when: '3 Weeks Ago',
    description: 'Added Nick as Friend',
  ),
];

/// Achievement Showcase — see placeholder-profile-data.md's "Achievement
/// Showcase" (title and unlocked status only — see
/// profile-engineering-decisions.md's "Achievements Use a Simplified
/// Preview").
const List<AchievementPreview> profileAchievementShowcase =
    <AchievementPreview>[
      AchievementPreview(title: 'First Round', unlocked: true),
      AchievementPreview(title: 'Birdie Hunter', unlocked: true),
      AchievementPreview(title: 'Course Collector', unlocked: true),
      AchievementPreview(title: 'Weekend Warrior', unlocked: true),
      AchievementPreview(title: 'Road Tripper', unlocked: true),
      AchievementPreview(title: 'Season Competitor', unlocked: true),
    ];

/// Favourite Courses — see placeholder-profile-data.md's "Favourite
/// Courses".
const List<String> profileFavouriteCourses = <String>[
  'Royal Queensland Golf Club',
  'Richmond Golf Club',
  'Brookwater Golf Club',
  'Virginia Golf Club',
  'Wantima Country Club',
];

/// Favourite Playing Partners — reuses the existing `Friend` objects from
/// `placeholder_friends.dart` rather than restating plain names (see
/// profile-engineering-decisions.md's "Favourite Playing Partners Is Not
/// the Friend Model's `favourite` Flag").
List<Friend> get profileFavouritePlayingPartners {
  const names = <String>['Tom', 'Luke', 'Ben', 'Nick'];
  return friends_data.friends
      .where((friend) => names.contains(friend.displayName))
      .toList();
}

/// One entry in Profile's Equipment list.
class ProfileEquipmentItem {
  const ProfileEquipmentItem({required this.club, required this.value});

  /// The equipment category (e.g. "Driver").
  final String club;

  /// The specific product (e.g. "TaylorMade Qi35").
  final String value;
}

/// Equipment — see placeholder-profile-data.md's "Equipment".
const List<ProfileEquipmentItem> profileEquipment = <ProfileEquipmentItem>[
  ProfileEquipmentItem(club: 'Driver', value: 'TaylorMade Qi35'),
  ProfileEquipmentItem(club: 'Irons', value: 'TaylorMade P790'),
  ProfileEquipmentItem(club: 'Wedges', value: 'Cleveland RTX'),
  ProfileEquipmentItem(club: 'Putter', value: 'Odyssey White Hot'),
  ProfileEquipmentItem(club: 'Ball', value: 'Titleist Pro V1'),
];
