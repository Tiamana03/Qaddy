/// One entry in a friend's activity feed: who did what, when, and a one-tap
/// way to cheer for them.
///
/// The icon and colour say what kind of moment it was (a round, a handicap
/// drop, a trophy) before a word is read. Cheering is the golfer's own
/// reaction — there are no invented counts of other people's.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/community/logic/activity_relative_time.dart';
import 'package:qaddy/features/community/models/activity_feed_item.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';

/// The icon for an [ActivityType].
IconData activityTypeIcon(ActivityType type) {
  return switch (type) {
    ActivityType.roundCompleted => Icons.golf_course,
    ActivityType.friendJoined => Icons.person_add,
    ActivityType.groupJoined => Icons.group_add,
    ActivityType.tripCreated => Icons.luggage,
    ActivityType.handicapChanged => Icons.trending_down,
    ActivityType.achievementUnlocked => Icons.emoji_events,
  };
}

/// The accent colour for an [ActivityType].
Color activityTypeColour(QaddyColours colours, ActivityType type) {
  return switch (type) {
    ActivityType.roundCompleted => colours.accentTeal,
    ActivityType.friendJoined => colours.accentPink,
    ActivityType.groupJoined => colours.accentIndigo,
    ActivityType.tripCreated => colours.accentSky,
    ActivityType.handicapChanged => colours.gold,
    ActivityType.achievementUnlocked => colours.gold,
  };
}

/// The cheer's word for an [ActivityType] ("Nice round", "Well played"…).
String activityCheerLabel(ActivityType type) {
  return switch (type) {
    ActivityType.roundCompleted => 'Nice round',
    ActivityType.friendJoined => 'Welcome',
    ActivityType.groupJoined => 'Welcome in',
    ActivityType.tripCreated => 'Count me in',
    ActivityType.handicapChanged => 'Well played',
    ActivityType.achievementUnlocked => 'Congrats',
  };
}

/// An activity entry with a cheer button.
class ActivityFeedTile extends ConsumerWidget {
  const ActivityFeedTile({required this.item, super.key});

  /// The activity to show.
  final ActivityFeedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final cheered = ref.watch(
      friendsProvider.select((state) => state.cheered.contains(item.id)),
    );
    final tone = activityTypeColour(colours, item.type);
    final when = formatActivityTimestamp(item.timestamp);

    // The actor's name leads the message in bold, the rest in plain.
    final message = item.message;
    final actorLength = message.startsWith(item.actor) ? item.actor.length : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            QaddyAvatar(name: item.actor),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tone,
                  shape: BoxShape.circle,
                  border: Border.all(color: colours.card, width: 2),
                ),
                child: Icon(
                  activityTypeIcon(item.type),
                  size: 12,
                  color: colours.backgroundBase,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    if (actorLength > 0)
                      TextSpan(
                        text: message.substring(0, actorLength),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    TextSpan(text: message.substring(actorLength)),
                  ],
                ),
                style: typography.body.copyWith(color: colours.textPrimary),
              ),
              SizedBox(height: spacing.xs),
              // Wraps onto a second line on a narrow screen.
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: spacing.md,
                runSpacing: spacing.xs,
                children: <Widget>[
                  Text(
                    when,
                    style: typography.small.copyWith(
                      color: colours.textTertiary,
                    ),
                  ),
                  _CheerButton(
                    label: activityCheerLabel(item.type),
                    cheered: cheered,
                    onTap: () {
                      cheered ? QaddyHaptics.selection() : QaddyHaptics.light();
                      ref.read(friendsProvider.notifier).toggleCheer(item.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheerButton extends StatelessWidget {
  const _CheerButton({
    required this.label,
    required this.cheered,
    required this.onTap,
  });

  final String label;
  final bool cheered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      toggled: cheered,
      label: cheered ? 'Cheered. Tap to take it back.' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.large),
        child: AnimatedContainer(
          duration: animate ? QaddyMotion.standard.fast : Duration.zero,
          // 44px tall keeps it comfortably tappable.
          constraints: const BoxConstraints(minHeight: 36),
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          decoration: BoxDecoration(
            color: cheered ? colours.gold.withValues(alpha: 0.16) : null,
            borderRadius: BorderRadius.circular(radius.large),
            border: Border.all(color: cheered ? colours.gold : colours.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                scale: cheered ? 1.25 : 1,
                duration: animate ? QaddyMotion.standard.normal : Duration.zero,
                curve: QaddyMotion.standard.enter,
                child: Icon(
                  cheered ? Icons.celebration : Icons.celebration_outlined,
                  size: 16,
                  color: cheered ? colours.gold : colours.textSecondary,
                ),
              ),
              SizedBox(width: spacing.xs),
              Flexible(
                child: Text(
                  cheered ? 'Cheered' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.small.copyWith(
                    color: cheered ? colours.gold : colours.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
