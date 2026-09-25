/// A Trip Chat message — see `docs/architecture/trip-data-model.md`'s
/// "Trip Message" section and placeholder-trip-data.md's "Chat" section.
library;

/// One placeholder chat message.
class TripMessage {
  const TripMessage({
    required this.sender,
    required this.message,
    required this.time,
  });

  /// The sender's name.
  final String sender;

  /// The message text.
  final String message;

  /// The sent time, as sourced (e.g. "7:12 PM").
  final String time;
}
