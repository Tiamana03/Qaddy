/// Invite More Friends — pick friends to invite to the trip, or share the
/// trip's invite link.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
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

  Future<void> _copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      _tell('Invite link copied');
    }
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
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onTrip = plan.members.map((member) => member.displayName).toSet();
    final link = tripInviteLink(trip);

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Invite Friends')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Your Friends',
              child: TripFriendPicker(
                selected: _selected,
                exclude: onTrip,
                onChanged: (names) => setState(() => _selected = names),
              ),
            ),
            SizedBox(height: spacing.md),
            QaddyPrimaryButton(
              label: _selected.isEmpty
                  ? 'Send Invites'
                  : 'Invite ${_selected.length} '
                        '${_selected.length == 1 ? 'friend' : 'friends'}',
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      final count = _selected.length;
                      ref
                          .read(tripsProvider.notifier)
                          .inviteFriends(widget.tripId, _selected.toList());
                      setState(() => _selected = <String>{});
                      _tell(count == 1 ? 'Invite sent' : '$count invites sent');
                    },
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Invite Link',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Anyone with this link can ask to join. (Placeholder — '
                    'links go live with accounts.)',
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  SelectableText(
                    link,
                    style: typography.body.copyWith(color: colours.accent),
                  ),
                  SizedBox(height: spacing.md),
                  QaddySecondaryButton(
                    label: 'Copy Link',
                    onPressed: () => _copyLink(link),
                  ),
                ],
              ),
            ),
            if (plan.pendingMembers.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionCard(
                title: 'Waiting to Reply',
                child: Text(
                  plan.pendingMembers.map((m) => m.displayName).join(', '),
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
