/// The store behind the golfer's own details.
///
/// It lives on the device (see `DocumentStorage`): loaded when the app starts,
/// saved after every change. Screens read through [golferProvider] and change
/// it only through [GolferController].
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';

/// The profile's storage. `main` overrides it with on-device storage.
final golferStorageProvider = Provider<DocumentStorage>(
  (ref) => const NoDocumentStorage(),
);

/// The key the profile is kept under.
const String golferStorageKey = 'qaddy.golfer.v1';

/// The clock the profile is stamped with. Tests override it.
final golferClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// The golfer's details, or `null` until they have been asked for.
final golferProvider = NotifierProvider<GolferController, GolferProfile?>(
  GolferController.new,
);

/// What the app calls the golfer: their first name, or the placeholder
/// golfer's until they have set one. Use it for anything the golfer reads
/// ("– Sam", "Good morning, Sam").
final golferNameProvider = Provider<String>(
  (ref) => ref.watch(golferProvider)?.firstName ?? currentUserName,
);

/// Sets and changes the golfer's details.
class GolferController extends Notifier<GolferProfile?> {
  @override
  GolferProfile? build() {
    final storage = ref.read(golferStorageProvider);
    // Save after every change from here on (the starting state is not one).
    listenSelf((previous, next) {
      if (previous == null && next == null) {
        return;
      }
      if (next != null) {
        unawaited(storage.write(encodeGolfer(next)));
      }
    });

    final stored = storage.read();
    final golfer = stored == null ? null : decodeGolfer(stored);
    useGolfer(golfer);
    return golfer;
  }

  /// Saves the golfer's details. The name is trimmed and, once set, kept (the
  /// golfer's rounds are recorded under it); a blank course or no handicap
  /// means "not given". The date the golfer joined is kept once set.
  void save({required String firstName, double? handicap, String? homeCourse}) {
    final name = state?.firstName ?? firstName.trim();
    if (name.isEmpty) {
      return;
    }
    final course = homeCourse?.trim();
    final saved = GolferProfile(
      firstName: name.length > maxProfileTextLength
          ? name.substring(0, maxProfileTextLength)
          : name,
      handicap: handicap?.clamp(minHandicap, maxHandicap),
      homeCourse: course == null || course.isEmpty
          ? null
          : course.length > maxProfileTextLength
          ? course.substring(0, maxProfileTextLength)
          : course,
      joinedAt: state?.joinedAt ?? ref.read(golferClockProvider)(),
    );
    useGolfer(saved);
    state = saved;
  }
}

/// Who the app shows before the golfer has set up (and in tests): the shared
/// placeholder golfer, see `docs/standards/placeholder-data.md`.
final GolferProfile placeholderGolfer = GolferProfile(
  firstName: currentUserName,
  handicap: 8.4,
  homeCourse: 'Richmond Golf Club',
  joinedAt: DateTime(2024),
);

/// The golfer's details, always present: theirs once they have set up, the
/// placeholder golfer's until then. Screens read this rather than the nullable
/// [golferProvider].
final golferDetailsProvider = Provider<GolferProfile>(
  (ref) => ref.watch(golferProvider) ?? placeholderGolfer,
);
