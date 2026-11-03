import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/notifications/logic/notification_feed.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';

// A Sunday: the Saturday round is six days away.
final DateTime _sunday = DateTime(2026, 11, 1, 9);

const _roundId = 'round:Saturday:8:20 AM';
const _tableId = "table:saturday-boys:You're 5th in the Saturday Boys table";

typedef _Trip = ({String id, String name, String destination, int daysToGo});

NotificationInputs _inputs({
  DateTime? now,
  int? liveHole,
  List<FriendRequest> requests = const <FriendRequest>[],
  bool hasHandicap = true,
  int earned = 0,
  _Trip? trip,
  int toReply = 0,
}) => NotificationInputs(
  golferName: 'Sam',
  hasHandicap: hasHandicap,
  now: now ?? _sunday,
  roundDay: 'Saturday',
  roundCourse: 'Richmond Golf Club',
  roundTeeTime: '8:20 AM',
  incomingRequests: requests,
  earnedAchievements: earned,
  liveHole: liveHole,
  liveCourse: 'Richmond Golf Club',
  nextTrip: trip,
  tripStillToReply: toReply,
  tableId: 'saturday-boys',
  tableHeadline: "You're 5th in the Saturday Boys table",
  tableDetail: '4 points behind Ben · 10 rounds to go',
  tableLocation: '/friends/groups/saturday-boys',
);

Map<String, NotificationItem> _byId(List<NotificationItem> items) => {
  for (final item in items) item.id: item,
};

NotificationItem _achievements(List<NotificationItem> feed) =>
    feed.firstWhere((i) => i.id.startsWith('achievements'));

const _melbourne = (
  id: 'melbourne-golf-weekend',
  name: 'Melbourne Golf Weekend',
  destination: 'Melbourne, Australia',
  daysToGo: 27,
);

void main() {
  test('always welcomes the golfer by name, last', () {
    final feed = buildNotificationFeed(_inputs());

    expect(feed.last.id, 'welcome');
    expect(feed.last.message, 'Welcome to Qaddy, Sam');
  });

  group('the next round', () {
    test('counts the days', () {
      final item = _byId(buildNotificationFeed(_inputs()))[_roundId]!;

      expect(item.message, 'Your round starts in 6 days');
      expect(item.when, 'In 6 days');
      expect(item.location, '/rounds');
    });

    test('says tomorrow and today', () {
      final tomorrow = buildNotificationFeed(
        _inputs(now: DateTime(2026, 10, 30)),
      );
      final today = buildNotificationFeed(_inputs(now: DateTime(2026, 10, 31)));

      expect(
        _byId(tomorrow)[_roundId]!.message,
        'Tomorrow you tee off at 8:20 AM',
      );
      expect(
        _byId(today)[_roundId]!.message,
        "It's round day — you tee off at 8:20 AM",
      );
    });

    test('gives way to a round already in progress', () {
      final feed = _byId(buildNotificationFeed(_inputs(liveHole: 7)));

      expect(feed.containsKey(_roundId), isFalse);
      expect(feed['round:live']!.detail, contains('Hole 7'));
      expect(feed['round:live']!.location, '/rounds/scorecard');
    });
  });

  test('every friend request is its own notification', () {
    final feed = buildNotificationFeed(
      _inputs(requests: incomingFriendRequests),
    );

    final request = feed.firstWhere((i) => i.id.startsWith('request:'));
    expect(request.message, 'Sam wants to play with you');
    expect(request.location, '/friends/requests');
  });

  group('the next trip', () {
    test('says how far away it is and opens the trip', () {
      final feed = _byId(buildNotificationFeed(_inputs(trip: _melbourne)));
      final item = feed['trip:melbourne-golf-weekend:countdown']!;

      expect(item.message, 'Melbourne Golf Weekend is 27 days away');
      expect(item.location, '/trips/melbourne-golf-weekend');
    });

    test('says tomorrow, and not "1 days"', () {
      final feed = buildNotificationFeed(
        _inputs(
          trip: (id: 'x', name: 'Trip', destination: 'Here', daysToGo: 1),
        ),
      );

      expect(
        feed.firstWhere((i) => i.id == 'trip:x:countdown').message,
        'Trip starts tomorrow',
      );
    });

    test('nudges about mates who have not replied', () {
      final feed = buildNotificationFeed(_inputs(trip: _melbourne, toReply: 2));

      final item = feed.firstWhere((i) => i.id.contains(':reply:'));
      expect(
        item.message,
        '2 mates have not replied to Melbourne Golf Weekend',
      );
      expect(item.location, '/trips/melbourne-golf-weekend/invite');
    });

    test('and says "mate has" for one', () {
      final feed = buildNotificationFeed(_inputs(trip: _melbourne, toReply: 1));

      expect(
        feed.firstWhere((i) => i.id.contains(':reply:')).message,
        '1 mate has not replied to Melbourne Golf Weekend',
      );
    });
  });

  test('achievements appear once earned, and are new again when more are', () {
    expect(
      buildNotificationFeed(
        _inputs(),
      ).where((i) => i.id.startsWith('achievements')),
      isEmpty,
    );

    final one = buildNotificationFeed(_inputs(earned: 1));
    final two = buildNotificationFeed(_inputs(earned: 2));

    expect(_achievements(one).message, "You've earned an achievement");
    expect(_achievements(two).message, "You've earned 2 achievements");
    expect(_achievements(one).id, isNot(_achievements(two).id));
  });

  test('a golfer with no handicap is nudged to add one', () {
    final without = _byId(buildNotificationFeed(_inputs(hasHandicap: false)));
    final given = _byId(buildNotificationFeed(_inputs()));

    expect(without['tip:handicap']!.location, '/profile/settings');
    expect(given.containsKey('tip:handicap'), isFalse);
  });

  test('where the golfer stands in the table leads to the group', () {
    final item = _byId(buildNotificationFeed(_inputs()))[_tableId]!;

    expect(item.location, '/friends/groups/saturday-boys');
  });

  test('every notification leads somewhere and has its own id', () {
    final feed = buildNotificationFeed(
      _inputs(
        liveHole: 3,
        requests: incomingFriendRequests,
        earned: 2,
        hasHandicap: false,
        toReply: 1,
        trip: (id: 't', name: 'Trip', destination: 'Here', daysToGo: 5),
      ),
    );

    expect(feed.every((i) => i.location.startsWith('/')), isTrue);
    expect(feed.map((i) => i.id).toSet().length, feed.length);
  });

  test('tab destinations are gone to, the rest pushed', () {
    expect(isTabLocation('/rounds'), isTrue);
    expect(isTabLocation('/profile'), isTrue);
    expect(isTabLocation('/rounds/scorecard'), isFalse);
    expect(isTabLocation('/friends/requests'), isFalse);
  });
}
