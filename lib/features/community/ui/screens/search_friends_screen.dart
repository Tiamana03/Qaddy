/// Qaddy's Invite a Mate screen (the `/friends/search` route).
///
/// Qaddy has no accounts yet, so there is no directory of golfers to search
/// and nobody to "add". What a golfer *can* do is bring a mate in: send them a
/// message about Qaddy through the share sheet. This screen says so plainly
/// and does exactly that — no list of strangers, no button that does nothing.
/// See `docs/features/sample-clubhouse.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';

/// Invite a Mate (route `/friends/search`).
class SearchFriendsScreen extends ConsumerWidget {
  const SearchFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final message = qaddyInviteMessage(currentUserDisplayName);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Invite a mate')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Golf is better with mates',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Qaddy has no directory of golfers yet, so you invite your mates '
              'yourself. Send them this, and when they join they will find '
              'you.',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.xl),
            QaddyCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QaddyIconBadge(
                    icon: Icons.chat_bubble_outline,
                    colour: colours.accentTeal,
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      message,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.lg),
            QaddyGoldButton(
              label: 'Invite a mate',
              icon: Icons.ios_share_rounded,
              tall: true,
              onPressed: () => shareOrCopy(
                context,
                ref,
                text: message,
                subject: 'Play golf with me on Qaddy',
              ),
            ),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}
