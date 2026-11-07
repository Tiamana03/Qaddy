/// The bar at the top of a tab root, as the approved mockups draw it: the
/// brand at the left, then Search (optional), Notifications with its unread
/// count, and the golfer's face.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';

/// The brand, and the way to Search, Notifications and Profile.
///
/// The same bar heads every tab root in the mockups. The mark, wordmark and
/// tagline are a placeholder for the crown lockup (see
/// `docs/design/asset-register.md`). As in the mockup, the icons have no
/// circle behind them and the face wears a thin white ring.
class AppBrandBar extends ConsumerWidget {
  const AppBrandBar({this.showSearch = true, this.showGear = false, super.key});

  /// Whether the magnifying glass is drawn (Home has it; the mockups for the
  /// other tabs do not).
  final bool showSearch;

  /// Draws Settings' gear where the golfer's face would be: the Profile tab
  /// is the golfer's own face, so its bar offers Settings instead.
  final bool showGear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;

    Widget action({
      required Widget icon,
      required String tooltip,
      required VoidCallback onTap,
    }) => Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        onTap: onTap,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(width: 44, height: 48, child: Center(child: icon)),
        ),
      ),
    );

    return SizedBox(
      height: 52,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const QaddyMark(size: 30, animate: false),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Qaddy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: QaddyText.heroName.copyWith(
                          color: colours.textPrimary,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'MORE GOLF. BETTER DAYS.',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: QaddyText.tagline.copyWith(
                    color: colours.textPrimary.withValues(alpha: 0.9),
                    fontSize: 7.5,
                    height: 10 / 7.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
          if (showSearch)
            action(
              icon: Icon(Icons.search, size: 24, color: colours.textPrimary),
              tooltip: 'Search',
              onTap: () => context.push(AppRoutes.homeSearch),
            ),
          action(
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(
                  Icons.notifications_outlined,
                  size: 26,
                  color: colours.textPrimary,
                ),
                if (unread > 0)
                  // The unread count, as in the mockups: a small gold badge.
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colours.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: TextStyle(
                          fontFamily: QaddyText.heroName.fontFamily,
                          color: colours.backgroundBase,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: unread > 0
                ? 'Notifications, $unread new'
                : 'Notifications',
            onTap: () => context.push(AppRoutes.homeNotifications),
          ),
          if (showGear)
            action(
              icon: Icon(
                Icons.settings_outlined,
                size: 26,
                color: colours.textPrimary,
              ),
              tooltip: 'Settings',
              onTap: () => context.push(AppRoutes.profileSettings),
            )
          else ...<Widget>[
            const SizedBox(width: 6),
            Semantics(
              button: true,
              label: 'Your profile',
              excludeSemantics: true,
              onTap: () => context.go(AppRoutes.profile),
              child: InkResponse(
                onTap: () => context.go(AppRoutes.profile),
                radius: 28,
                child: Container(
                  width: 43,
                  height: 43,
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.5,
                    ),
                  ),
                  child: FittedBox(child: QaddyAvatar(name: currentUserName)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
