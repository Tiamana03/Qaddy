/// The Home hero, as the approved mockup draws it: a photograph with the
/// greeting laid over it and a frosted weather card in the corner.
///
/// The photograph is a `QaddyMediaPlaceholder` until the final image arrives,
/// at the size and in the position it will have. The weather is the
/// upcoming round's forecast, and says it is a sample while it is one.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
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

  /// A short line under the name (today's date).
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
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.large);

    return Semantics(
      container: true,
      label: '$greeting $name. $line.',
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            QaddyMediaPlaceholder(borderRadius: shape, scrim: true),
            Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            greeting,
                            style: typography.bodyLarge.copyWith(
                              color: onImage.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            name,
                            style: typography.h1.copyWith(color: onImage),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            line,
                            style: typography.small.copyWith(
                              color: onImage.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weather != null) ...<Widget>[
                    SizedBox(width: spacing.md),
                    _WeatherCard(
                      weather: weather!,
                      course: course,
                      sample: sample,
                      colours: colours,
                      typography: typography,
                      spacing: spacing,
                      radius: radius,
                      onImage: onImage,
                    ),
                  ],
                ],
              ),
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
    required this.sample,
    required this.colours,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.onImage,
  });

  final String weather;
  final String? course;
  final bool sample;
  final QaddyColours colours;
  final QaddyTypography typography;
  final QaddySpacing spacing;
  final QaddyRadius radius;
  final Color onImage;

  @override
  Widget build(BuildContext context) {
    final space = weather.indexOf(' ');
    final temp = space < 0 ? weather : weather.substring(0, space);
    final condition = space < 0 ? '' : weather.substring(space + 1);
    final shape = BorderRadius.circular(radius.medium);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 140),
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colours.backgroundBase.withValues(alpha: 0.4),
            borderRadius: shape,
            border: Border.all(color: onImage.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.wb_sunny_outlined, color: colours.gold, size: 22),
                  SizedBox(width: spacing.sm),
                  Text(
                    temp,
                    style: typography.h4.copyWith(
                      color: onImage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (condition.isNotEmpty)
                Text(
                  condition,
                  style: typography.caption.copyWith(
                    color: onImage.withValues(alpha: 0.85),
                  ),
                ),
              if (course != null)
                Text(
                  course!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption.copyWith(color: onImage),
                ),
              if (sample) ...<Widget>[
                SizedBox(height: spacing.xs),
                const SampleBadge(onGradient: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
