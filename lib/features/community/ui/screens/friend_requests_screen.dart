/// Qaddy's Friend Requests screen — incoming and outgoing requests.
///
/// Qaddy has no accounts yet, so the only requests are the Sample Clubhouse's;
/// the screen says so, and with none it says that plainly instead of showing
/// two empty boxes. See `docs/architecture/friend-requests.md` and
/// `docs/features/sample-clubhouse.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/sample_banner.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/friend_request_row.dart';

/// Friend Requests (route `/friends/requests`).
class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final incoming = ref.watch(incomingRequestsProvider);
    final outgoing = ref.watch(outgoingRequestsProvider);

    if (incoming.isEmpty && outgoing.isEmpty) {
      return QaddyScaffold(
        appBar: AppBar(title: const Text('Friend Requests')),
        body: Center(
          child: QaddyEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No requests',
            message:
                "You're all caught up. When a mate wants to play with "
                'you, it shows up here.',
            actionLabel: 'Invite a mate',
            onAction: () => context.push(AppRoutes.friendsSearch),
          ),
        ),
      );
    }

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            SampleBanner(
              message:
                  'These requests are pretend, so you can see how '
                  'answering one works.',
              onManage: () => context.push(AppRoutes.profileSettings),
            ),
            SizedBox(height: spacing.sectionGap),
            if (incoming.isNotEmpty) ...<Widget>[
              QaddySectionHeading(title: 'Incoming', badge: incoming.length),
              SizedBox(height: spacing.md),
              for (final (index, request) in incoming.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.cardGap),
                FriendRequestRow(request: request),
              ],
              SizedBox(height: spacing.sectionGap),
            ],
            if (outgoing.isNotEmpty) ...<Widget>[
              QaddySectionHeading(title: 'Sent', badge: outgoing.length),
              SizedBox(height: spacing.md),
              for (final (index, request) in outgoing.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.cardGap),
                FriendRequestRow(request: request),
              ],
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
