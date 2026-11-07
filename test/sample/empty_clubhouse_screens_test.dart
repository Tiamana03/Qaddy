// What a golfer who starts with an empty clubhouse sees: honest, inviting
// screens rather than pretend people.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/community/ui/screens/activity_feed_screen.dart';
import 'package:qaddy/features/community/ui/screens/friend_requests_screen.dart';
import 'package:qaddy/features/community/ui/screens/friends_home_screen.dart';
import 'package:qaddy/features/community/ui/screens/friends_list_screen.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:qaddy/features/dashboard/ui/widgets/home_hero.dart';
import 'package:qaddy/features/groups/ui/screens/groups_screen.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

import '../support/app_test_harness.dart';
import '../support/memory_document_storage.dart';

/// The golfer chose an empty clubhouse: the flag, and the stored choice the
/// provider reads back.
List<Override> _empty() {
  useSampleClubhouse(on: false);
  addTearDown(resetSampleClubhouseForTests);
  return <Override>[
    sampleStorageProvider.overrideWithValue(
      MemoryDocumentStorage(
        encodeSampleChoice(const SampleChoice(enabled: false, decided: true)),
      ),
    ),
  ];
}

void main() {
  testWidgets('Home is just a hero and four doors', (tester) async {
    final off = _empty();
    await pumpFriends(tester, const DashboardScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.byType(HomeHero), findsOneWidget);
    expect(find.text('Upcoming round'), findsOneWidget);
    // Nothing is planned, so the round is one to start, not to get ready for.
    expect(find.text('Start round'), findsOneWidget);
    expect(find.text('Get ready'), findsNothing);
    expect(find.text('Sample'), findsNothing);
    expect(find.text('Start a round'), findsWidgets);
    // A new golfer sees a hero and four doors: nothing empty, nothing pretend.
    expect(find.text('Invite a mate'), findsOneWidget);
    expect(find.text('Next trip'), findsNothing);
    expect(find.text('Your mates'), findsNothing);
    expect(find.text('From your sample mates'), findsNothing);
    expect(find.textContaining('Saturday Boys'), findsNothing);
  });

  testWidgets('Rounds is just you, ready when you are', (tester) async {
    final off = _empty();
    await pumpFriends(tester, const RoundsScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.text('Your round'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
    expect(find.text('Start round'), findsOneWidget);
    expect(find.textContaining('1 playing'), findsNothing);
    expect(find.text('On the course (sample)'), findsNothing);
    expect(find.textContaining('standard par-72 layout'), findsOneWidget);
    expect(find.textContaining('sample 18-hole layout'), findsNothing);
  });

  testWidgets('Friends List invites a first mate', (tester) async {
    final off = _empty();
    await pumpFriends(tester, const FriendsListScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.text('No mates yet'), findsOneWidget);
    expect(find.text('Invite a mate'), findsOneWidget);
  });

  testWidgets('Activity Feed and Friend Requests say what will come', (
    tester,
  ) async {
    final off = _empty();
    await pumpFriends(tester, const ActivityFeedScreen(), overrides: off);
    await tester.pumpAndSettle();
    expect(find.text('Nothing yet'), findsOneWidget);
    expect(find.text('Invite a mate'), findsOneWidget);

    await pumpFriends(tester, const FriendRequestsScreen(), overrides: off);
    await tester.pumpAndSettle();
    expect(find.text('No requests'), findsOneWidget);
    expect(find.text('Invite a mate'), findsOneWidget);
  });

  testWidgets('Friends invites you to build your squad', (tester) async {
    final off = _empty();
    await pumpFriends(tester, const FriendsHomeScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.text('Build your squad'), findsOneWidget);
    expect(find.text('Sample Clubhouse'), findsNothing);
    expect(find.text('Your clubs'), findsNothing);
    expect(find.text('Latest from mates'), findsNothing);
  });

  testWidgets('Groups says there are none, and where to see how one works', (
    tester,
  ) async {
    final off = _empty();
    await pumpFriends(tester, const GroupsScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.text('No groups yet'), findsWidgets);
    expect(find.text('Saturday Boys'), findsNothing);
    expect(find.text('Open Settings'), findsOneWidget);
  });

  testWidgets('Trips starts empty', (tester) async {
    final off = _empty();
    await pumpFriends(tester, const TripsScreen(), overrides: off);
    await tester.pumpAndSettle();

    expect(find.textContaining('Melbourne'), findsNothing);
    expect(find.textContaining('Sample'), findsNothing);
  });

  testWidgets(
    'with it on, Friends explains what is sample and where to remove it',
    (tester) async {
      await pumpFriends(tester, const FriendsHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sample Clubhouse'), findsOneWidget);
      expect(
        find.text('Keep it, edit it or remove it in Settings'),
        findsOneWidget,
      );
    },
  );
}
