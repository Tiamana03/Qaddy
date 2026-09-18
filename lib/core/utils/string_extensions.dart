/// See `docs/sprints/sprint-01-4-responsive-layout.md`'s
/// `string_extensions.dart` section: reusable String helper methods —
/// capitalize, title case, null-safe formatting. No business logic.
library;

/// Reusable `String` helpers.
extension StringExtensions on String {
  /// Capitalises the first character; leaves the rest unchanged.
  ///
  /// An empty string is returned unchanged.
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalises the first character of every word, splitting on spaces.
  String toTitleCase() {
    if (isEmpty) {
      return this;
    }
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

/// Null-safe `String?` helpers.
extension NullableStringExtensions on String? {
  /// Whether this string is `null` or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// This string, or [fallback] if it is `null` or empty.
  String orDefault(String fallback) => isNullOrEmpty ? fallback : this!;
}
