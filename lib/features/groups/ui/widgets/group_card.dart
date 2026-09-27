/// The Groups screen's row — see `docs/architecture/groups.md`'s "Screen
/// Contents" section (name, member count, current season, status badge).
/// Built on [QaddyCard], reusing [QaddyStatusBadge] — the same composition
/// `QaddyTripCard` uses for its own list rows.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/groups/models/group.dart';

/// The tone and label a [Group]'s status renders with — Release 1 only
/// displays Active groups (see `groups.md`'s "Status Badge" section).
(String, QaddyStatusBadgeTone) groupStatusBadgeContent(GroupStatus status) {
  return switch (status) {
    GroupStatus.active => ('Active', QaddyStatusBadgeTone.success),
    GroupStatus.archived => ('Archived', QaddyStatusBadgeTone.info),
    GroupStatus.hidden => ('Hidden', QaddyStatusBadgeTone.warning),
    GroupStatus.deleted => ('Deleted', QaddyStatusBadgeTone.error),
  };
}

/// A summary card for one [Group], used on the Groups screen.
class GroupCard extends StatelessWidget {
  const GroupCard({required this.group, this.onTap, super.key});

  /// The group to summarise.
  final Group group;

  /// Called when the card is tapped. Omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final (statusLabel, statusTone) = groupStatusBadgeContent(group.status);

    return QaddyCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        group.name,
                        style: typography.h4.copyWith(
                          color: colours.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    QaddyStatusBadge(label: statusLabel, tone: statusTone),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '${group.totalMembers} Members'
                  '${group.season != null ? '  ·  ${group.season}' : ''}',
                  style: typography.body.copyWith(color: colours.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ],
      ),
    );
  }
}
