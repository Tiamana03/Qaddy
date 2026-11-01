/// "Set up your trip" — a short, tappable list of first steps for a trip that
/// is still mostly empty. It disappears once every step is done.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/trips/logic/trip_setup.dart';

/// The setup checklist for one trip. Draws nothing when [steps] are all done.
class TripSetupCard extends StatelessWidget {
  const TripSetupCard({required this.steps, super.key});

  /// The first steps and whether each is done.
  final List<TripSetupStep> steps;

  @override
  Widget build(BuildContext context) {
    final done = steps.where((step) => step.done).length;
    if (done == steps.length) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Set up your trip',
                  style: typography.h3.copyWith(color: colours.textPrimary),
                ),
              ),
              Text(
                '$done of ${steps.length}',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.large),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: done / steps.length),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: colours.surface2,
                color: colours.accent,
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
          for (final step in steps)
            Semantics(
              button: !step.done,
              label: step.done
                  ? '${step.title}, done'
                  : '${step.title}. ${step.detail}',
              excludeSemantics: true,
              onTap: step.done ? null : () => context.push(step.route),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius.medium),
                onTap: step.done ? null : () => context.push(step.route),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.sm),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: spacing.xxxl,
                        height: spacing.xxxl,
                        decoration: BoxDecoration(
                          color: step.done ? colours.accent : colours.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.done ? Icons.check : step.icon,
                          size: spacing.xl,
                          color: step.done
                              ? colours.background
                              : colours.accent,
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              step.title,
                              style: typography.body.copyWith(
                                color: step.done
                                    ? colours.textTertiary
                                    : colours.textPrimary,
                                decoration: step.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (!step.done)
                              Text(
                                step.detail,
                                style: typography.small.copyWith(
                                  color: colours.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!step.done)
                        Icon(Icons.add, color: colours.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
