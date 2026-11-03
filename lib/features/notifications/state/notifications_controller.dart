/// The store behind Notifications: what the golfer has read, which kinds they
/// have switched off, and the feed worked out from the rest of the app.
///
/// What was read and what is switched off live on the device (see
/// `DocumentStorage`). The notifications themselves are never stored — they are
/// derived from the golfer's real rounds, mates and trips each time (see
/// `logic/notification_feed.dart`). The bell, the feed and Settings all read
/// through the providers here.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/notifications/logic/notification_feed.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// The key the state is kept under.
const String notificationsStorageKey = 'qaddy.notifications.v1';

/// The notifications' storage. `main` overrides it with on-device storage.
final notificationsStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// What the golfer has read and which kinds they have switched off.
class NotificationsState {
  const NotificationsState({
    this.read = const <String>{},
    this.muted = const <NotificationCategory>{},
  });

  /// The ids of notifications already seen.
  final Set<String> read;

  /// The kinds the golfer does not want.
  final Set<NotificationCategory> muted;
}

/// The notifications store.
final notificationsProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

/// Reads and mutes.
class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    final storage = ref.read(notificationsStorageProvider);
    // Save after every change from here on (the starting state is not one).
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(storage.write(encodeNotificationsState(next)));
    });

    final stored = storage.read();
    return (stored == null ? null : decodeNotificationsState(stored)) ??
        const NotificationsState();
  }

  /// Marks [id] as read.
  void markRead(String id) {
    if (state.read.contains(id)) {
      return;
    }
    state = NotificationsState(
      read: <String>{...state.read, id},
      muted: state.muted,
    );
  }

  /// Marks every id in [ids] as read.
  void markAllRead(Iterable<String> ids) {
    final next = <String>{...state.read, ...ids};
    if (next.length == state.read.length) {
      return;
    }
    state = NotificationsState(read: next, muted: state.muted);
  }

  /// Switches [category] on or off.
  void setEnabled(NotificationCategory category, {required bool enabled}) {
    final muted = <NotificationCategory>{...state.muted};
    if (enabled) {
      muted.remove(category);
    } else {
      muted.add(category);
    }
    state = NotificationsState(read: state.read, muted: muted);
  }
}

/// The state as the JSON document kept on the device.
String encodeNotificationsState(NotificationsState state) =>
    jsonEncode(<String, Object?>{
      'version': 1,
      'read': state.read.toList()..sort(),
      'muted': <String>[for (final c in state.muted) c.name]..sort(),
    });

/// Reads a document written by [encodeNotificationsState]; `null` when it
/// cannot be read, so the golfer simply starts with nothing read.
NotificationsState? decodeNotificationsState(String document) {
  try {
    final json = jsonDecode(document);
    if (json is! Map<String, dynamic>) {
      return null;
    }
    final read = json['read'];
    final muted = json['muted'];
    return NotificationsState(
      read: <String>{if (read is List) ...read.whereType<String>()},
      muted: <NotificationCategory>{
        if (muted is List)
          for (final name in muted.whereType<String>())
            for (final c in NotificationCategory.values)
              if (c.name == name) c,
      },
    );
  } on FormatException {
    return null;
  }
}

/// Everything there is to tell the golfer right now, whether or not they want
/// to hear it: worked out from their real rounds, mates and trips.
final notificationFeedProvider = Provider<List<NotificationItem>>((ref) {
  final now = ref.watch(dashboardClockProvider)();
  final golfer = ref.watch(golferDetailsProvider);
  final live = ref.watch(liveRoundProvider);
  final history = ref.watch(roundHistoryProvider);
  final stats = CareerStats.of(history, you: currentUserName);
  final trips = ref.watch(upcomingTripsProvider);
  final nextTrip = trips.isEmpty ? null : trips.first;
  final race = SeasonRace.of(
    saturdayBoysLeaderboard,
    yourName: currentUserName,
    roundsRemaining: saturdayBoysSeasonSummary.roundsRemaining,
  );

  return buildNotificationFeed(
    NotificationInputs(
      golferName: golfer.firstName,
      hasHandicap: golfer.handicap != null,
      now: now,
      roundDay: upcomingRound.date,
      roundCourse: upcomingRound.course,
      roundTeeTime: upcomingRound.teeTime,
      liveHole: live == null ? null : live.currentHole + 1,
      liveCourse: live?.course,
      incomingRequests: ref.watch(incomingRequestsProvider),
      earnedAchievements: achievementsFor(
        stats,
      ).where((a) => a.unlocked).length,
      nextTrip: nextTrip == null
          ? null
          : (
              id: nextTrip.id,
              name: nextTrip.name,
              destination: nextTrip.destination,
              daysToGo: _daysToGo(nextTrip, now),
            ),
      tripStillToReply: nextTrip == null
          ? 0
          : ref.watch(tripPlanProvider(nextTrip.id)).pendingMembers.length,
      tableId: saturdayBoys.id,
      tableHeadline: '${race.headline} in the ${saturdayBoys.name} table',
      tableDetail: <String>[?race.chase, race.roundsLeft].join(' · '),
      tableLocation: AppRoutes.friendsGroup(saturdayBoys.id),
    ),
  );
});

int _daysToGo(Trip trip, DateTime now) {
  final countdown = tripCountdown(trip, now: now);
  return int.tryParse(countdown.value) ?? 0;
}

/// The feed the golfer wants (kinds they switched off are left out), each
/// marked read or not.
final notificationEntriesProvider = Provider<List<NotificationEntry>>((ref) {
  final feed = ref.watch(notificationFeedProvider);
  final state = ref.watch(notificationsProvider);
  return <NotificationEntry>[
    for (final item in feed)
      if (!state.muted.contains(item.category))
        NotificationEntry(item: item, isRead: state.read.contains(item.id)),
  ];
});

/// How many notifications the golfer has not seen — what the bell shows.
final unreadNotificationCountProvider = Provider<int>(
  (ref) => ref.watch(
    notificationEntriesProvider.select(
      (entries) => entries.where((e) => !e.isRead).length,
    ),
  ),
);
