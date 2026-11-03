/// Qaddy's Groups screen — your crews: the groups you play with, each one a
/// colour, a crest and a reason to come back.
///
/// Every group opens its own page. See `docs/features/groups-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_card.dart';
import 'package:qaddy/features/groups/ui/widgets/group_crest.dart';

/// Groups (route `/friends/groups`).
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final playingNext = groups
        .where((group) => upcomingRoundOf(group) != null)
        .toList();
    final pulse = playingNext.isEmpty
        ? 'The crews you play with'
        : '${playingNext.first.name} play next';

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Your crews',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            Text(
              '${groups.length} groups · $pulse',
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.xl),
            for (final (index, group) in groups.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              GroupCard(
                group: group,
                accent: groupAccent(colours, index),
                nextRound: _nextRoundLine(group),
                members: <String>[
                  for (final member in membersOf(group)) member.name,
                ],
                onTap: () => context.push(AppRoutes.friendsGroup(group.id)),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// "Next round Saturday, 8:20 AM", or `null` when none is planned.
String? _nextRoundLine(Group group) {
  final round = upcomingRoundOf(group);
  return round == null ? null : 'Next round ${round.date}, ${round.teeTime}';
}
