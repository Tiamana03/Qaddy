/// One friend request, with buttons that work: Accept and Decline for a
/// request someone sent you, Cancel for one you sent.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';

/// A friend request card.
class FriendRequestRow extends ConsumerWidget {
  const FriendRequestRow({
    required this.request,
    this.compact = false,
    super.key,
  });

  /// The request to show.
  final FriendRequest request;

  /// Show a request the golfer sent as one quiet line instead of a card — it
  /// needs nothing from them, so it shouldn't compete with ones that do.
  final bool compact;

  void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final friend = request.friend;
    final incoming = request.direction == FriendRequestDirection.incoming;
    final controller = ref.read(friendsProvider.notifier);

    if (compact && !incoming) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              height: 32,
              child: FittedBox(child: QaddyAvatar(name: friend.displayName)),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Text(
                'Waiting for ${friend.displayName} to reply',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                QaddyHaptics.selection();
                controller.cancelRequest(friend.id);
                _tell(context, 'Request to ${friend.displayName} cancelled');
              },
              child: Text(
                'Cancel',
                semanticsLabel: 'Cancel request to ${friend.displayName}',
              ),
            ),
          ],
        ),
      );
    }

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              QaddyAvatar(name: friend.displayName),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            friend.displayName,
                            style: typography.body.copyWith(
                              color: colours.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        const SampleBadge(),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      incoming ? 'Wants to play' : 'Waiting for a reply',
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                    Text(
                      'HCP ${handicapLabel(friend.handicap)}'
                      '  ·  ${request.sentDescription}',
                      style: typography.small.copyWith(
                        color: colours.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!incoming)
                TextButton(
                  onPressed: () {
                    QaddyHaptics.selection();
                    controller.cancelRequest(friend.id);
                    _tell(
                      context,
                      'Request to ${friend.displayName} cancelled',
                    );
                  },
                  child: Text(
                    'Cancel',
                    semanticsLabel: 'Cancel request to ${friend.displayName}',
                  ),
                ),
            ],
          ),
          if (incoming) ...<Widget>[
            SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: QaddyGoldButton(
                    label: 'Accept',
                    onPressed: () {
                      QaddyHaptics.success();
                      controller.acceptRequest(friend.id);
                      _tell(
                        context,
                        'You and ${friend.displayName} are now friends',
                      );
                    },
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  flex: 2,
                  child: QaddySecondaryButton(
                    label: 'Decline',
                    onPressed: () {
                      QaddyHaptics.selection();
                      controller.declineRequest(friend.id);
                      _tell(
                        context,
                        'Request from ${friend.displayName} declined',
                      );
                    },
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
