/// The Trips screen's hero — the next trip, led by a countdown.
///
/// One card that answers "what is the state of my next trip?": how long to
/// go, how much is planned, what to do next, what you owe, who is coming,
/// and the latest news from the plan and the chat. Everything shown comes
/// from the trip's own plan (see `trip_snapshot.dart`); the card itself only
/// lays it out. Text sits on the green brand gradient in both themes, so it
/// uses `ColorScheme.onPrimary` (the documented "text on a coloured surface"
/// pairing) rather than `textPrimary`, which is dark green in Light Mode.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';

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
      onGradient: onGradient,
    );
    final details = snapshot == null
        ? null
        : _Details(snapshot: snapshot, onGradient: onGradient);

    final Widget body;
    if (details != null && !context.isMobile) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 5, child: header),
          SizedBox(width: spacing.xl),
          Expanded(flex: 4, child: details),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          header,
          if (details != null) ...<Widget>[
            SizedBox(height: spacing.lg),
            details,
          ],
        ],
      );
    }

    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label:
          'Next trip: ${trip.name}, ${countdown.value} ${countdown.label}. '
          '${trip.destination}.',
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
                decoration: BoxDecoration(gradient: colours.gradientGreen),
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(spacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        body,
                        if (onTap != null) ...<Widget>[
                          SizedBox(height: spacing.lg),
                          _ViewTripLink(colour: colours.gold),
                        ],
                      ],
                    ),
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
    required this.onGradient,
  });

  final Trip trip;
  final TripCountdown countdown;

  /// Planning progress (0–1) for the ring, or `null` to leave the ring out.
  final double? progress;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'NEXT TRIP',
                style: typography.caption.copyWith(
                  color: colours.gold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
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
                  _CountUp(
                    value: countdown.value,
                    style: valueStyle.copyWith(color: colours.gold),
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
          style: typography.h3.copyWith(color: onGradient),
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
      ],
    );
  }
}

/// The countdown value, counting up to a numeric value once when it first
/// appears. Words ("Today", "Now") and reduced-motion settings skip the
/// animation.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.style});

  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final target = int.tryParse(value);
    if (target == null || MediaQuery.disableAnimationsOf(context)) {
      return Text(value, style: style);
    }
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => Text('$current', style: style),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.snapshot, required this.onGradient});

  final TripSnapshot snapshot;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final muted = onGradient.withValues(alpha: 0.78);

    Widget infoRow(IconData icon, String text) => Padding(
      padding: EdgeInsets.only(top: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: spacing.lg + spacing.xs, color: colours.gold),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              text,
              style: typography.small.copyWith(color: onGradient),
            ),
          ),
        ],
      ),
    );

    final going = snapshot.squad.length;
    final invites = snapshot.pendingInvites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(height: 1, color: onGradient.withValues(alpha: 0.18)),
        SizedBox(height: spacing.lg),
        for (final (index, highlight) in snapshot.highlights.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : spacing.sm),
            child: _HighlightTile(highlight: highlight, onGradient: onGradient),
          ),
        if (snapshot.nextTask != null)
          infoRow(Icons.checklist, 'Next task: ${snapshot.nextTask}'),
        if (snapshot.upcomingPayment != null)
          infoRow(Icons.payments_outlined, snapshot.upcomingPayment!),
        if (snapshot.budgetProgress != null) ...<Widget>[
          SizedBox(height: spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.large),
            child: LinearProgressIndicator(
              value: snapshot.budgetProgress,
              minHeight: 6,
              backgroundColor: onGradient.withValues(alpha: 0.18),
              color: colours.gold,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            snapshot.budgetLabel ?? '',
            style: typography.small.copyWith(color: muted),
          ),
        ],
        if (going > 0) ...<Widget>[
          SizedBox(height: spacing.lg),
          Row(
            children: <Widget>[
              _SquadStack(names: snapshot.squad),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  invites == 0
                      ? '$going going'
                      : '$going going · $invites invited',
                  style: typography.small.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ] else if (invites > 0) ...<Widget>[
          infoRow(Icons.group_outlined, '$invites invited'),
        ],
        if (snapshot.latestUpdate != null)
          _Callout(
            icon: Icons.update,
            text: snapshot.latestUpdate!,
            onGradient: onGradient,
          ),
        if (snapshot.latestMessage != null)
          _Callout(
            icon: Icons.chat_bubble_outline,
            text: snapshot.latestMessage!,
            onGradient: onGradient,
          ),
      ],
    );
  }
}

/// A rounded one-line strip for the latest plan update or chat message.
class _Callout extends StatelessWidget {
  const _Callout({
    required this.icon,
    required this.text,
    required this.onGradient,
  });

  final IconData icon;
  final String text;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: onGradient.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(radius.medium),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: spacing.lg,
              color: onGradient.withValues(alpha: 0.78),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(color: onGradient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.highlight, required this.onGradient});

  final TripHighlight highlight;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final icon = highlight.isCourse
        // A placeholder for the course's logo.
        ? Container(
            width: spacing.xxl,
            height: spacing.xxl,
            decoration: BoxDecoration(
              color: onGradient.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(highlight.icon, size: spacing.lg, color: colours.gold),
          )
        : Icon(
            highlight.icon,
            size: spacing.lg + spacing.xs,
            color: colours.gold,
          );

    return Row(
      children: <Widget>[
        SizedBox(
          width: spacing.xxl,
          child: Center(child: icon),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                highlight.label,
                style: typography.caption.copyWith(
                  color: onGradient.withValues(alpha: 0.78),
                ),
              ),
              Text(
                highlight.value,
                style: typography.small.copyWith(
                  color: onGradient,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overlapping initials avatars, capped so the stack stays compact.
class _SquadStack extends StatelessWidget {
  const _SquadStack({required this.names});

  static const int _maxShown = 5;

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final shown = names.take(_maxShown).toList();
    final size = spacing.xxl;
    final step = size - spacing.sm;

    return SizedBox(
      width: size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: <Widget>[
          for (final (index, name) in shown.indexed)
            Positioned(
              left: index * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colours.primary, width: 2),
                ),
                child: ClipOval(
                  child: FittedBox(child: QaddyAvatar(name: name)),
                ),
              ),
            ),
        ],
      ),
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
