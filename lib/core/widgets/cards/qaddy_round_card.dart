/// A round as a card, as the approved mockup draws it (Home's "Upcoming Round"
/// and the My Rounds list): a landscape thumbnail, the course, the day and
/// how close it is, the tee time and a few faces at the right, then two pill
/// buttons, the quiet one (View details) and the gold one.
///
/// The thumbnail is a `QaddyMediaPlaceholder` until the course photograph
/// arrives, at the size and in the place the photograph will have. While a
/// round is under way the card is the way back into it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_face_stack.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';

/// A round card: upcoming, under way or finished.
class QaddyRoundCard extends StatelessWidget {
  const QaddyRoundCard({
    required this.course,
    this.primaryLabel,
    this.onPrimary,
    this.note,
    this.noteIcon = Icons.emoji_events_outlined,
    this.day,
    this.when,
    this.teeTime,
    this.players = const <String>[],
    this.total = 0,
    this.sample = false,
    this.showCount = false,
    this.onDetails,
    super.key,
  });

  /// The course.
  final String course;

  /// The day, "Saturday".
  final String? day;

  /// How close it is, "In 3 days" or "Today".
  final String? when;

  /// The tee time, "8:20 AM".
  final String? teeTime;

  /// Who is playing, for the little faces.
  final List<String> players;

  /// How many are playing in all.
  final int total;

  /// Whether the round is the Sample Clubhouse's.
  final bool sample;

  /// Says how many are playing in words ("4 playing"), for a list of rounds.
  final bool showCount;

  /// One more line about the round: how a finished one went ("You won ·
  /// 38 pts"), or the forecast and format of one to come.
  final String? note;

  /// The icon beside [note].
  final IconData noteIcon;

  /// The gold action ("Get ready", "Start round", "Continue round"). Omit for
  /// a round with nothing to do.
  final String? primaryLabel;

  /// Runs the gold action.
  final VoidCallback? onPrimary;

  /// The quiet action, "View details". Omit for none.
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    Widget metaRow(IconData icon, String text) => Row(
      children: <Widget>[
        Icon(icon, size: 14, color: colours.textSecondary),
        SizedBox(width: spacing.xs),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: QaddyText.meta.copyWith(color: colours.textSecondary),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(11),
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
                width: 73,
                height: 65,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    QaddyMediaPlaceholder(
                      borderRadius: BorderRadius.circular(10),
                      tone: 1,
                    ),
                    if (sample)
                      const Positioned(
                        left: 4,
                        bottom: 4,
                        child: SampleBadge(onGradient: true, dense: true),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            course,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QaddyText.cardTitle.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                        ),
                        if (teeTime != null) ...<Widget>[
                          SizedBox(width: spacing.sm),
                          Text(
                            teeTime!,
                            style: QaddyText.timeFigure.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (day != null)
                      Text(
                        day!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: QaddyText.meta.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    if (when != null || players.length > 1)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: when != null
                                ? metaRow(Icons.schedule, when!)
                                : showCount
                                ? metaRow(
                                    Icons.groups_outlined,
                                    '$total playing',
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (players.length > 1)
                            QaddyFaceStack(
                              names: players,
                              total: total,
                              size: 28,
                              step: 21,
                            ),
                        ],
                      ),
                    if (note != null) metaRow(noteIcon, note!),
                  ],
                ),
              ),
            ],
          ),
          if (onPrimary != null || onDetails != null) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                if (onDetails != null)
                  Expanded(
                    child: QaddySecondaryButton(
                      label: 'View details',
                      compact: true,
                      onPressed: onDetails,
                    ),
                  ),
                if (onDetails != null && onPrimary != null)
                  SizedBox(width: spacing.sm),
                if (onPrimary != null)
                  Expanded(
                    child: QaddyGoldButton(
                      label: primaryLabel ?? 'Open round',
                      compact: true,
                      icon: Icons.flag_rounded,
                      onPressed: onPrimary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
