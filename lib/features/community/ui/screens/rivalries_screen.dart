/// Qaddy's Rivalries screen — head-to-head record against a friend.
///
/// See `docs/architecture/rivalries.md`. Displays the shared placeholder
/// rivalry: the current user (Tiamana) against Tom.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/friend_info_row.dart';

/// Rivalries (route `/friends/rivalries`).
class RivalriesScreen extends StatelessWidget {
  const RivalriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final rivalry = tomRivalry;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Rivalries')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Center(
              child: Column(
                children: <Widget>[
                  QaddyAvatar(name: rivalry.friendName),
                  SizedBox(height: spacing.sm),
                  Text(
                    'You vs ${rivalry.friendName}',
                    style: typography.h2.copyWith(color: colours.textPrimary),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddyStatisticCard(
                    label: 'Rounds Played',
                    value: '${rivalry.roundsPlayed}',
                  ),
                ),
                SizedBox(width: spacing.cardGap),
                Expanded(
                  child: QaddyStatisticCard(
                    label: 'Wins',
                    value: '${rivalry.wins}',
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.cardGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddyStatisticCard(
                    label: 'Losses',
                    value: '${rivalry.losses}',
                  ),
                ),
                SizedBox(width: spacing.cardGap),
                Expanded(
                  child: QaddyStatisticCard(
                    label: 'Draws',
                    value: '${rivalry.draws}',
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyCard(
              child: FriendInfoRow(
                label: 'Last Result',
                value: rivalry.lastResult,
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
