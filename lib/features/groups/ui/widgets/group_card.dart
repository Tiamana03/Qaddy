/// A group on the Groups list: its crest, name, what it is about and what is
/// coming up, in the colour the group always wears.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/ui/widgets/group_crest.dart';

/// A tappable card for [group]. [nextRound] is the line about what is coming
/// up ("Next round Saturday, 8:20 AM"), when there is one.
class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.accent,
    required this.onTap,
    this.nextRound,
    super.key,
  });

  /// The group to show.
  final Group group;

  /// The colour the group wears.
  final Color accent;

  /// Opens the group's page.
  final VoidCallback onTap;

  /// What is coming up, if anything.
  final String? nextRound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final borderRadius = BorderRadius.circular(radius.large);
    final line = groupLine(group);

    return Semantics(
      button: true,
      label:
          '${group.name}. ${group.description ?? ''} $line. '
          '${nextRound ?? ''} Opens the group.',
      excludeSemantics: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadows.medium,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color.lerp(accent, colours.backgroundBase, 0.55)!,
                    Color.lerp(accent, colours.backgroundBase, 0.82)!,
                  ],
                ),
              ),
              child: InkWell(
                onTap: () {
                  QaddyHaptics.selection();
                  onTap();
                },
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GroupCrest(name: group.name, size: 56),
                      SizedBox(width: spacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              group.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: typography.h3.copyWith(color: onGradient),
                            ),
                            if (group.description != null) ...<Widget>[
                              SizedBox(height: spacing.xs),
                              Text(
                                group.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: typography.small.copyWith(
                                  color: onGradient.withValues(alpha: 0.85),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            SizedBox(height: spacing.sm),
                            Text(
                              line,
                              style: typography.small.copyWith(
                                color: onGradient.withValues(alpha: 0.85),
                              ),
                            ),
                            if (nextRound != null) ...<Widget>[
                              SizedBox(height: spacing.xs),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 16,
                                    color: colours.gold,
                                  ),
                                  SizedBox(width: spacing.xs),
                                  Flexible(
                                    child: Text(
                                      nextRound!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: typography.small.copyWith(
                                        color: colours.gold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: onGradient.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
