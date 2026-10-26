/// A Trip Chat message — see `docs/architecture/trip-data-model.md`'s
/// "Trip Message" section.
library;

/// Delivery progress of a message. Release 1 has no real delivery, so the
/// state advances on a short timer purely as a placeholder for read receipts.
enum MessageStatus { sent, delivered, read }

/// One chat message.
class TripMessage {
  const TripMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentAt,
    this.status = MessageStatus.read,
  });

  /// Unique identifier within the trip.
  final String id;

  /// The sender's name.
  final String sender;

  /// The message text.
  final String text;

  /// When it was sent (local date and time).
  final DateTime sentAt;

  /// Delivery progress (only meaningful for the current user's messages).
  final MessageStatus status;

  /// A copy with the given fields replaced.
  TripMessage copyWith({MessageStatus? status}) {
    return TripMessage(
      id: id,
      sender: sender,
      text: text,
      sentAt: sentAt,
      status: status ?? this.status,
    );
  }
}

/// Per-trip chat preferences.
class TripChatSettings {
  const TripChatSettings({
    this.muted = false,
    this.readReceipts = true,
    this.typingIndicators = true,
  });

  /// Whether notifications for this chat are muted.
  final bool muted;

  /// Whether sent messages show delivery/read ticks.
  final bool readReceipts;

  /// Whether the "is typing…" indicator is shown.
  final bool typingIndicators;

  /// A copy with the given fields replaced.
  TripChatSettings copyWith({
    bool? muted,
    bool? readReceipts,
    bool? typingIndicators,
  }) {
    return TripChatSettings(
      muted: muted ?? this.muted,
      readReceipts: readReceipts ?? this.readReceipts,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }
}
