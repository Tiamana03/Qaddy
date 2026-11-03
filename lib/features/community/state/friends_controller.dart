/// The store behind the Friends screens: who your friends are, who has asked
/// to be, and which of their moments you have cheered.
///
/// It starts from the placeholder friends and requests and changes only
/// through [FriendsController], so accepting a request on Friends Home is
/// reflected on the Requests and Friends List screens too. Release 1 keeps it
/// in memory (see technical debt); other features still read the placeholder
/// constants directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

/// Every friend, every open request, and the activity items you have cheered.
class FriendsState {
  const FriendsState({
    required this.friends,
    required this.requests,
    this.cheered = const <String>{},
  });

  /// Everyone the golfer has a relationship with, in any status.
  final List<Friend> friends;

  /// Requests still waiting for an answer, both directions.
  final List<FriendRequest> requests;

  /// Ids of the activity items the golfer has cheered.
  final Set<String> cheered;

  /// A copy with some parts replaced.
  FriendsState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? requests,
    Set<String>? cheered,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      cheered: cheered ?? this.cheered,
    );
  }
}

/// The clock "played recently" is measured against. Tests override it.
final friendsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// The friends store.
final friendsProvider = NotifierProvider<FriendsController, FriendsState>(
  FriendsController.new,
);

/// Confirmed friends, favourites first (the rule in friend-data-model.md),
/// then whoever played most recently.
final confirmedFriendsProvider = Provider<List<Friend>>((ref) {
  final all = ref.watch(friendsProvider.select((state) => state.friends));
  return <Friend>[
    for (final friend in all)
      if (friend.status == FriendStatus.confirmed) friend,
  ]..sort((a, b) {
    if (a.favourite != b.favourite) {
      return a.favourite ? -1 : 1;
    }
    return b.lastPlayed.compareTo(a.lastPlayed);
  });
});

/// Requests other golfers have sent the user.
final incomingRequestsProvider = Provider<List<FriendRequest>>((ref) {
  final all = ref.watch(friendsProvider.select((state) => state.requests));
  return <FriendRequest>[
    for (final request in all)
      if (request.direction == FriendRequestDirection.incoming) request,
  ];
});

/// Requests the user has sent that are still waiting.
final outgoingRequestsProvider = Provider<List<FriendRequest>>((ref) {
  final all = ref.watch(friendsProvider.select((state) => state.requests));
  return <FriendRequest>[
    for (final request in all)
      if (request.direction == FriendRequestDirection.outgoing) request,
  ];
});

/// Reads and changes the friends store.
class FriendsController extends Notifier<FriendsState> {
  @override
  FriendsState build() => FriendsState(
    friends: List<Friend>.of(friends),
    requests: List<FriendRequest>.of(friendRequests),
  );

  /// Brings the sample mates back, or takes them (and their requests) away.
  void setSample({required bool on}) {
    state = on
        ? FriendsState(
            friends: List<Friend>.of(friends),
            requests: List<FriendRequest>.of(friendRequests),
          )
        : const FriendsState(friends: <Friend>[], requests: <FriendRequest>[]);
  }

  /// Accepts [friendId]'s request: they become a confirmed friend.
  void acceptRequest(String friendId) =>
      _answer(friendId, FriendStatus.confirmed);

  /// Declines [friendId]'s request.
  void declineRequest(String friendId) =>
      _answer(friendId, FriendStatus.declined);

  /// Withdraws the request the user sent to [friendId].
  void cancelRequest(String friendId) =>
      _answer(friendId, FriendStatus.removed);

  void _answer(String friendId, FriendStatus status) {
    state = state.copyWith(
      friends: <Friend>[
        for (final friend in state.friends)
          if (friend.id == friendId)
            friend.copyWith(status: status)
          else
            friend,
      ],
      requests: <FriendRequest>[
        for (final request in state.requests)
          if (request.friend.id != friendId) request,
      ],
    );
  }

  /// Cheers the activity item [id], or takes the cheer back.
  void toggleCheer(String id) {
    final next = <String>{...state.cheered};
    if (!next.remove(id)) {
      next.add(id);
    }
    state = state.copyWith(cheered: next);
  }
}
