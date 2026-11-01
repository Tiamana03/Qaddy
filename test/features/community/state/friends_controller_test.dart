import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';

void main() {
  late ProviderContainer container;
  late FriendsController controller;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    controller = container.read(friendsProvider.notifier);
  });

  FriendStatus statusOf(String id) => container
      .read(friendsProvider)
      .friends
      .firstWhere((friend) => friend.id == id)
      .status;

  test('starts from the placeholder friends and requests', () {
    expect(container.read(confirmedFriendsProvider), hasLength(5));
    expect(container.read(incomingRequestsProvider).single.friend.id, 'sam');
    expect(container.read(outgoingRequestsProvider).single.friend.id, 'josh');
  });

  test('confirmed friends list favourites first, then the most recent', () {
    final ids = container.read(confirmedFriendsProvider).map((f) => f.id);

    // Tom and Luke are favourites; Tom played today, Luke 3 days ago.
    expect(ids.take(2), <String>['tom', 'luke']);
    expect(ids.toList().sublist(2), <String>['ben', 'nick', 'liam']);
  });

  test('accepting a request makes the golfer a confirmed friend', () {
    controller.acceptRequest('sam');

    expect(statusOf('sam'), FriendStatus.confirmed);
    expect(container.read(incomingRequestsProvider), isEmpty);
    expect(
      container.read(confirmedFriendsProvider).map((f) => f.id),
      contains('sam'),
    );
  });

  test('declining removes the request without adding a friend', () {
    controller.declineRequest('sam');

    expect(statusOf('sam'), FriendStatus.declined);
    expect(container.read(incomingRequestsProvider), isEmpty);
    expect(
      container.read(confirmedFriendsProvider).map((f) => f.id),
      isNot(contains('sam')),
    );
  });

  test('cancelling withdraws the request the golfer sent', () {
    controller.cancelRequest('josh');

    expect(statusOf('josh'), FriendStatus.removed);
    expect(container.read(outgoingRequestsProvider), isEmpty);
  });

  test('answering one request leaves the other alone', () {
    controller.acceptRequest('sam');

    expect(container.read(outgoingRequestsProvider), hasLength(1));
  });

  test('cheering toggles', () {
    controller.toggleCheer('activity-1');
    expect(container.read(friendsProvider).cheered, <String>{'activity-1'});

    controller.toggleCheer('activity-1');
    expect(container.read(friendsProvider).cheered, isEmpty);
  });

  test('a friend can be copied with a new status', () {
    final tom = container.read(friendsProvider).friends.first;
    final copy = tom.copyWith(status: FriendStatus.blocked);

    expect(copy.status, FriendStatus.blocked);
    expect(copy.displayName, tom.displayName);
    expect(copy.handicap, tom.handicap);
    expect(copy.favourite, tom.favourite);
  });
}
