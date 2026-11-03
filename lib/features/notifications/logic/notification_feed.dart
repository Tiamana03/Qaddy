/// What there is to tell the golfer, worked out from what is really going on.
///
/// Pure: everything it needs is passed in, so it can be tested without the
/// calendar or any store. Every item leads somewhere useful.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';

/// The facts the feed is built from.
class NotificationInputs {
  const NotificationInputs({
    required this.golferName,
    required this.hasHandicap,
    required this.now,
    required this.roundDay,
    required this.roundCourse,
    required this.roundTeeTime,
    required this.incomingRequests,
    required this.earnedAchievements,
    this.liveHole,
    this.liveCourse,
    this.nextTrip,
    this.tripStillToReply = 0,
    this.tripIsSample = false,
    this.roundPlanned = true,
    this.sampleOn = false,
    this.tableHeadline,
    this.tableDetail,
    this.tableLocation,
    this.tableId,
  });

  /// What the golfer is called.
  final String golferName;

  /// Whether the golfer gave a handicap.
  final bool hasHandicap;

  /// The moment things are measured from.
  final DateTime now;

  /// The day of the next round ("Saturday") and its course and tee time.
  final String roundDay;
  final String roundCourse;
  final String roundTeeTime;

  /// The hole a round in progress is on (1-based) and its course, when there
  /// is one.
  final int? liveHole;
  final String? liveCourse;

  /// Friend requests waiting for the golfer.
  final List<FriendRequest> incomingRequests;

  /// The next trip's id, name, destination and days to go, when there is one.
  final ({String id, String name, String destination, int daysToGo})? nextTrip;

  /// How many mates have not answered the next trip's invitation.
  final int tripStillToReply;

  /// Whether the next trip is a sample trip.
  final bool tripIsSample;

  /// Whether the next round is planned for a day (the sample round); an
  /// unplanned round has no reminder.
  final bool roundPlanned;

  /// Whether the Sample Clubhouse is on.
  final bool sampleOn;

  /// Where the golfer stands in their group's season, when there is one.
  final String? tableHeadline;
  final String? tableDetail;
  final String? tableLocation;
  final String? tableId;

  /// How many achievements the golfer has earned.
  final int earnedAchievements;
}

/// The notifications for [inputs], most urgent first.
List<NotificationItem> buildNotificationFeed(NotificationInputs inputs) {
  final items = <NotificationItem>[];

  if (inputs.liveHole != null) {
    items.add(
      NotificationItem(
        id: 'round:live',
        category: NotificationCategory.roundReminder,
        message: 'Your round is in progress',
        detail:
            'Hole ${inputs.liveHole}'
            '${inputs.liveCourse == null ? '' : ' at ${inputs.liveCourse}'}'
            ' — pick up where you left off',
        when: 'Now',
        location: AppRoutes.roundScorecard,
        icon: Icons.play_circle_outline,
      ),
    );
  }

  for (final request in inputs.incomingRequests) {
    items.add(
      NotificationItem(
        id: 'request:${request.friend.id}',
        category: NotificationCategory.friendActivity,
        message: '${request.friend.displayName} wants to play with you',
        detail: 'Handicap ${handicapLabel(request.friend.handicap)}',
        when: request.sentDescription,
        location: AppRoutes.friendRequests,
        icon: Icons.person_add_alt_1_outlined,
        sample: true,
      ),
    );
  }

  final countdown = roundCountdown(inputs.now, inputs.roundDay);
  if (countdown != null && inputs.liveHole == null && inputs.roundPlanned) {
    final days = daysUntilWeekday(inputs.now, inputs.roundDay) ?? 0;
    items.add(
      NotificationItem(
        id: 'round:${inputs.roundDay}:${inputs.roundTeeTime}',
        category: NotificationCategory.roundReminder,
        message: switch (days) {
          0 => "It's round day — you tee off at ${inputs.roundTeeTime}",
          1 => 'Tomorrow you tee off at ${inputs.roundTeeTime}',
          _ => 'Your round starts in $days days',
        },
        detail:
            '${inputs.roundCourse} · ${inputs.roundDay}, '
            '${inputs.roundTeeTime}',
        when: switch (days) {
          0 => 'Today',
          1 => 'Tomorrow',
          _ => 'In $days days',
        },
        location: AppRoutes.rounds,
        sample: true,
      ),
    );
  }

  final trip = inputs.nextTrip;
  if (trip != null) {
    final days = trip.daysToGo;
    items.add(
      NotificationItem(
        id: 'trip:${trip.id}:countdown',
        category: NotificationCategory.tripUpdate,
        message: switch (days) {
          <= 0 => '${trip.name} is under way',
          1 => '${trip.name} starts tomorrow',
          _ => '${trip.name} is $days days away',
        },
        detail: trip.destination,
        when: days <= 0 ? 'Now' : 'In $days days',
        location: AppRoutes.tripDetails(trip.id),
        sample: inputs.tripIsSample,
      ),
    );
    if (inputs.tripStillToReply > 0) {
      final n = inputs.tripStillToReply;
      items.add(
        NotificationItem(
          id: 'trip:${trip.id}:reply:$n',
          category: NotificationCategory.tripUpdate,
          message:
              '$n ${n == 1 ? 'mate has' : 'mates have'} not replied to '
              '${trip.name}',
          detail: 'Nudge them, or invite someone else',
          location: AppRoutes.tripInvite(trip.id),
          icon: Icons.mark_email_unread_outlined,
          sample: inputs.tripIsSample,
        ),
      );
    }
  }

  final headline = inputs.tableHeadline;
  if (headline != null && inputs.tableLocation != null) {
    items.add(
      NotificationItem(
        id: 'table:${inputs.tableId}:$headline',
        category: NotificationCategory.friendActivity,
        message: headline,
        detail: inputs.tableDetail,
        location: inputs.tableLocation!,
        icon: Icons.leaderboard_outlined,
        sample: true,
      ),
    );
  }

  if (inputs.earnedAchievements > 0) {
    final n = inputs.earnedAchievements;
    items.add(
      NotificationItem(
        id: 'achievements:$n',
        category: NotificationCategory.systemUpdate,
        message: n == 1
            ? "You've earned an achievement"
            : "You've earned $n achievements",
        detail: 'See them on your trophy shelf',
        location: AppRoutes.profile,
        icon: Icons.emoji_events_outlined,
      ),
    );
  }

  if (!inputs.hasHandicap) {
    items.add(
      const NotificationItem(
        id: 'tip:handicap',
        category: NotificationCategory.systemUpdate,
        message: 'Add your handicap',
        detail: 'So your net scores and stats are right',
        location: AppRoutes.profileSettings,
        icon: Icons.speed_outlined,
      ),
    );
  }

  items.add(
    NotificationItem(
      id: 'welcome',
      category: NotificationCategory.systemUpdate,
      message: 'Welcome to Qaddy, ${inputs.golferName}',
      detail: inputs.sampleOn
          ? 'Your Sample Clubhouse is ready: pretend mates, a group and a '
                'trip to explore. Remove it any time in Settings.'
          : 'Score a round, plan a trip, invite your mates',
      when: 'Welcome',
      location: inputs.sampleOn ? AppRoutes.profileSettings : AppRoutes.rounds,
      icon: Icons.waving_hand_outlined,
    ),
  );

  return items;
}

/// Whether [location] is one of the five tabs (and so is gone to, not pushed).
bool isTabLocation(String location) => const <String>{
  AppRoutes.home,
  AppRoutes.rounds,
  AppRoutes.trips,
  AppRoutes.friends,
  AppRoutes.profile,
}.contains(location);
