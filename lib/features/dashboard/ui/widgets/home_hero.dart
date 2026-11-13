/// The Home hero, as the approved mockup draws it: a photograph 205 tall with
/// the greeting at its top left and a frosted weather card in the corner.
///
/// The photograph is a `QaddyMediaPlaceholder` until the final image arrives,
/// at the size and in the position it will have. The weather is the upcoming
/// round's forecast, and says it is a sample while it is one.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';

/// The greeting hero.
class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.greeting,
    required this.name,
    required this.line,
    this.weather,
    this.course,
    this.sample = false,
    super.key,
  });

  /// "Good morning,".
  final String greeting;

  /// The golfer's name.
  final String name;

  /// The brand line under the name.
  final String line;

  /// The forecast, "21°C Sunny", when there is a round to forecast for.
  final String? weather;

  /// Where the forecast is for.
  final String? course;

  /// Whether the forecast is the Sample Clubhouse's.
  final bool sample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.medium);

    return Semantics(
      container: true,
      label: '$greeting $name. $line',
      child: SizedBox(
        height: 205,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            QaddyMediaPlaceholder(
              borderRadius: shape,
              scrim: true,
              coastal: true,
            ),
            Positioned(
              left: 19,
              top: 19,
              right: weather == null ? 19 : 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      greeting,
                      style: QaddyText.greeting.copyWith(
                        color: onImage.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: QaddyText.heroName.copyWith(color: onImage),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      line,
                      style: QaddyText.tagline.copyWith(
                        color: onImage.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (weather != null)
              Positioned(
                top: 12,
                right: 11,
                child: _WeatherCard(
                  weather: weather!,
                  course: course,
                  colours: colours,
                  radius: radius,
                  onImage: onImage,
                ),
              ),
            if (sample)
              const Positioned(
                left: 19,
                bottom: 14,
                child: SampleBadge(onGradient: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.weather,
    required this.course,
    required this.colours,
    required this.radius,
    required this.onImage,
  });

  final String weather;
  final String? course;
  final QaddyColours colours;
  final QaddyRadius radius;
  final Color onImage;

  @override
  Widget build(BuildContext context) {
    final space = weather.indexOf(' ');
    final temp = space < 0 ? weather : weather.substring(0, space);
    final condition = space < 0 ? '' : weather.substring(space + 1);
    final shape = BorderRadius.circular(radius.medium - 2);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 117,
          padding: const EdgeInsets.fromLTRB(10, 10, 8, 9),
          decoration: BoxDecoration(
            color: colours.backgroundBase.withValues(alpha: 0.5),
            borderRadius: shape,
            border: Border.all(color: onImage.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.wb_sunny_rounded, color: colours.gold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          temp,
                          style: QaddyText.weatherTemp.copyWith(color: onImage),
                        ),
                        if (condition.isNotEmpty)
                          Text(
                            condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QaddyText.weatherCondition.copyWith(
                              color: onImage.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (course != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  course!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QaddyText.weatherPlace.copyWith(
                    color: onImage.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
