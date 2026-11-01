/// The moment the Dashboard measures "today" from. Tests override it so a
/// greeting or a countdown never depends on the real calendar.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns the current time.
final dashboardClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
