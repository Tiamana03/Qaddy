/// Opening things outside the app: phone calls, websites and maps.
///
/// Screens ask for a link to be opened through [linkLauncherProvider] and
/// never talk to the `url_launcher` plugin directly, so tests substitute a
/// fake and a platform that cannot open a link degrades to "copied instead".
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens links outside the app.
// An interface (not a function) so tests can substitute a recording fake.
// ignore: one_member_abstracts
abstract class LinkLauncher {
  /// Opens [uri] in the right app (dialler, browser, maps). Returns `false`
  /// when nothing could open it, so the caller can offer a fallback.
  Future<bool> open(Uri uri);
}

/// The real launcher, backed by `url_launcher`.
class UrlLauncherLinkLauncher implements LinkLauncher {
  const UrlLauncherLinkLauncher();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // No handler, no plugin (tests, unsupported platforms): not an error
      // the golfer needs to see — the caller falls back to copying.
      return false;
    }
  }
}

/// The app's link launcher. Tests override this with a recording fake.
final linkLauncherProvider = Provider<LinkLauncher>(
  (ref) => const UrlLauncherLinkLauncher(),
);

/// A `tel:` link for [phone], keeping only what a dialler understands (digits
/// and a leading `+`), so "(03) 5550 0141" dials "0355500141".
Uri phoneUri(String phone) {
  final trimmed = phone.trim();
  final digits = trimmed.replaceAll(RegExp('[^0-9]'), '');
  return Uri(
    scheme: 'tel',
    path: trimmed.startsWith('+') ? '+$digits' : digits,
  );
}

/// An `https:` link for a website typed as "www.club.com" or
/// "https://club.com".
Uri websiteUri(String website) {
  final trimmed = website.trim();
  final hasScheme = RegExp('^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
  return Uri.parse(hasScheme ? trimmed : 'https://$trimmed');
}

/// A map search for [place] (an address or a name).
Uri mapSearchUri(String place) => Uri.https(
  'www.google.com',
  '/maps/search/',
  <String, String>{'api': '1', 'query': place},
);

/// Directions to [destination], from [origin] when given (otherwise from the
/// device's own location).
Uri mapDirectionsUri({required String destination, String? origin}) =>
    Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'destination': destination,
      if (origin != null && origin.isNotEmpty) 'origin': origin,
    });
