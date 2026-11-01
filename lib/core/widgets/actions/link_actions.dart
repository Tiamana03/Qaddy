/// Small actions every screen needs: tell the golfer something, copy a
/// value, open a link or share text — each degrading to a clear fallback
/// rather than a dead tap.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/services/share_service.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// Shows a short confirmation at the bottom of the screen.
void tellUser(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Copies [text] to the clipboard and says [confirmation].
Future<void> copyToClipboard(
  BuildContext context,
  String text,
  String confirmation,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  QaddyHaptics.light();
  if (context.mounted) {
    tellUser(context, confirmation);
  }
}

/// Opens [uri] outside the app (dialler, browser, maps). When nothing can open
/// it — no handler, or a platform without one — copies [fallback] instead and
/// says so, so the golfer is never left with a dead tap.
Future<void> openLinkOrCopy(
  BuildContext context,
  WidgetRef ref, {
  required Uri uri,
  required String fallback,
  required String label,
}) async {
  final opened = await ref.read(linkLauncherProvider).open(uri);
  if (opened) {
    QaddyHaptics.light();
    return;
  }
  if (context.mounted) {
    await copyToClipboard(
      context,
      fallback,
      'Could not open $label — copied it instead',
    );
  }
}

/// Shares [text] through the system share sheet. Where there is none, copies
/// it and says so.
Future<void> shareOrCopy(
  BuildContext context,
  WidgetRef ref, {
  required String text,
  String? subject,
}) async {
  final outcome = await ref
      .read(shareServiceProvider)
      .shareText(text, subject: subject);
  if (outcome == ShareOutcome.unavailable && context.mounted) {
    await copyToClipboard(context, text, 'Copied — paste it into a message');
  }
}
