/// What the app says about itself in Settings and About.
///
/// There is no package for reading `pubspec.yaml` at run time (and adding one
/// for this alone is unjustified), so the version is written here and a test
/// checks it against `pubspec.yaml`, so the two cannot drift apart.
library;

/// The version, as in `pubspec.yaml` before the `+`.
const String appVersion = '0.1.0';

/// The build number, as in `pubspec.yaml` after the `+`.
const String appBuild = '1';

/// Which release this is.
const String appReleaseLabel = 'Soft launch';

/// "0.1.0 (1)".
const String appVersionLabel = '$appVersion ($appBuild)';
