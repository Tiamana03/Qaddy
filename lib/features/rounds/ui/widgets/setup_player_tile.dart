/// A friend invited to the round, with a switch to put them in or take them
/// out. The golfer's own tile is always on.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

/// One invitee in the "Who's playing" list.
class SetupPlayerTile extends StatelessWidget {
  const SetupPlayerTile({
    required this.player,
    required this.isYou,
    required this.included,
    required this.confirmed,
    required this.onToggle,
    super.key,
  });

  /// The golfer.
  final RoundPlayer player;

  /// Whether this is the golfer keeping the score (always playing).
  final bool isYou;

  /// Whether they are in the round.
  final bool included;

  /// Whether they have said yes to the invitation.
  final bool confirmed;

  /// Puts them in or takes them out.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final borderRadius = BorderRadius.circular(radius.large);

    final handicap = handicapLabel(player.handicap);
    final detail = !confirmed && !included
        ? 'HCP $handicap · Waiting to reply'
        : 'HCP $handicap';

    return Semantics(
      container: true,
      label:
          '${isYou ? 'You' : player.name}, handicap $handicap'
          '${confirmed ? '' : ', waiting to reply'}. '
          '${isYou
              ? 'Always playing.'
              : included
              ? 'Playing.'
              : 'Not playing.'}',
      toggled: included,
      child: Material(
        color: colours.card,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isYou
              ? null
              : () {
                  QaddyHaptics.selection();
                  onToggle();
                },
          child: AnimatedOpacity(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            opacity: included ? 1 : 0.55,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: FittedBox(child: QaddyAvatar(name: player.name)),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          isYou ? 'You' : player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            color: colours.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isYou)
                    Icon(Icons.check_circle, color: colours.gold)
                  else
                    ExcludeSemantics(
                      child: Switch(
                        value: included,
                        onChanged: (_) {
                          QaddyHaptics.selection();
                          onToggle();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
