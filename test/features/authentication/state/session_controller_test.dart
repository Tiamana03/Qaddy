import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/authentication/models/session.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';

import '../../../support/memory_document_storage.dart';

ProviderContainer _container(MemoryDocumentStorage storage) {
  final container = ProviderContainer(
    overrides: <Override>[sessionStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a new golfer has seen nothing yet', () {
    final c = _container(MemoryDocumentStorage());

    final session = c.read(sessionProvider);

    expect(session.onboardingComplete, isFalse);
    expect(session.isGuest, isFalse);
  });

  test('finishing the introduction is remembered', () async {
    final storage = MemoryDocumentStorage();
    final first = _container(storage);
    first.read(sessionProvider.notifier).completeOnboarding();
    await Future<void>.delayed(Duration.zero);

    final second = _container(storage);

    expect(second.read(sessionProvider).onboardingComplete, isTrue);
    expect(second.read(sessionProvider).isGuest, isFalse);
  });

  test('continuing as a guest also finishes the introduction', () async {
    final storage = MemoryDocumentStorage();
    final first = _container(storage);
    first.read(sessionProvider.notifier).continueAsGuest();
    await Future<void>.delayed(Duration.zero);

    final second = _container(storage);

    expect(second.read(sessionProvider).onboardingComplete, isTrue);
    expect(second.read(sessionProvider).isGuest, isTrue);
  });

  test('an unreadable document starts from the introduction', () {
    for (final bad in <String>['{not json', '[1, 2]', '"hello"']) {
      final c = _container(MemoryDocumentStorage(bad));
      expect(c.read(sessionProvider).onboardingComplete, isFalse, reason: bad);
    }
  });

  test('the document round-trips', () {
    const session = AuthSession(onboardingComplete: true, isGuest: true);

    final decoded = decodeSession(encodeSession(session))!;

    expect(decoded.onboardingComplete, isTrue);
    expect(decoded.isGuest, isTrue);
  });
}
