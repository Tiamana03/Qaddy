/// A photographic promo card, as the approved Home mockup draws "Plan Your
/// Next Golf Trip": a wide picture with a dark wash on its left, a title and a
/// line of copy over it, a gold pill and a round icon badge in the corner.
///
/// The picture is a `QaddyMediaPlaceholder` until the real photograph arrives,
/// at the size and in the place it will have.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';

/// A promo card with one action.
class QaddyPromoCard extends StatelessWidget {
  const QaddyPromoCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    required this.badgeIcon,
    this.tone = 2,
    super.key,
  });

  /// The title; a line break is kept.
  final String title;

  /// A line or two of copy.
  final String body;

  /// The gold pill's label.
  final String actionLabel;

  /// Runs when the card or its pill is tapped.
  final VoidCallback onAction;

  /// The icon in the round badge at the top right.
  final IconData badgeIcon;

  /// Which placeholder sky to draw (0–2).
  final int tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.medium);

    return Semantics(
      button: true,
      label: '$title. $body',
      excludeSemantics: true,
      onTap: onAction,
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            QaddyMediaPlaceholder(borderRadius: shape, tone: tone),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: shape,
                gradient: LinearGradient(
                  colors: <Color>[
                    colours.backgroundBase.withValues(alpha: 0.78),
                    colours.backgroundBase.withValues(alpha: 0),
                  ],
                  stops: const <double>[0.15, 0.85],
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: shape,
                onTap: () {
                  QaddyHaptics.selection();
                  onAction();
                },
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              right: 74,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: QaddyText.promoTitle.copyWith(color: onImage),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: QaddyText.promoBody.copyWith(
                      color: onImage.withValues(alpha: 0.92),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IntrinsicWidth(
                      child: QaddyGoldButton(
                        label: actionLabel,
                        compact: true,
                        icon: Icons.chevron_right_rounded,
                        iconAfter: true,
                        onPressed: onAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colours.backgroundBase.withValues(alpha: 0.7),
                  border: Border.all(color: onImage.withValues(alpha: 0.2)),
                ),
                child: Icon(badgeIcon, color: onImage, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
