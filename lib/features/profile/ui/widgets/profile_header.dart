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
import 'package:qaddy/core/theme/qaddy_text.dart';
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

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          golfer.firstName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: QaddyText.holeTitle.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.xs),
        if (golfer.homeCourse != null)
          Row(
            children: <Widget>[
              Icon(Icons.location_on, size: 16, color: colours.textPrimary),
              SizedBox(width: spacing.xs),
              Flexible(
                child: Text(
                  golfer.homeCourse!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QaddyText.listMeta.copyWith(
                    color: colours.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        Text(
          'Since ${golfer.joinedAt.year}',
          style: QaddyText.listMeta.copyWith(color: colours.textSecondary),
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
            // The face in its ring, with the mockup's camera badge. Adding a
            // photograph is Release 2, so the badge only holds its place.
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2.5,
                      ),
                    ),
                    child: FittedBox(
                      child: QaddyAvatar(name: golfer.firstName),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colours.surface1,
                        border: Border.all(color: colours.border),
                      ),
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 15,
                        color: colours.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.md + 2),
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
