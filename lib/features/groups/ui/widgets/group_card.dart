/// A group on the My Groups list, as the approved mockup draws it: a tall
/// course photo at the left, the group's name with a crown when you run it and
/// "You're the admin" / "Member" beside it, the course, the date and the
/// members beneath, then a few faces and a status pill.
///
/// The photo is a `QaddyMediaPlaceholder` until the course photograph arrives,
/// at the size and in the place it will have.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_face_stack.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_pill.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/features/groups/models/group.dart';

/// A tappable card for [group].
class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.onTap,
    required this.photoTone,
    this.isAdmin = false,
    this.course,
    this.when,
    this.membersLine,
    this.description,
    this.members = const <String>[],
    this.statusLabel,
    this.statusTone = QaddyPillTone.pending,
    super.key,
  });

  /// The group to show.
  final Group group;

  /// Opens the group's page.
  final VoidCallback onTap;

  /// Which placeholder sky the photo slot draws (0–2).
  final int photoTone;

  /// Whether the golfer runs the group (a crown, "You're the admin").
  final bool isAdmin;

  /// Where the group plays.
  final String? course;

  /// The next round, "Saturday · 8:20 AM".
  final String? when;

  /// "8 members" or "8 members · 7 confirmed".
  final String? membersLine;

  /// What the group is about, shown when there is no round to talk about.
  final String? description;

  /// Names to show faces for, when the group's people are known.
  final List<String> members;

  /// Where the next round stands ("Round ready", "Waiting on 1").
  final String? statusLabel;

  /// The status pill's colour.
  final QaddyPillTone statusTone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;

    Widget line(IconData icon, String text) => SizedBox(
      height: 20,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 15, color: colours.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: QaddyText.listMeta.copyWith(color: colours.textPrimary),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label:
          '${group.name}. ${isAdmin ? "You're the admin" : 'Member'}. '
          '${course ?? ''} ${when ?? ''} ${membersLine ?? ''} '
          '${statusLabel ?? ''}. Opens the group.',
      excludeSemantics: true,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(color: colours.border),
          boxShadow: shadows.medium,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius.medium),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              QaddyHaptics.selection();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      width: 112,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          QaddyMediaPlaceholder(
                            borderRadius: BorderRadius.circular(
                              radius.small + 2,
                            ),
                            tone: photoTone,
                          ),
                          const Positioned(
                            left: 6,
                            top: 6,
                            child: SampleBadge(onGradient: true, dense: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        group.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: QaddyText.listTitle.copyWith(
                                          color: colours.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isAdmin) ...<Widget>[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.workspace_premium,
                                        size: 16,
                                        color: colours.gold,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isAdmin ? 'Admin' : 'Member',
                                style: QaddyText.weatherCondition.copyWith(
                                  color: isAdmin
                                      ? colours.gold
                                      : colours.textSecondary,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: colours.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (course != null)
                            line(Icons.location_on_outlined, course!),
                          if (when != null)
                            line(Icons.calendar_today_outlined, when!),
                          if (membersLine != null)
                            line(Icons.groups_outlined, membersLine!),
                          if (course == null &&
                              when == null &&
                              description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: QaddyText.meta.copyWith(
                                  height: 17 / 12,
                                  color: colours.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          const Spacer(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (members.isNotEmpty)
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: QaddyFaceStack(
                                      names: members,
                                      total: group.totalMembers,
                                      step: 19,
                                      limit: 4,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              if (statusLabel != null) ...<Widget>[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: QaddyStatusPill(
                                    label: statusLabel!,
                                    tone: statusTone,
                                    filled: statusTone == QaddyPillTone.success,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
