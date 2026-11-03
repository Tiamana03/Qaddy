/// Qaddy's Trip Complete screen — the wrap-up once a trip is over: the
/// champion, the other awards, the courses and the bill.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Complete" section
/// and `docs/features/trips-sub-screens-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_result.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Trip Complete (route `/trips/:tripId/complete`).
class TripCompleteScreen extends ConsumerWidget {
  const TripCompleteScreen({required this.tripId, super.key});

  /// The trip being wrapped up.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final summary = summariseExpenses(plan.expenses);
    final rounds = plan.courses.length;
    final players = trip.playerCount;
    final awards = trip.id == melbourneGolfWeekend.id
        ? melbourneGolfWeekendResults
        : const <TripAward>[];

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Trip Complete')),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: staggered(<Widget>[
                SizedBox(height: spacing.lg),
                DetailHeader(
                  icon: Icons.emoji_events_outlined,
                  title: "That's a wrap",
                  subtitle: '${trip.name} · ${trip.destination}',
                  facts: <String>[
                    trip.startDate.toFriendlyRange(trip.endDate),
                    if (plan.courses.isNotEmpty)
                      '$rounds ${rounds == 1 ? 'round' : 'rounds'}',
                    '$players ${players == 1 ? 'player' : 'players'}',
                  ],
                ),
                if (awards.isNotEmpty) ...<Widget>[
                  SizedBox(height: spacing.sectionGap),
                  _Champion(award: awards.first),
                  if (awards.length > 1) ...<Widget>[
                    SizedBox(height: spacing.cardGap),
                    _OtherAwards(awards: awards.skip(1).toList()),
                  ],
                ],
                if (plan.courses.isNotEmpty) ...<Widget>[
                  SizedBox(height: spacing.sectionGap),
                  const QaddySectionHeading(title: 'Courses played'),
                  SizedBox(height: spacing.md),
                  QaddyCard(
                    child: Column(
                      children: <Widget>[
                        for (final (index, course)
                            in plan.courses.indexed) ...<Widget>[
                          if (index > 0) SizedBox(height: spacing.md),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.golf_course_outlined,
                                color: colours.accentOrange,
                              ),
                              SizedBox(width: spacing.md),
                              Expanded(
                                child: Text(
                                  course.name,
                                  style: typography.body.copyWith(
                                    color: colours.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                course.teeTime.toWeekdayAndDate(),
                                style: typography.small.copyWith(
                                  color: colours.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                SizedBox(height: spacing.sectionGap),
                const QaddySectionHeading(title: 'The bill'),
                SizedBox(height: spacing.md),
                _Bill(total: summary.total, players: players),
                SizedBox(height: spacing.sectionGap),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: QaddySecondaryButton(
                        label: 'Archive trip',
                        onPressed: () {
                          ref.read(tripsProvider.notifier).archiveTrip(tripId);
                          context.go(AppRoutes.trips);
                        },
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: QaddyGoldButton(
                        label: 'Return home',
                        onPressed: () {
                          QaddyHaptics.light();
                          context.go(AppRoutes.home);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.xl),
              ]),
            ),
          ),
          const Positioned.fill(child: QaddyConfetti()),
        ],
      ),
    );
  }
}

/// The headline award: the winner's face on gold.
class _Champion extends StatelessWidget {
  const _Champion({required this.award});

  final TripAward award;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGold = colours.backgroundBase;

    return Semantics(
      container: true,
      label: '${award.award}: ${award.winner}',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.cardPadding),
          decoration: BoxDecoration(
            gradient: colours.gradientGold,
            borderRadius: BorderRadius.circular(radius.extraLarge),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: onGold, width: 3),
                ),
                child: FittedBox(child: QaddyAvatar(name: award.winner)),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    QaddyEyebrow(
                      award.award.toUpperCase(),
                      colour: onGold.withValues(alpha: 0.8),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      award.winner,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.h1.copyWith(color: onGold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.emoji_events, color: onGold, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}

/// The other awards, two to a row, each with its winner's face.
class _OtherAwards extends StatelessWidget {
  const _OtherAwards({required this.awards});

  final List<TripAward> awards;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing.cardGap) / 2;
        return Wrap(
          spacing: spacing.cardGap,
          runSpacing: spacing.cardGap,
          children: <Widget>[
            for (final (index, award) in awards.indexed)
              SizedBox(
                width: width,
                child: QaddyFadeSlideIn(
                  offset: 8,
                  delay: staggerDelay(index, stepMs: 60),
                  child: _AwardTile(award: award),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AwardTile extends StatelessWidget {
  const _AwardTile({required this.award});

  final TripAward award;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      container: true,
      label: '${award.award}: ${award.winner}',
      child: ExcludeSemantics(
        child: QaddyCard(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 36,
                height: 36,
                child: FittedBox(child: QaddyAvatar(name: award.winner)),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      award.winner,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      award.award,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.caption.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the trip cost, and what that comes to each.
class _Bill extends StatelessWidget {
  const _Bill({required this.total, required this.players});

  final double total;
  final int players;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final each = players > 0 ? total / players : null;

    return QaddyCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  formatMoney(total),
                  style: typography.display.copyWith(
                    color: colours.textPrimary,
                  ),
                ),
                Text(
                  'Total cost',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (each != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  formatMoney(each.roundToDouble()),
                  style: typography.h2.copyWith(color: colours.gold),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'each',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
