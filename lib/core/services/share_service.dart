/// Sharing text — an invite link, an itinerary — through the system share
/// sheet.
///
/// Screens share through [shareServiceProvider] and never talk to the
/// `share_plus` plugin directly, so tests substitute a fake and a platform
/// with no share sheet degrades to "copied instead".
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// How a share request ended.
enum ShareOutcome {
  /// The golfer picked somewhere to send it (or the platform doesn't say).
  shared,

  /// The share sheet was closed without choosing anything.
  dismissed,

  /// There is no share sheet here; the caller should copy instead.
  unavailable,
}

/// Shares text with other apps.
// An interface (not a function) so tests can substitute a recording fake.
// ignore: one_member_abstracts
abstract class ShareService {
  /// Opens the system share sheet with [text] (and an optional [subject],
  /// used as an email subject).
  Future<ShareOutcome> shareText(String text, {String? subject});
}

/// The real share service, backed by `share_plus`.
class SharePlusShareService implements ShareService {
  const SharePlusShareService();

  @override
  Future<ShareOutcome> shareText(String text, {String? subject}) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, subject: subject),
      );
      return switch (result.status) {
        ShareResultStatus.success => ShareOutcome.shared,
        ShareResultStatus.dismissed => ShareOutcome.dismissed,
        ShareResultStatus.unavailable => ShareOutcome.unavailable,
      };
    } on Object {
      return ShareOutcome.unavailable;
    }
  }
}

/// The app's share service. Tests override this with a recording fake.
final shareServiceProvider = Provider<ShareService>(
  (ref) => const SharePlusShareService(),
);
