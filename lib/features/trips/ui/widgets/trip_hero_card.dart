/// The Trips screen's hero — the next trip, led by a countdown.
///
/// One card that makes the next trip feel close. It leads with the feeling
/// (a cover, a big countdown that builds anticipation, what happens next) and
/// keeps the facts to four small tiles — first tee, next task, money and who
/// is coming — with a ticker for the latest news underneath. Everything shown
/// comes from the trip's own plan (see `trip_snapshot.dart`); the card itself
/// only lays it out. Text sits on a dark gradient in both themes, so it uses
/// `ColorScheme.onPrimary` (the documented "text on a coloured surface"
/// pairing) rather than `textPrimary`, which is dark green in Light Mode.
library;

import 'dart:async';
import 'dart:math' as math;

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
import 'package:qaddy/features/trips/models/trip_cover.dart';
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
                            body,
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
            Expanded(
              child: Text(
                tripCountdownEyebrow(countdown),
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
                        'UP NEXT',
                        style: typography.caption.copyWith(
                          color: muted,
                          letterSpacing: 1.2,
                        ),
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

const Curve _countCurve = Curves.easeOutCubic;

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
        final counted = target == null ? value : '${(target * eased).round()}';
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

class _Details extends StatelessWidget {
  const _Details({required this.snapshot, required this.onGradient});

  final TripSnapshot snapshot;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<QaddySpacing>()!;

    final tiles = <Widget>[
      if (snapshot.firstTee != null)
        _FirstTeeTile(tee: snapshot.firstTee!, onGradient: onGradient),
      if (snapshot.nextTask != null || snapshot.tasksTotal > 0)
        _TaskTile(snapshot: snapshot, onGradient: onGradient),
      if (snapshot.upcomingPayment != null || snapshot.budgetProgress != null)
        _MoneyTile(snapshot: snapshot, onGradient: onGradient),
      if (snapshot.squad.isNotEmpty || snapshot.pendingInvites > 0)
        _SquadTile(snapshot: snapshot, onGradient: onGradient),
    ];
    final news = <(IconData, String)>[
      if (snapshot.latestUpdate != null) (Icons.update, snapshot.latestUpdate!),
      if (snapshot.latestMessage != null)
        (Icons.chat_bubble_outline, snapshot.latestMessage!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < tiles.length; i += 2) ...<Widget>[
          if (i > 0) SizedBox(height: spacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: tiles[i]),
                if (i + 1 < tiles.length) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  Expanded(child: tiles[i + 1]),
                ],
              ],
            ),
          ),
        ],
        if (news.isNotEmpty) ...<Widget>[
          SizedBox(height: spacing.md),
          _NewsTicker(lines: news, onGradient: onGradient),
        ],
      ],
    );
  }
}

/// A small rounded tile on the card: a caption, a headline fact, a detail.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.caption,
    required this.onGradient,
    required this.children,
  });

  final IconData icon;
  final String caption;
  final Color onGradient;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: onGradient.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: spacing.lg, color: colours.gold),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption.copyWith(
                    color: onGradient.withValues(alpha: 0.78),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _FirstTeeTile extends StatelessWidget {
  const _FirstTeeTile({required this.tee, required this.onGradient});

  final TripFirstTee tee;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final weather = tee.weather;
    final muted = onGradient.withValues(alpha: 0.78);

    return _Tile(
      icon: Icons.flag_outlined,
      caption: 'FIRST TEE',
      onGradient: onGradient,
      children: <Widget>[
        Text(
          tee.course,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: typography.body.copyWith(
            color: onGradient,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${tee.day} · ${tee.time}',
          style: typography.small.copyWith(color: muted),
        ),
        if (weather != null) ...<Widget>[
          SizedBox(height: spacing.xs),
          Row(
            children: <Widget>[
              Icon(
                weather.condition.icon,
                size: spacing.lg,
                color: colours.gold,
              ),
              SizedBox(width: spacing.xs),
              Flexible(
                child: Text(
                  '${weather.forecast}, ${weather.highLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.small.copyWith(color: onGradient),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.snapshot, required this.onGradient});

  final TripSnapshot snapshot;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<QaddyTypography>()!;
    final muted = onGradient.withValues(alpha: 0.78);
    final next = snapshot.nextTask;

    return _Tile(
      icon: Icons.checklist,
      caption: next == null ? 'PLANNING' : 'NEXT TASK',
      onGradient: onGradient,
      children: <Widget>[
        Text(
          next ?? 'All tasks done',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: typography.body.copyWith(
            color: onGradient,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (snapshot.tasksTotal > 0)
          Text(
            '${snapshot.tasksDone} of ${snapshot.tasksTotal} done',
            style: typography.small.copyWith(color: muted),
          ),
      ],
    );
  }
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({required this.snapshot, required this.onGradient});

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
    final progress = snapshot.budgetProgress;

    return _Tile(
      icon: Icons.payments_outlined,
      caption: 'MONEY',
      onGradient: onGradient,
      children: <Widget>[
        Text(
          snapshot.upcomingPayment ?? snapshot.budgetLabel ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: typography.body.copyWith(
            color: onGradient,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (snapshot.paymentFor != null)
          Text(
            snapshot.paymentFor!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(color: muted),
          ),
        if (progress != null) ...<Widget>[
          SizedBox(height: spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.large),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: onGradient.withValues(alpha: 0.18),
                color: colours.gold,
              ),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            snapshot.budgetLabel ?? '',
            style: typography.small.copyWith(color: muted),
          ),
        ],
      ],
    );
  }
}

class _SquadTile extends StatelessWidget {
  const _SquadTile({required this.snapshot, required this.onGradient});

  final TripSnapshot snapshot;
  final Color onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final muted = onGradient.withValues(alpha: 0.78);
    final going = snapshot.squad.length;
    final invites = snapshot.pendingInvites;

    return _Tile(
      icon: Icons.groups_outlined,
      caption: 'SQUAD',
      onGradient: onGradient,
      children: <Widget>[
        if (going > 0) ...<Widget>[
          _SquadStack(names: snapshot.squad),
          SizedBox(height: spacing.sm),
        ],
        Text(
          going > 0 ? '$going going' : '$invites invited',
          style: typography.body.copyWith(
            color: onGradient,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (going > 0 && invites > 0)
          Text(
            '$invites invited',
            style: typography.small.copyWith(color: muted),
          ),
      ],
    );
  }
}

/// The latest plan update and chat message. With reduced motion both are
/// shown; otherwise they take turns, so the card always feels alive.
class _NewsTicker extends StatefulWidget {
  const _NewsTicker({required this.lines, required this.onGradient});

  final List<(IconData, String)> lines;
  final Color onGradient;

  @override
  State<_NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<_NewsTicker> {
  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    _timer = null;
    if (widget.lines.length > 1 && !MediaQuery.disableAnimationsOf(context)) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          setState(() => _index = (_index + 1) % widget.lines.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = widget.onGradient;
    final stacked =
        widget.lines.length > 1 && MediaQuery.disableAnimationsOf(context);

    Widget line((IconData, String) entry) => Row(
      key: ValueKey<String>(entry.$2),
      children: <Widget>[
        Icon(
          entry.$1,
          size: spacing.lg,
          color: onGradient.withValues(alpha: 0.78),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            entry.$2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(color: onGradient),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: onGradient.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius.medium),
      ),
      child: stacked
          ? Column(
              children: <Widget>[
                for (final entry in widget.lines) ...<Widget>[
                  line(entry),
                  if (entry != widget.lines.last) SizedBox(height: spacing.xs),
                ],
              ],
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: line(widget.lines[_index % widget.lines.length]),
            ),
    );
  }
}

/// Overlapping initials avatars, capped so the stack stays compact.
class _SquadStack extends StatelessWidget {
  const _SquadStack({required this.names});

  static const int _maxShown = 4;

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
