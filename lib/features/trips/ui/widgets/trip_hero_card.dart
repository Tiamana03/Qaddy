/// The Trips screen's hero — the next trip, led by a countdown.
///
/// One card that makes the next trip feel close. It leads with the feeling
/// (a cover, a big countdown that builds anticipation, what happens next) and
/// keeps everything else out of the way: the trip's own page holds the first
/// tee, the tasks, the money and the squad. Everything shown comes from the
/// trip's own plan (see `trip_snapshot.dart`); the card itself
/// only lays it out. Text sits on a dark gradient in both themes, so it uses
/// `ColorScheme.onPrimary` (the documented "text on a coloured surface"
/// pairing) rather than `textPrimary`, which is dark green in Light Mode.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_cover.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';

/// The next-trip hero card.
class TripHeroCard extends StatelessWidget {
  const TripHeroCard({
    required this.trip,
    required this.countdown,
    this.snapshot,
    this.onTap,
    super.key,
  });

  /// The trip being featured.
  final Trip trip;

  /// The headline countdown (see [tripCountdown]).
  final TripCountdown countdown;

  /// Supporting facts, when the trip has detail data.
  final TripSnapshot? snapshot;

  /// Opens the trip. Omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final onGradient = theme.colorScheme.onPrimary;
    final snapshot = this.snapshot;
    final borderRadius = BorderRadius.circular(radius.extraLarge);

    final header = _Header(
      trip: trip,
      countdown: countdown,
      progress: snapshot?.planningProgress,
      upNext: snapshot?.upNext,
      onGradient: onGradient,
    );

    final upNext = snapshot?.upNext;
    final upNextLabel = upNext == null
        ? ''
        : ' Up next: ${upNext.title}, ${upNext.when}.';

    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label:
          '${tripCountdownEyebrow(countdown)}: ${trip.name}, '
          '${countdown.value} ${countdown.label}. ${trip.destination}.'
          '$upNextLabel',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: shadows.large,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: tripCoverGradient(colours, trip.coverImage),
                ),
                child: InkWell(
                  onTap: onTap,
                  child: Stack(
                    children: <Widget>[
                      // The cover's emblem, huge and faint, behind the text.
                      Positioned(
                        right: -spacing.xl,
                        top: -spacing.lg,
                        child: ExcludeSemantics(
                          child: Icon(
                            tripCoverFor(trip.coverImage).icon,
                            size: 220,
                            color: onGradient.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(spacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            header,
                            if (onTap != null) ...<Widget>[
                              SizedBox(height: spacing.lg),
                              _ViewTripLink(colour: colours.gold),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.trip,
    required this.countdown,
    required this.progress,
    required this.upNext,
    required this.onGradient,
  });

  final Trip trip;
  final TripCountdown countdown;

  /// Planning progress (0–1) for the ring, or `null` to leave the ring out.
  final double? progress;

  /// What happens next, if anything.
  final TripUpNext? upNext;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final (statusLabel, statusTone) = tripStatusBadgeContent(trip.status);
    final muted = onGradient.withValues(alpha: 0.78);
    // Short numbers get the big display size; words ("Today", "Now") would
    // overflow a narrow phone at 72px, so they use h1.
    final valueStyle = countdown.value.length <= 3
        ? typography.display
        : typography.h1;
    final value = progress;
    final next = upNext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: QaddyEyebrow(tripCountdownEyebrow(countdown))),
            if (TripsController.isSample(trip)) ...<Widget>[
              const SampleBadge(onGradient: true),
              const SizedBox(width: 8),
            ],
            QaddyStatusBadge(label: statusLabel, tone: statusTone),
          ],
        ),
        SizedBox(height: spacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  _Countdown(
                    value: countdown.value,
                    style: valueStyle.copyWith(color: colours.gold),
                    glow: tripCountdownIsImminent(countdown),
                    glowColour: colours.gold,
                  ),
                  SizedBox(width: spacing.sm),
                  Flexible(
                    child: Text(
                      countdown.label,
                      style: typography.bodyLarge.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ),
            if (value != null) ...<Widget>[
              SizedBox(width: spacing.md),
              PlanningRing(
                progress: value,
                label: '${(value * 100).round()}%',
                semanticLabel: 'Planning ${(value * 100).round()} percent done',
                size: spacing.hero + spacing.sm,
                trackColour: onGradient.withValues(alpha: 0.18),
                progressColour: colours.gold,
                labelColour: onGradient,
              ),
            ],
          ],
        ),
        SizedBox(height: spacing.sm),
        Text(
          trip.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: typography.h2.copyWith(color: onGradient),
        ),
        SizedBox(height: spacing.xs),
        Row(
          children: <Widget>[
            Icon(Icons.location_on_outlined, size: spacing.lg, color: muted),
            SizedBox(width: spacing.xs),
            Expanded(
              child: Text(
                trip.destination,
                overflow: TextOverflow.ellipsis,
                style: typography.body.copyWith(color: muted),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.xs),
        Text(
          '${trip.startDate.toFriendlyRange(trip.endDate)}  ·  '
          '${trip.durationInDays} days',
          style: typography.small.copyWith(color: muted),
        ),
        if (next != null) ...<Widget>[
          SizedBox(height: spacing.lg),
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: onGradient.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(radius.medium),
              border: Border.all(color: onGradient.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: <Widget>[
                Icon(next.icon, color: colours.gold),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Up next',
                        style: typography.caption.copyWith(color: muted),
                      ),
                      Text(
                        next.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: onGradient,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        next.when,
                        style: typography.small.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

final Curve _countCurve = QaddyMotion.standard.enter;

/// The countdown value. A number counts up once when it first appears; when
/// the trip is close (`glow`) it also glows for a few pulses, then settles.
/// Words ("Today", "Now") and reduced-motion settings skip the animation.
class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.value,
    required this.style,
    required this.glow,
    required this.glowColour,
  });

  final String value;
  final TextStyle style;
  final bool glow;
  final Color glowColour;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(value, style: style);
    }
    final target = int.tryParse(value);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 3600),
      builder: (context, t, _) {
        // The count lands in the first quarter second; the glow then pulses
        // three times and fades — finite, so nothing animates forever.
        final eased = _countCurve.transform((t / 0.25).clamp(0, 1));
        final counted = target == null ? value : '${countedUp(target, eased)}';
        final pulse = glow ? 0.5 - 0.5 * math.cos(t * 2 * math.pi * 3) : 0.0;
        final fade = glow ? 1 - t : 0.0;
        return Text(
          counted,
          style: style.copyWith(
            shadows: <Shadow>[
              if (glow)
                Shadow(
                  color: glowColour.withValues(alpha: 0.55 * pulse * fade),
                  blurRadius: 28,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewTripLink extends StatelessWidget {
  const _ViewTripLink({required this.colour});

  final Color colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('View trip', style: typography.button.copyWith(color: colour)),
        SizedBox(width: spacing.xs),
        Icon(Icons.arrow_forward, size: spacing.lg + spacing.xs, color: colour),
      ],
    );
  }
}
