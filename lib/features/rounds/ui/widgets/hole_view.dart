/// The picture of the hole, as the approved Live Scoring mockup draws it: a
/// tall aerial view with the distances in a frosted card at the top left, wind,
/// weather, GPS and course tiles down the right, the length flagged at the
/// green and a flyover pill at the foot.
///
/// Everything beyond the hole's par and length arrives in a [HoleGuide], which
/// the course data sources fill (see `features/courses`): GPS distances, the
/// forecast and the pictures. The aerial is a `QaddyMediaPlaceholder`, 290
/// tall as the mockup's is, until the guide has a picture. Whatever the guide
/// does not have keeps its place at the mockup's size and says "–" (or "Soon")
/// rather than invent a number or act like a button.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The hole view for [hole].
class HoleView extends StatelessWidget {
  const HoleView({
    required this.hole,
    this.guide = HoleGuide.unavailable,
    this.greeting,
    super.key,
  });

  /// What the course data sources know about the hole right now.
  final HoleGuide guide;

  /// The hole being played.
  final CourseHole hole;

  /// A friendly line over the picture: on the first tee, "Enjoy it out
  /// there."
  final String? greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.medium);
    final sideGames = <SideGame>[
      for (final game in upcomingRoundSideGames)
        if (game.hole == hole.number) game,
    ];
    final metres = hole.metres;
    final distances = guide.distances;
    final forecast = guide.forecast;
    final temp = forecast?.temperatureLabel ?? '–';
    final sky = forecast?.condition ?? '–';
    final aerial = guide.media.aerialUrl;
    String metresOrDash(int? value) => value == null ? '–' : '$value m';

    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          QaddyMediaPlaceholder(
            borderRadius: shape,
            aerial: true,
            image: aerial == null ? null : NetworkImage(aerial.toString()),
          ),
          // Back, middle and front: GPS when there is a fix, else the hole's
          // length stands in for the middle.
          Positioned(
            left: 12,
            top: 12,
            child: _Frosted(
              width: 120,
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _DistanceRow(
                    label: 'Back',
                    value: metresOrDash(distances?.back),
                    onImage: onImage,
                  ),
                  _DistanceRow(
                    label: 'Middle',
                    value: distances?.middle != null
                        ? metresOrDash(distances!.middle)
                        : metresOrDash(metres),
                    onImage: onImage,
                    strong: true,
                  ),
                  _DistanceRow(
                    label: 'Front',
                    value: metresOrDash(distances?.front),
                    onImage: onImage,
                  ),
                ],
              ),
            ),
          ),
          // Wind, weather, GPS and course down the right.
          Positioned(
            right: 10,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _Tile(
                  width: 74,
                  height: 74,
                  icon: Icons.navigation_outlined,
                  top: forecast?.windLabel ?? '–',
                  bottom: 'Wind',
                  onImage: onImage,
                ),
                const SizedBox(height: 6),
                _Tile(
                  width: 74,
                  height: 72,
                  icon: Icons.wb_sunny_rounded,
                  iconColour: colours.gold,
                  top: temp,
                  bottom: sky,
                  onImage: onImage,
                ),
                const SizedBox(height: 6),
                _Tile(
                  width: 62,
                  height: 54,
                  icon: Icons.my_location_outlined,
                  bottom: 'GPS',
                  onImage: onImage,
                ),
                const SizedBox(height: 6),
                _Tile(
                  width: 62,
                  height: 54,
                  icon: Icons.map_outlined,
                  bottom: 'Course',
                  onImage: onImage,
                ),
              ],
            ),
          ),
          // Two more distance pills on the fairway, as the mockup has them;
          // there is no GPS yet, so they hold their place with a dash.
          const Align(
            alignment: Alignment(-0.22, 0.04),
            child: _DistancePill(text: '– m'),
          ),
          const Align(
            alignment: Alignment(0.08, 0.4),
            child: _DistancePill(text: '– m'),
          ),
          // The hole's length, flagged at the green.
          if (metres != null)
            Align(
              alignment: const Alignment(0.12, -0.42),
              child: _Frosted(
                radius: 999,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  '$metres m',
                  style: QaddyText.pillLabel.copyWith(color: onImage),
                ),
              ),
            ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (greeting != null) ...<Widget>[
                  QaddyInfoChip(
                    icon: Icons.waving_hand_outlined,
                    text: greeting!,
                  ),
                  const SizedBox(height: 6),
                ],
                if (sideGames.isNotEmpty) ...<Widget>[
                  QaddyInfoChip(
                    icon: Icons.flag_outlined,
                    text: '${sideGames.first.name} on this hole',
                  ),
                  const SizedBox(height: 6),
                ],
                _Frosted(
                  radius: 999,
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.play_arrow_rounded, color: onImage, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Flyover soon',
                        style: QaddyText.pillLabel.copyWith(
                          color: onImage.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted dark surface that sits on the picture.
class _Frosted extends StatelessWidget {
  const _Frosted({
    required this.child,
    this.width,
    this.height,
    this.radius = 14,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final shape = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: colours.backgroundBase.withValues(alpha: 0.6),
            borderRadius: shape,
            border: Border.all(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DistanceRow extends StatelessWidget {
  const _DistanceRow({
    required this.label,
    required this.value,
    required this.onImage,
    this.strong = false,
  });

  final String label;
  final String value;
  final Color onImage;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: QaddyText.meta.copyWith(
                  height: 18 / 12,
                  color: onImage.withValues(alpha: strong ? 1 : 0.7),
                  fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: QaddyText.cardTitle.copyWith(
                  height: 18 / 14,
                  color: onImage.withValues(alpha: value == '–' ? 0.6 : 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.width,
    required this.height,
    required this.icon,
    required this.bottom,
    required this.onImage,
    this.iconColour,
    this.top,
  });

  final double width;
  final double height;
  final IconData icon;
  final Color? iconColour;
  final String? top;
  final String bottom;
  final Color onImage;

  @override
  Widget build(BuildContext context) {
    return _Frosted(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24, color: iconColour ?? onImage),
          if (top != null)
            Text(
              top!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.cardTitle.copyWith(
                height: 18 / 14,
                color: onImage.withValues(alpha: top == '–' ? 0.6 : 1),
              ),
            ),
          Text(
            bottom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: QaddyText.weatherCondition.copyWith(
              color: onImage.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// A distance pill on the fairway.
class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Frosted(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: QaddyText.pillLabel.copyWith(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
