/// Being straight with the golfer about accounts: they open after the soft
/// launch, and until then Qaddy lives on this phone. Shown on the sign-in and
/// sign-up screens, and again if someone tries to submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';

/// The line on the sign-in and sign-up screens.
class AccountsNotice extends StatelessWidget {
  const AccountsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colours.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(color: colours.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 20, color: colours.gold),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              'Accounts open after the soft launch. Until then Qaddy keeps '
              'everything on this phone — jump in as a guest.',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Starts the golfer as a guest and takes them into the app.
void enterAsGuest(BuildContext context, WidgetRef ref) {
  QaddyHaptics.light();
  ref.read(sessionProvider.notifier).continueAsGuest();
  // A golfer who has not said who they are is asked first.
  context.go(
    ref.read(golferProvider) == null ? AppRoutes.setup : AppRoutes.home,
  );
}

/// What a valid sign-in or sign-up says when accounts are not open yet: the
/// truth, that nothing was sent anywhere, and the way in.
Future<void> showAccountsSoonSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: QaddyTheme.dark.extension<QaddyColours>()!.surface1,
    builder: (sheetContext) => Theme(
      data: QaddyTheme.dark,
      child: Builder(
        builder: (inner) {
          final theme = Theme.of(inner);
          final colours = theme.extension<QaddyColours>()!;
          final spacing = theme.extension<QaddySpacing>()!;
          final typography = theme.extension<QaddyTypography>()!;

          return Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                QaddyIconBadge(
                  icon: Icons.lock_clock_outlined,
                  colour: colours.gold,
                  size: 56,
                  iconSize: 28,
                ),
                SizedBox(height: spacing.md),
                Text(
                  'Accounts open after the soft launch',
                  textAlign: TextAlign.center,
                  style: typography.h2.copyWith(color: colours.textPrimary),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Nothing you typed has been sent anywhere. Qaddy keeps your '
                  'rounds, bag and trips on this phone, and you can start '
                  'right now as a guest.',
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
                SizedBox(height: spacing.lg),
                QaddyGoldButton(
                  label: 'Continue as guest',
                  icon: Icons.sports_golf,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    enterAsGuest(context, ref);
                  },
                ),
                SizedBox(height: spacing.xs),
                QaddyTertiaryButton(
                  label: 'Not now',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
