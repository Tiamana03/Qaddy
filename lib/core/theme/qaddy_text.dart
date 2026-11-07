/// The text sizes the approved mockups actually use, measured against them.
///
/// The Typography Library's scale (`QaddyTypography`: display 72, h1 40 …)
/// names the families of style; the mockups set most of the interface in
/// smaller sizes than that scale suggests (a section title is about 16, a card
/// title 14, a tile label 11). The mockups win, so a screen that is built to
/// them takes its sizes from here rather than scattering numbers. Colour is
/// left to the caller (`copyWith(color: …)`).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Mockup-measured text styles. Sizes were measured by comparing a rendered
/// screen against its mockup at the same scale; see
/// `docs/reviews/mockup-checklist.md`.
abstract final class QaddyText {
  static const String _family = QaddyTypography.fontFamily;

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? line,
    double spacing = 0,
  }) => TextStyle(
    fontFamily: _family,
    fontSize: size,
    fontWeight: weight,
    height: (line ?? size * 1.4) / size,
    letterSpacing: spacing,
  );

  /// The golfer's name over the Home hero.
  static final TextStyle heroName = _style(
    26,
    FontWeight.w700,
    line: 32,
    spacing: -0.3,
  );

  /// "Good morning," over the Home hero.
  static final TextStyle greeting = _style(14, FontWeight.w400, line: 20);

  /// The brand line under a name or logo.
  static final TextStyle tagline = _style(12, FontWeight.w400, line: 18);

  /// A section title: "Upcoming Round", "Your Game".
  static final TextStyle sectionTitle = _style(
    16,
    FontWeight.w600,
    line: 22,
    spacing: -0.1,
  );

  /// The quiet "See all ›" beside a section title.
  static final TextStyle sectionLink = _style(13, FontWeight.w400, line: 18);

  /// A card's title: a course, a trip.
  static final TextStyle cardTitle = _style(14, FontWeight.w600, line: 20);

  /// A card's supporting lines: the date, the place.
  static final TextStyle meta = _style(12, FontWeight.w400, line: 20);

  /// A time or short figure on a card: "8:20 AM".
  static final TextStyle timeFigure = _style(15, FontWeight.w700, line: 20);

  /// A shortcut tile's label.
  static final TextStyle doorLabel = _style(12, FontWeight.w500, line: 16);

  /// A pill button's label.
  static final TextStyle pillLabel = _style(12, FontWeight.w600, line: 16);

  /// A stat tile's figure.
  static final TextStyle tileFigure = _style(
    18,
    FontWeight.w700,
    line: 22,
    spacing: -0.2,
  );

  /// A stat tile's label.
  static final TextStyle tileLabel = _style(11, FontWeight.w400, line: 14);

  /// The temperature on a weather card.
  static final TextStyle weatherTemp = _style(15, FontWeight.w600, line: 20);

  /// The condition under the temperature.
  static final TextStyle weatherCondition = _style(
    10,
    FontWeight.w400,
    line: 14,
  );

  /// The place on a weather card.
  static final TextStyle weatherPlace = _style(12, FontWeight.w400, line: 16);

  /// The title in a screen's top bar ("Live scoring").
  static final TextStyle screenTitle = _style(
    16,
    FontWeight.w600,
    line: 22,
    spacing: -0.1,
  );

  /// The line under it (the course, the group).
  static final TextStyle screenSubtitle = _style(12, FontWeight.w400, line: 16);

  /// The big title of a hole or a subject: "Hole 4".
  static final TextStyle holeTitle = _style(
    22,
    FontWeight.w700,
    line: 28,
    spacing: -0.3,
  );

  /// The facts under it: "Par 4 | 380 m | SI 10".
  static final TextStyle holeMeta = _style(14, FontWeight.w400, line: 20);

  /// A player's name in a list panel.
  static final TextStyle panelName = _style(14, FontWeight.w600, line: 20);

  /// The score in a stepper.
  static final TextStyle stepperFigure = _style(16, FontWeight.w700, line: 20);

  /// A running total beside a stepper ("E", "+1").
  static final TextStyle runningTotal = _style(14, FontWeight.w500, line: 20);

  /// A promo card's title.
  static final TextStyle promoTitle = _style(
    19,
    FontWeight.w600,
    line: 24,
    spacing: -0.2,
  );

  /// A promo card's body.
  static final TextStyle promoBody = _style(12, FontWeight.w400, line: 17);
}
