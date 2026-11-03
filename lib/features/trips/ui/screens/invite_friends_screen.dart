/// Invite More Friends — who is coming, who is still to answer, and the quick
/// ways to get more mates on the trip.
///
/// See `docs/features/trips-sub-screens-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_friend_picker.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Invite More Friends (route `/trips/:tripId/invite`).
class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({required this.tripId, super.key});

  /// The trip to invite friends to.
  final String tripId;

  @override
  ConsumerState<InviteFriendsScreen> createState() =>
      _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  Set<String> _selected = <String>{};

  void _tell(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyMessage(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      _tell('Invite copied');
    }
  }

  void _invite() {
    final count = _selected.length;
    ref
        .read(tripsProvider.notifier)
        .inviteFriends(widget.tripId, _selected.toList());
    QaddyHaptics.success();
    setState(() => _selected = <String>{});
    _tell(count == 1 ? 'Invite sent' : '$count invites sent');
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(widget.tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onTrip = plan.members.map((member) => member.displayName).toSet();
    final waiting = plan.pendingMembers;
    final message = tripInviteMessage(trip, plan);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Invite friends')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            DetailHeader(
              icon: Icons.person_add_alt_1_outlined,
              title: "Who's coming?",
              subtitle: trip.name,
              facts: <String>[
                '${plan.confirmedMembers.length} going',
                if (waiting.isNotEmpty) '${waiting.length} waiting',
              ],
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your mates'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: TripFriendPicker(
                selected: _selected,
                exclude: onTrip,
                onChanged: (names) => setState(() => _selected = names),
              ),
            ),
            // The button arrives only once there is someone to invite, so the
            // screen never shows a dead, greyed-out action.
            AnimatedSize(
              duration: animate
                  ? const Duration(milliseconds: 250)
                  : Duration.zero,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _selected.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: EdgeInsets.only(top: spacing.md),
                      child: QaddyGoldButton(
                        label:
                            'Invite ${_selected.length} '
                            '${_selected.length == 1 ? 'friend' : 'friends'}',
                        icon: Icons.send_rounded,
                        onPressed: _invite,
                      ),
                    ),
            ),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Or send a message'),
            SizedBox(height: spacing.md),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colours.surface2,
                      borderRadius: BorderRadius.circular(radius.large),
                    ),
                    child: SelectableText(
                      message,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'Works without the app — send it to anyone.',
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  QaddyGoldButton(
                    label: 'Share invite',
                    icon: Icons.ios_share_rounded,
                    onPressed: () => shareOrCopy(
                      context,
                      ref,
                      text: message,
                      subject: 'Join ${trip.name} on Qaddy',
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddySecondaryButton(
                    label: 'Copy message',
                    onPressed: () => _copyMessage(message),
                  ),
                ],
              ),
            ),
            if (waiting.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Waiting to reply',
                badge: waiting.length,
              ),
              SizedBox(height: spacing.md),
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    for (final (index, member) in waiting.indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.md),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: FittedBox(
                              child: QaddyAvatar(name: member.displayName),
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: Text(
                              member.displayName,
                              style: typography.body.copyWith(
                                color: colours.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            'Invited',
                            style: typography.small.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}
