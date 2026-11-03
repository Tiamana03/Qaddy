import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';

import '../../../support/memory_document_storage.dart';

ProviderContainer _container([MemoryDocumentStorage? storage]) {
  final container = ProviderContainer(
    overrides: <Override>[
      dashboardClockProvider.overrideWithValue(() => DateTime(2026, 11, 1, 9)),
      if (storage != null)
        notificationsStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('everything starts unread, and the bell counts it', () {
    final c = _container();

    final entries = c.read(notificationEntriesProvider);

    expect(entries, isNotEmpty);
    expect(entries.every((e) => !e.isRead), isTrue);
    expect(c.read(unreadNotificationCountProvider), entries.length);
  });

  test('reading one lowers the bell by one', () {
    final c = _container();
    final before = c.read(unreadNotificationCountProvider);
    final id = c.read(notificationEntriesProvider).first.item.id;

    c.read(notificationsProvider.notifier).markRead(id);

    expect(c.read(unreadNotificationCountProvider), before - 1);
    final entry = c
        .read(notificationEntriesProvider)
        .firstWhere((e) => e.item.id == id);
    expect(entry.isRead, isTrue);
  });

  test('marking all read clears the bell', () {
    final c = _container();
    final ids = c.read(notificationEntriesProvider).map((e) => e.item.id);

    c.read(notificationsProvider.notifier).markAllRead(ids);

    expect(c.read(unreadNotificationCountProvider), 0);
  });

  test('a kind switched off leaves the feed and the bell', () {
    final c = _container();
    final before = c.read(notificationEntriesProvider);

    c
        .read(notificationsProvider.notifier)
        .setEnabled(NotificationCategory.tripUpdate, enabled: false);

    final after = c.read(notificationEntriesProvider);
    expect(after.length, lessThan(before.length));
    expect(
      after.any((e) => e.item.category == NotificationCategory.tripUpdate),
      isFalse,
    );
    expect(c.read(unreadNotificationCountProvider), after.length);

    c
        .read(notificationsProvider.notifier)
        .setEnabled(NotificationCategory.tripUpdate, enabled: true);
    expect(c.read(notificationEntriesProvider).length, before.length);
  });

  test('what was read and switched off survives a restart', () async {
    final storage = MemoryDocumentStorage();
    final first = _container(storage);
    final id = first.read(notificationEntriesProvider).first.item.id;
    first.read(notificationsProvider.notifier)
      ..markRead(id)
      ..setEnabled(NotificationCategory.systemUpdate, enabled: false);
    await Future<void>.delayed(Duration.zero);

    final second = _container(storage);

    expect(second.read(notificationsProvider).read, contains(id));
    expect(
      second.read(notificationsProvider).muted,
      contains(NotificationCategory.systemUpdate),
    );
  });

  test('an unreadable document starts with nothing read', () {
    for (final bad in <String>['{not json', '[]', '"x"']) {
      final c = _container(MemoryDocumentStorage(bad));
      expect(c.read(notificationsProvider).read, isEmpty, reason: bad);
    }
  });
}
