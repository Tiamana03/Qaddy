/// One item in the golfer's bag: a club (or the ball) with the model they play,
/// how far it carries, how much they trust it and a note to self.
library;

/// The kind of club, which decides how it is grouped and whether it has a
/// carry distance.
enum ClubFamily {
  wood,
  hybrid,
  iron,
  wedge,
  putter,
  ball;

  /// Whether a carry distance means anything for this kind of club.
  bool get hasCarry => this != putter && this != ball;
}

/// A club or the ball, as the golfer has set it up.
class BagClub {
  const BagClub({
    required this.id,
    required this.name,
    required this.family,
    required this.model,
    this.carryMetres,
    this.note = '',
    this.confidence = 0,
  });

  /// A stable id ("7-iron") that edits are saved against.
  final String id;

  /// What the golfer calls it ("7 iron").
  final String name;

  /// What kind of club it is.
  final ClubFamily family;

  /// The product ("TaylorMade P790").
  final String model;

  /// How far it carries, in metres. `null` for the putter and the ball.
  final double? carryMetres;

  /// A note to self ("Aim a touch left; plays 5 m longer downhill").
  final String note;

  /// How much the golfer trusts it, 0 (not set) to 5 (the go-to).
  final int confidence;

  /// Whether it has a carry distance to chart.
  bool get hasCarry => family.hasCarry && carryMetres != null;

  /// Whether the golfer has written a note.
  bool get hasNote => note.trim().isNotEmpty;

  /// Whether the golfer has said which model they play.
  bool get hasModel => model.trim().isNotEmpty;

  /// Returns a changed copy. The id, name and family never change.
  BagClub copyWith({
    String? model,
    double? carryMetres,
    String? note,
    int? confidence,
  }) => BagClub(
    id: id,
    name: name,
    family: family,
    model: model ?? this.model,
    carryMetres: carryMetres ?? this.carryMetres,
    note: note ?? this.note,
    confidence: confidence ?? this.confidence,
  );
}
