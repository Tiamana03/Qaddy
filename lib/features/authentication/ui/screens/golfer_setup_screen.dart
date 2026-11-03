/// Qaddy's Setup screen — the moment the app becomes the golfer's own: a first
/// name and, if they like, a handicap and a home course.
///
/// See `docs/features/identity.md`. Shown once, after the introduction (or to a
/// returning golfer who somehow has no details), on the launch stage. Nothing
/// leaves the phone.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/golfer_form.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/authentication/ui/widgets/launch_scaffold.dart';

/// Setup (route `/setup`).
class GolferSetupScreen extends ConsumerWidget {
  const GolferSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LaunchScaffold(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colours = theme.extension<QaddyColours>()!;
          final spacing = theme.extension<QaddySpacing>()!;
          final typography = theme.extension<QaddyTypography>()!;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: staggered(<Widget>[
                SizedBox(height: spacing.xxl),
                Text(
                  "Who's teeing off?",
                  textAlign: TextAlign.center,
                  style: typography.h1.copyWith(color: colours.textPrimary),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Tell Qaddy who you are and it becomes your app: your name '
                  'on every scorecard, your handicap in your stats.',
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
                SizedBox(height: spacing.xl),
                GolferForm(
                  autofocus: true,
                  submitLabel: "Let's play",
                  onSubmit: (name, handicap, course) {
                    ref
                        .read(golferProvider.notifier)
                        .save(
                          firstName: name,
                          handicap: handicap,
                          homeCourse: course,
                        );
                    QaddyHaptics.success();
                    context.go(AppRoutes.home);
                  },
                ),
                SizedBox(height: spacing.xl),
              ]),
            ),
          );
        },
      ),
    );
  }
}
