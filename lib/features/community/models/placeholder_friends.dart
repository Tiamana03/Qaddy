/// The Friends feature's shared placeholder data.
///
/// See `docs/standards/placeholder-friend-data.md`. Per
/// `docs/architecture/friends-engineering-decisions.md`'s "Shared
/// Placeholder Subjects", **Tom** is the single shared placeholder friend
/// with full detail data (Friend Profile, Rivalries) — the other seven
/// friends only need the summary fields shown on Friends List, Friend
/// Requests, Search Friends and Activity Feed.
library;

import 'package:qaddy/features/community/models/activity_feed_item.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/community/models/rivalry_record.dart';

/// Tom — the shared placeholder friend with full detail data.
final Friend tom = Friend(
  id: 'tom',
  displayName: 'Tom',
  initials: 'TO',
  handicap: 8,
  homeClub: 'Richmond Golf Club',
  favouriteCourse: 'Richmond Golf Club',
  location: 'Richmond, VIC',
  status: FriendStatus.confirmed,
  favourite: true,
  lastPlayed: DateTime.now(),
  roundsPlayed: 12,
  createdAt: DateTime(2022),
);

final Friend _ben = Friend(
  id: 'ben',
  displayName: 'Ben',
  initials: 'BE',
  handicap: 12,
  homeClub: 'Pacific Harbour',
  favouriteCourse: 'Brookwater Golf Club',
  location: 'Ipswich, QLD',
  status: FriendStatus.confirmed,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 1)),
  roundsPlayed: 8,
  createdAt: DateTime(2021, 3),
);

final Friend _luke = Friend(
  id: 'luke',
  displayName: 'Luke',
  initials: 'LU',
  handicap: 5,
  homeClub: 'Royal Queensland',
  favouriteCourse: 'Royal Queensland',
  location: 'Brisbane, QLD',
  status: FriendStatus.confirmed,
  favourite: true,
  lastPlayed: DateTime.now().subtract(const Duration(days: 3)),
  roundsPlayed: 15,
  createdAt: DateTime(2020, 6),
);

final Friend _josh = Friend(
  id: 'josh',
  displayName: 'Josh',
  initials: 'JO',
  handicap: 15,
  homeClub: 'Virginia',
  favouriteCourse: 'Virginia Golf Club',
  location: 'Brisbane, QLD',
  status: FriendStatus.pending,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 14)),
  roundsPlayed: 4,
  createdAt: DateTime(2023, 7),
);

final Friend _nick = Friend(
  id: 'nick',
  displayName: 'Nick',
  initials: 'NI',
  handicap: 10,
  homeClub: 'Wantima',
  favouriteCourse: 'Wantima Country Club',
  location: 'Bray Park, QLD',
  status: FriendStatus.confirmed,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 3)),
  roundsPlayed: 6,
  createdAt: DateTime(2022, 4),
);

final Friend _sam = Friend(
  id: 'sam',
  displayName: 'Sam',
  initials: 'SA',
  handicap: 18,
  homeClub: 'Indooroopilly',
  favouriteCourse: 'Indooroopilly Golf Club',
  location: 'Indooroopilly, QLD',
  status: FriendStatus.pending,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 30)),
  roundsPlayed: 2,
  createdAt: DateTime(2023, 9),
);

final Friend _liam = Friend(
  id: 'liam',
  displayName: 'Liam',
  initials: 'LI',
  handicap: 7,
  homeClub: 'Nudgee',
  favouriteCourse: 'Nudgee Golf Club',
  location: 'Nudgee, QLD',
  status: FriendStatus.confirmed,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 4)),
  roundsPlayed: 9,
  createdAt: DateTime(2021, 2),
);

final Friend _jack = Friend(
  id: 'jack',
  displayName: 'Jack',
  initials: 'JA',
  handicap: 22,
  homeClub: 'Gailes',
  favouriteCourse: 'Gailes Golf Club',
  location: 'Gailes, QLD',
  status: FriendStatus.declined,
  favourite: false,
  lastPlayed: DateTime.now().subtract(const Duration(days: 182)),
  roundsPlayed: 1,
  createdAt: DateTime(2022, 11),
);

/// Every placeholder friend — see placeholder-friend-data.md's "Friends"
/// table (8 entries).
final List<Friend> friends = <Friend>[
  tom,
  _ben,
  _luke,
  _josh,
  _nick,
  _sam,
  _liam,
  _jack,
];

/// Confirmed friends only — Friends List filters to this subset, per
/// friends-engineering-decisions.md's "Friends List Shows Confirmed
/// Friends Only".
List<Friend> get confirmedFriends =>
    friends.where((friend) => friend.status == FriendStatus.confirmed).toList();

/// Total friend count — see placeholder-friend-data.md's "Friend Summary".
int get totalFriendsCount => friends.length;

/// Confirmed friend count.
int get confirmedFriendsCount => confirmedFriends.length;

/// Pending friend count.
int get pendingFriendsCount =>
    friends.where((friend) => friend.status == FriendStatus.pending).length;

/// Friend-scoped activity — see `docs/architecture/activity-feed.md` and
/// placeholder-friend-data.md's "Activity Feed" section (5 entries,
/// ordered newest first).
final List<ActivityFeedItem> friendActivityFeed = <ActivityFeedItem>[
  ActivityFeedItem(
    id: 'activity-1',
    actor: tom.displayName,
    type: ActivityType.roundCompleted,
    message: 'Tom completed a round at Richmond Golf Club',
    relatedEntity: 'Richmond Golf Club',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ActivityFeedItem(
    id: 'activity-2',
    actor: _ben.displayName,
    type: ActivityType.groupJoined,
    message: 'Ben joined Saturday Boys',
    relatedEntity: 'Saturday Boys',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ActivityFeedItem(
    id: 'activity-3',
    actor: _luke.displayName,
    type: ActivityType.handicapChanged,
    message: "Luke's handicap improved to 5",
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ActivityFeedItem(
    id: 'activity-4',
    actor: _nick.displayName,
    type: ActivityType.tripCreated,
    message: 'Nick created Gold Coast Golf Escape',
    relatedEntity: 'Gold Coast Golf Escape',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ActivityFeedItem(
    id: 'activity-5',
    actor: _liam.displayName,
    type: ActivityType.achievementUnlocked,
    message: 'Liam unlocked Personal Best',
    relatedEntity: 'Personal Best',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

/// The shared placeholder rivalry: the current user (Tiamana) against Tom —
/// see `docs/architecture/rivalries.md`.
final RivalryRecord tomRivalry = RivalryRecord(
  friendName: tom.displayName,
  roundsPlayed: 12,
  wins: 6,
  losses: 5,
  draws: 1,
  lastResult: 'Won by 2 strokes at Richmond Golf Club',
);

/// Pending friendships split by direction — see
/// `docs/architecture/friend-requests.md` and placeholder-friend-data.md's
/// "Friend Requests" section.
final List<FriendRequest> friendRequests = <FriendRequest>[
  FriendRequest(
    friend: _sam,
    direction: FriendRequestDirection.incoming,
    sentDescription: '3 days ago',
  ),
  FriendRequest(
    friend: _josh,
    direction: FriendRequestDirection.outgoing,
    sentDescription: '5 days ago',
  ),
];

/// Incoming friend requests.
List<FriendRequest> get incomingFriendRequests => friendRequests
    .where((request) => request.direction == FriendRequestDirection.incoming)
    .toList();

/// Outgoing friend requests.
List<FriendRequest> get outgoingFriendRequests => friendRequests
    .where((request) => request.direction == FriendRequestDirection.outgoing)
    .toList();
