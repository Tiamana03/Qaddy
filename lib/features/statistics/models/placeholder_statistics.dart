/// The Statistics feature's shared placeholder data.
///
/// See `docs/standards/placeholder-statistics-data.md`. Per
/// `docs/architecture/statistics-engineering-decisions.md`'s "Source of
/// Truth" section, Statistics never duplicates a value already owned by
/// another feature — every constant below reads directly from Profile,
/// Groups or Friends' own placeholder data. The two `StatTrend` entries are
/// the only genuinely new placeholder data this feature introduces.
library;

import 'package:qaddy/features/community/models/placeholder_friends.dart'
    as friends_data;
import 'package:qaddy/features/community/models/rivalry_record.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart'
    as groups_data;
import 'package:qaddy/features/profile/models/placeholder_profile.dart'
    as profile_data;
import 'package:qaddy/features/statistics/models/stat_trend.dart';

// Career Totals — reused from Profile, not duplicated.
int get statisticsRoundsPlayed => profile_data.profileRoundsPlayed;
int get statisticsCoursesPlayed => profile_data.profileCoursesPlayed;
int get statisticsTripsCount => profile_data.profileTripsCount;
int get statisticsTotalStablefordPoints =>
    profile_data.profileTotalStablefordPoints;

// Scoring Statistics — reused from Profile, not duplicated.
int get statisticsAverageScore => profile_data.profileAverageScore;
int get statisticsAverageStableford => profile_data.profileAverageStableford;
int get statisticsFairwaysHitPercent => profile_data.profileFairwaysHitPercent;
int get statisticsGreensInRegulationPercent =>
    profile_data.profileGreensInRegulationPercent;
int get statisticsAveragePutts => profile_data.profileAveragePutts;

// Scoring Breakdown — reused from Profile, not duplicated.
int get statisticsBirdies => profile_data.profileBirdies;
int get statisticsEagles => profile_data.profileEagles;
int get statisticsPars => profile_data.profilePars;

// Personal Records — reused from Profile, not duplicated.
int get statisticsBestRound => profile_data.profileBestRound;
int get statisticsBestFrontNine => profile_data.profileBestFrontNine;
int get statisticsBestBackNine => profile_data.profileBestBackNine;
int get statisticsMostBirdies => profile_data.profileMostBirdies;
double get statisticsLongestDriveMetres =>
    profile_data.profileLongestDriveMetres;
double get statisticsLongestPuttMetres => profile_data.profileLongestPuttMetres;

/// The only new placeholder data this feature introduces — see
/// placeholder-statistics-data.md's "New Placeholder Data" section. Both
/// current values match Profile's own canonical figures exactly.
final List<StatTrend> statisticsTrends = <StatTrend>[
  StatTrend(
    label: 'Handicap',
    currentValue: profile_data.profile.handicap,
    previousValue: 9.6,
    period: 'Last 3 months',
    lowerIsBetter: true,
  ),
  StatTrend(
    label: 'Average Score',
    currentValue: profile_data.profileAverageScore.toDouble(),
    previousValue: 86,
    period: 'Last 3 months',
    lowerIsBetter: true,
  ),
];

// Season Performance — reused in full from Groups, not duplicated.
GroupSeasonSummary get statisticsSeasonSummary =>
    groups_data.saturdayBoysSeasonSummary;
List<GroupLeaderboardEntry> get statisticsSeasonLeaderboard =>
    groups_data.saturdayBoysLeaderboard;
String get statisticsSeasonGroupName => groups_data.saturdayBoys.name;

// Rivalry Performance — reused in full from Friends, not duplicated.
RivalryRecord get statisticsRivalry => friends_data.tomRivalry;
