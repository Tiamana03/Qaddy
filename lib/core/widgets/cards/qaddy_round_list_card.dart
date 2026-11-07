/// A round in the My Rounds list, as the approved mockup draws it: a wide
/// course thumbnail beside the course, the date, the time and the format with
/// the forecast at the right; under it the faces, how many are playing and a
/// status pill; then three pill buttons, the last one gold.
///
/// The thumbnail is a `QaddyMediaPlaceholder` until the course photograph
/// arrives, at the size and in the place the photograph will have.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_face_stack.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';

/// How a status pill is coloured.
enum QaddyPillTone {
  /// Green: all good ("Finished").
  success,

  /// Amber: waiting ("Planned").
  pending,

  /// Red: needs attention.
  danger,
}

/// One button on a [QaddyRoundListCard].
class QaddyCardAction {
  const QaddyCardAction({required this.label, this.icon, this.onPressed});

  /// The button's text.
  final String label;

  /// An icon before the text.
  final IconData? icon;

  /// Runs when tapped; null draws the button dimmed.
  final VoidCallback? onPressed;
}

/// A round in a list.
class QaddyRoundListCard extends StatelessWidget {
  const QaddyRoundListCard({
    required this.course,
    required this.statusLabel,
    this.tone = QaddyPillTone.pending,
    this.statusIcon,
    this.date,
    this.time,
    this.detail,
    this.detailIcon = Icons.emoji_events_outlined,
    this.weather,
    this.players = const <String>[],
    this.total = 0,
    this.sample = false,
    this.leading,
    this.middle,
    this.primary,
    super.key,
  });

  /// The course.
  final String course;

  /// The day, "Sat, 16 Aug".
  final String? date;

  /// The tee time, "8:20 AM".
  final String? time;

  /// The third line, with [detailIcon]: where, or how it is played.
  final String? detail;

  /// The icon before [detail].
  final IconData detailIcon;

  /// The forecast, "21°C Sunny"; only the temperature is drawn.
  final String? weather;

  /// Who is playing, for the faces.
  final List<String> players;

  /// How many are playing.
  final int total;

  /// Whether the round is the Sample Clubhouse's.
  final bool sample;

  /// The status pill's text.
  final String statusLabel;

  /// The pill's colour.
  final QaddyPillTone tone;

  /// An icon in the pill.
  final IconData? statusIcon;

  /// The quiet button at the left.
  final QaddyCardAction? leading;

  /// The quiet button in the middle.
  final QaddyCardAction? middle;

  /// The gold button at the right.
  final QaddyCardAction? primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;

    Widget line(IconData icon, String text, {Widget? trailing}) => SizedBox(
      height: 20,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: colours.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.listMeta.copyWith(color: colours.textPrimary),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    final temp = weather?.split(' ').first;

    final pillColour = switch (tone) {
      QaddyPillTone.success => colours.success,
      QaddyPillTone.pending => colours.gold,
      QaddyPillTone.danger => colours.error,
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(radius.medium),
        border: Border.all(color: colours.border),
        boxShadow: shadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 138,
                height: 94,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    QaddyMediaPlaceholder(
                      borderRadius: BorderRadius.circular(radius.small + 2),
                      tone: 1,
                    ),
                    if (sample)
                      const Positioned(
                        left: 6,
                        top: 6,
                        child: SampleBadge(onGradient: true, dense: true),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QaddyText.listTitle.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (date != null)
                      line(Icons.calendar_today_outlined, date!),
                    if (time != null) line(Icons.schedule, time!),
                    if (detail != null)
                      line(
                        detailIcon,
                        detail!,
                        trailing: temp == null
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                    size: 18,
                                    color: colours.gold,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    temp,
                                    style: QaddyText.listMeta.copyWith(
                                      color: colours.textPrimary,
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
          // The faces and the pill sit up over the photograph's lower edge, as
          // in the mockup: 12 of their 28 overlap the row above.
          SizedBox(
            height: 16,
            child: OverflowBox(
              alignment: Alignment.bottomLeft,
              minHeight: 28,
              maxHeight: 28,
              child: SizedBox(
                height: 28,
                child: Row(
                  children: <Widget>[
                    if (players.length > 1) ...<Widget>[
                      QaddyFaceStack(
                        names: players,
                        total: total,
                        size: 28,
                        step: 19,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$total players',
                        style: QaddyText.listMeta.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                    ] else
                      Text(
                        '1 player',
                        style: QaddyText.listMeta.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    const Spacer(),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: pillColour.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: pillColour.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            statusLabel,
                            style: QaddyText.pillLabel.copyWith(
                              color: pillColour,
                            ),
                          ),
                          if (statusIcon != null) ...<Widget>[
                            const SizedBox(width: 5),
                            Icon(statusIcon, size: 14, color: pillColour),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              if (leading != null)
                Expanded(
                  flex: 10,
                  child: QaddySecondaryButton(
                    label: leading!.label,
                    icon: leading!.icon,
                    iconBefore: true,
                    compact: true,
                    height: 34,
                    onPressed: leading!.onPressed,
                  ),
                ),
              if (middle != null) ...<Widget>[
                const SizedBox(width: 7),
                Expanded(
                  flex: 12,
                  child: QaddySecondaryButton(
                    label: middle!.label,
                    icon: middle!.icon,
                    iconBefore: true,
                    compact: true,
                    height: 34,
                    onPressed: middle!.onPressed,
                  ),
                ),
              ],
              if (primary != null) ...<Widget>[
                const SizedBox(width: 7),
                Expanded(
                  flex: 10,
                  child: QaddyGoldButton(
                    label: primary!.label,
                    compact: true,
                    onPressed: primary!.onPressed,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
