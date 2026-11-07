/// Qaddy's Groups screen, as the approved "My Groups" mockup draws it: the
/// brand bar, the title with a gold Create group button, a search bar, the
/// My groups / Invitations / Past groups tabs and each group as a photo card.
///
/// Every group opens its own page. Creating a group, invitations and past
/// groups are not in Release 1; the button says so kindly and the two tabs are
/// honest about being empty. See `docs/features/groups-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_pill.dart';
import 'package:qaddy/core/widgets/brand/app_brand_bar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/sample_banner.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_bar.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_pill_tabs.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_card.dart';

/// Groups (route `/friends/groups`).
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  int _tab = 0;
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Group group) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return group.name.toLowerCase().contains(query) ||
        (group.homeCourse ?? '').toLowerCase().contains(query) ||
        (group.description ?? '').toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final shown = groups.where(_matches).toList();

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            const SizedBox(height: 8),
            const AppBrandBar(showSearch: false),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My groups',
                      style: QaddyText.pageTitle.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 142,
                  child: QaddyGoldButton(
                    label: 'Create group',
                    icon: Icons.add_rounded,
                    compact: true,
                    height: 40,
                    onPressed: () => showQaddyNotice(
                      context,
                      title: 'Creating groups is coming',
                      message:
                          'For now, see how a group works in the Sample '
                          'Clubhouse. Starting your own arrives soon.',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "Golf's better together.",
              style: QaddyText.listMeta.copyWith(color: colours.textSecondary),
            ),
            const SizedBox(height: 14),
            QaddySearchBar(
              hintText: 'Search groups, courses or members…',
              controller: _search,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            QaddyPillTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
              tabs: <QaddyPillTab>[
                QaddyPillTab(
                  label: groups.isEmpty
                      ? 'My groups'
                      : 'My groups (${groups.length})',
                ),
                const QaddyPillTab(label: 'Invitations'),
                const QaddyPillTab(label: 'Past groups'),
              ],
            ),
            const SizedBox(height: 14),
            if (_tab == 1)
              QaddyEmptyState(
                icon: Icons.mail_outline_rounded,
                title: 'No invitations yet',
                message:
                    'When a mate invites you to a group, it shows up here '
                    'for you to accept.',
                actionLabel: 'See my groups',
                onAction: () => setState(() => _tab = 0),
              )
            else if (_tab == 2)
              QaddyEmptyState(
                icon: Icons.history_rounded,
                title: 'No past groups',
                message: 'Groups you have left or archived are kept here.',
                actionLabel: 'See my groups',
                onAction: () => setState(() => _tab = 0),
              )
            else if (groups.isEmpty)
              QaddyEmptyState(
                icon: Icons.groups_outlined,
                title: 'No groups yet',
                message:
                    'Groups are where your regular mates, tables and tee '
                    'times live. See how one works in the Sample Clubhouse.',
                actionLabel: 'Open Settings',
                onAction: () => context.push(AppRoutes.profileSettings),
              )
            else ...<Widget>[
              SampleBanner(
                message:
                    'These groups are pretend, so you can see how they work.',
                onManage: () => context.push(AppRoutes.profileSettings),
              ),
              const SizedBox(height: 14),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No groups match "${_search.text.trim()}".',
                      style: QaddyText.listMeta.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ),
                ),
              for (final (index, group) in shown.indexed) ...<Widget>[
                if (index > 0) const SizedBox(height: 12),
                _card(context, group, index),
              ],
            ],
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Group group, int index) {
    final next = upcomingRoundOf(group);
    final people = membersOf(group);
    // Who is still to say yes, when the next round says how many are in.
    final waiting = next == null
        ? 0
        : (group.totalMembers - next.players).clamp(0, group.totalMembers);
    final plural = group.totalMembers == 1 ? 'member' : 'members';

    return GroupCard(
      group: group,
      photoTone: index % 3,
      isAdmin: group.ownerId == currentUserName,
      course: next?.course ?? group.homeCourse,
      when: next == null ? null : '${next.date} · ${next.teeTime}',
      membersLine: next == null
          ? '${group.totalMembers} $plural'
          : '${group.totalMembers} $plural · ${next.players} confirmed',
      description: group.description,
      members: <String>[for (final member in people) member.name],
      statusLabel: next == null
          ? null
          : waiting == 0
          ? 'Round ready'
          : 'Waiting on $waiting',
      statusTone: next != null && waiting == 0
          ? QaddyPillTone.success
          : QaddyPillTone.pending,
      onTap: () => context.push(AppRoutes.friendsGroup(group.id)),
    );
  }
}
