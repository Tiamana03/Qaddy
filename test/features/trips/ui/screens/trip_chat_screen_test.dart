import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/trip_chat_screen.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_message_bubble.dart';

import '../../trips_test_harness.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  String tripId = melbourneId,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 1400);
  return pumpTrips(tester, TripChatScreen(tripId: tripId));
}

Finder get _sendButton => find.byTooltip('Send message');

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

bool _sendEnabled(WidgetTester tester) =>
    tester
        .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send_rounded))
        .onPressed !=
    null;

void main() {
  testWidgets('shows the conversation with senders, times and day headings', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Looking forward to this trip!'), findsOneWidget);
    expect(find.text("Can't wait."), findsOneWidget);
    expect(find.text('See everyone Saturday morning.'), findsOneWidget);
    expect(find.text('7:12 PM'), findsOneWidget);
    expect(find.byType(ChatDaySeparator), findsNWidgets(3));
    expect(find.text('Luke'), findsWidgets);
  });

  testWidgets('puts my messages on the right and everyone else on the left', (
    tester,
  ) async {
    await _pump(tester);

    final mine = tester.getTopRight(find.text('Looking forward to this trip!'));
    final theirs = tester.getTopLeft(find.text("Can't wait."));

    expect(mine.dx, greaterThan(200));
    expect(theirs.dx, lessThan(200));
  });

  testWidgets('shows a profile circle for other people, not for me', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(ChatAvatar), findsWidgets);
    final mineStartsRun = find.ancestor(
      of: find.text('Looking forward to this trip!'),
      matching: find.byType(TripMessageBubble),
    );
    expect(
      find.descendant(of: mineStartsRun, matching: find.byType(ChatAvatar)),
      findsNothing,
    );
  });

  testWidgets('the send button is disabled until there is text to send', (
    tester,
  ) async {
    await _pump(tester);

    expect(_sendEnabled(tester), isFalse);
    await _type(tester, '   ');
    expect(_sendEnabled(tester), isFalse);
    await _type(tester, 'Hello');
    expect(_sendEnabled(tester), isTrue);
  });

  testWidgets('sending adds the message, clears the box and stores it', (
    tester,
  ) async {
    final container = await _pump(tester);
    final before = container.read(tripPlanProvider(melbourneId)).messages;

    await _type(tester, 'Tee time sorted');
    await tester.tap(_sendButton);
    await tester.pump();

    expect(find.text('Tee time sorted'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    final after = container.read(tripPlanProvider(melbourneId)).messages;
    expect(after, hasLength(before.length + 1));
    expect(after.last.sender, currentUserName);

    // Let the placeholder delivery timers finish.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('read receipts tick through sent, delivered and read', (
    tester,
  ) async {
    final container = await _pump(tester);

    await _type(tester, 'Ping');
    await tester.tap(_sendButton);
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byIcon(Icons.check), findsNothing);
    expect(
      container.read(tripPlanProvider(melbourneId)).messages.last.status,
      MessageStatus.delivered,
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      container.read(tripPlanProvider(melbourneId)).messages.last.status,
      MessageStatus.read,
    );
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('with read receipts off nothing becomes read and no ticks show', (
    tester,
  ) async {
    final container = await _pump(tester);
    container
        .read(tripsProvider.notifier)
        .updatePlan(
          melbourneId,
          (plan) => plan.copyWith(
            chatSettings: plan.chatSettings.copyWith(readReceipts: false),
          ),
        );
    await tester.pump();

    await _type(tester, 'Ping');
    await tester.tap(_sendButton);
    await tester.pump(const Duration(seconds: 5));

    expect(
      container.read(tripPlanProvider(melbourneId)).messages.last.status,
      MessageStatus.delivered,
    );
    expect(find.byIcon(Icons.done_all), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('shows a typing indicator briefly after sending', (tester) async {
    await _pump(tester);

    await _type(tester, 'Ping');
    await tester.tap(_sendButton);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(ChatTypingIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(ChatTypingIndicator), findsNothing);
  });

  testWidgets('typing indicators can be turned off', (tester) async {
    final container = await _pump(tester);
    container
        .read(tripsProvider.notifier)
        .updatePlan(
          melbourneId,
          (plan) => plan.copyWith(
            chatSettings: plan.chatSettings.copyWith(typingIndicators: false),
          ),
        );
    await tester.pump();

    await _type(tester, 'Ping');
    await tester.tap(_sendButton);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(ChatTypingIndicator), findsNothing);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the emoji tray inserts an emoji into the message', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('Add emoji'));
    await tester.pump();
    await tester.tap(find.text('⛳'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '⛳',
    );
    expect(_sendEnabled(tester), isTrue);

    await tester.tap(find.byTooltip('Show keyboard'));
    await tester.pump();
    expect(find.text('⛳'), findsOneWidget); // only in the field now
  });

  testWidgets('a trip with no messages invites the first one', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final id = container
        .read(tripsProvider.notifier)
        .createTrip(
          NewTripDraft(
            name: 'Barossa',
            destination: 'Barossa Valley, Australia',
            startDate: DateTime(2027, 3, 12),
            endDate: DateTime(2027, 3, 14),
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: QaddyTheme.dark,
          home: TripChatScreen(tripId: id),
        ),
      ),
    );

    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('shows a muted marker when notifications are muted', (
    tester,
  ) async {
    final container = await _pump(tester);
    container
        .read(tripsProvider.notifier)
        .updatePlan(
          melbourneId,
          (plan) => plan.copyWith(
            chatSettings: plan.chatSettings.copyWith(muted: true),
          ),
        );
    await tester.pump();

    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
  });
}
