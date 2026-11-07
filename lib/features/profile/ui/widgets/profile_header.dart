/// The top of Profile, as the approved mockup draws it: the golfer's face in a
/// gold ring, their name, where they play and since when, and "Edit profile"
/// beside them (below them when the screen is narrow).
///
/// The face is a `QaddyAvatar` until a photograph can be added (Release 2; see
/// `docs/design/asset-register.md`), so there is no camera badge.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';

/// The golfer's identity row.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.golfer, required this.onEdit, super.key});

  /// Who the profile is about.
  final GolferProfile golfer;

  /// Opens the edit sheet.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          golfer.firstName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typography.h2.copyWith(
            color: colours.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: spacing.xs),
        if (golfer.homeCourse != null)
          Row(
            children: <Widget>[
              Icon(Icons.location_on, size: 16, color: colours.gold),
              SizedBox(width: spacing.xs),
              Flexible(
                child: Text(
                  golfer.homeCourse!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
              ),
            ],
          ),
        Text(
          'Since ${golfer.joinedAt.year}',
          style: typography.small.copyWith(color: colours.textTertiary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 360;
        final edit = QaddySecondaryButton(
          label: 'Edit profile',
          compact: true,
          onPressed: onEdit,
        );

        return Row(
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colours.gold, width: 3),
              ),
              child: FittedBox(child: QaddyAvatar(name: golfer.firstName)),
            ),
            SizedBox(width: spacing.lg),
            Expanded(
              child: wide
                  ? details
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        details,
                        SizedBox(height: spacing.sm),
                        edit,
                      ],
                    ),
            ),
            if (wide) ...<Widget>[SizedBox(width: spacing.md), edit],
          ],
        );
      },
    );
  }
}
