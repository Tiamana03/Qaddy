/// What a golfer sees on the Trips tab before they have planned anything: an
/// invitation, not an empty list.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';

/// A welcoming card that explains, in three lines, why to plan a trip here,
/// with the one action that matters.
class TripsWelcome extends StatelessWidget {
  const TripsWelcome({required this.onCreateTrip, super.key});

  /// Starts the Create Trip flow.
  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;

    Widget benefit(IconData icon, String title, String detail) => Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: spacing.xxxl,
            height: spacing.xxxl,
            decoration: BoxDecoration(
              color: onGradient.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(radius.medium),
            ),
            child: Icon(icon, color: colours.gold),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: typography.body.copyWith(
                    color: onGradient,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: typography.small.copyWith(
                    color: onGradient.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.extraLarge),
        boxShadow: shadows.large,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.extraLarge),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: colours.gradientGreen),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -spacing.xl,
                top: -spacing.lg,
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.flag_outlined,
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
                    const QaddyEyebrow('Your first trip'),
                    SizedBox(height: spacing.sm),
                    Text(
                      'Plan your next golf trip',
                      style: typography.h2.copyWith(color: onGradient),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'Tee times, flights, dinners and the bill — all in one '
                      'place, with the whole squad.',
                      style: typography.body.copyWith(
                        color: onGradient.withValues(alpha: 0.85),
                      ),
                    ),
                    benefit(
                      Icons.event_note_outlined,
                      'Plan every day',
                      'A timeline of flights, tee times and dinners.',
                    ),
                    benefit(
                      Icons.payments_outlined,
                      'Split costs fairly',
                      'See exactly who owes who, and settle up.',
                    ),
                    benefit(
                      Icons.chat_bubble_outline,
                      'Keep the squad talking',
                      'One chat for the whole trip.',
                    ),
                    SizedBox(height: spacing.xl),
                    QaddyGoldButton(
                      label: 'Create your first trip',
                      tall: true,
                      onPressed: onCreateTrip,
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
