/// A Pending friendship presented on the Friend Requests screen — see
/// `docs/architecture/friend-requests.md`. Not a documented data model in
/// its own right (friend-requests.md defines no new model): every request
/// is one of the existing Pending [Friend] entries, split by direction.
library;

import 'package:qaddy/features/community/models/friend.dart';

/// Which direction a friend request travelled.
enum FriendRequestDirection { incoming, outgoing }

/// A Pending [Friend], plus which direction the request travelled and when
/// it was sent (display text, per placeholder-friend-data.md's "Friend
/// Requests" section — no Sent timestamp field is documented, only text).
class FriendRequest {
  const FriendRequest({
    required this.friend,
    required this.direction,
    required this.sentDescription,
  });

  /// The Pending friend this request belongs to.
  final Friend friend;

  /// Whether this request was sent to, or received from, [friend].
  final FriendRequestDirection direction;

  /// When the request was sent, as display text (e.g. "3 days ago").
  final String sentDescription;
}
