/// Qaddy's Golf Bag screen — equipment, club distances and a bag summary.
///
/// See `docs/features/golf-bag-feature-integration.md`. Release 1 is a
/// single screen reached from Profile — see
/// `docs/architecture/golf-bag-engineering-decisions.md`'s "Golf Bag Is
/// Reached From Profile, Not the Bottom Navigation". The feature folder is
/// `my_bag` per that same document's "Feature Folder Is `my_bag`, Not
/// `golf_bag`" — only the folder name differs from the public "Golf Bag"
/// name used everywhere else.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/my_bag/models/placeholder_my_bag.dart';

/// Golf Bag (route `/profile/bag`).
class GolfBagScreen extends StatelessWidget {
  const GolfBagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Golf Bag')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _BagSummaryCard(),
            SizedBox(height: spacing.sectionGap),
            const _EquipmentCard(),
            SizedBox(height: spacing.sectionGap),
            const _ClubDistancesCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _BagSummaryCard extends StatelessWidget {
  const _BagSummaryCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final longest = golfBagLongestAverageDistance;

    return QaddySectionCard(
      title: 'Bag Summary',
      child: Row(
        children: <Widget>[
          Expanded(
            child: QaddyStatisticCard(
              label: 'Total Clubs',
              value: '$golfBagTotalClubs',
            ),
          ),
          SizedBox(width: spacing.cardGap),
          Expanded(
            child: QaddyStatisticCard(
              label: 'Longest Average Distance',
              value:
                  '${longest.clubName} — '
                  '${formatDistance(longest.averageDistanceMetres)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Equipment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, item) in golfBagEquipment.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: item.club, value: item.value),
          ],
        ],
      ),
    );
  }
}

class _ClubDistancesCard extends StatelessWidget {
  const _ClubDistancesCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Club Distances',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, distance)
              in golfBagClubDistances.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(
              label: distance.clubName,
              value: formatDistance(distance.averageDistanceMetres),
            ),
          ],
        ],
      ),
    );
  }
}
