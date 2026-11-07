/// Qaddy's Setup screen — the moment the app becomes the golfer's own: a first
/// name and, if they like, a handicap and a home course, and whether to start
/// with the Sample Clubhouse.
///
/// See `docs/features/identity.md` and `docs/features/sample-clubhouse.md`.
/// Shown once, after the introduction (or to a returning golfer who somehow
/// has no details), on the launch stage. Nothing leaves the phone.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/golfer_form.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/authentication/ui/widgets/launch_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// Setup (route `/setup`).
class GolferSetupScreen extends ConsumerStatefulWidget {
  const GolferSetupScreen({super.key});

  @override
  ConsumerState<GolferSetupScreen> createState() => _GolferSetupScreenState();
}

class _GolferSetupScreenState extends ConsumerState<GolferSetupScreen> {
  /// Starts on: the golfer sees what Qaddy does, and can switch it off.
  bool _sample = true;

  void _save(String name, double? handicap, String? course) {
    ref
        .read(golferProvider.notifier)
        .save(firstName: name, handicap: handicap, homeCourse: course);
    ref.read(sampleClubhouseProvider.notifier).choose(enabled: _sample);
    ref.read(friendsProvider.notifier).setSample(on: _sample);
    ref.read(tripsProvider.notifier).setSample(on: _sample);
    QaddyHaptics.success();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
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
                GolferForm(
                  autofocus: true,
                  submitLabel: "Let's play",
                  onSubmit: _save,
                  beforeSubmit: _SampleRow(
                    value: _sample,
                    onChanged: (value) => setState(() => _sample = value),
                  ),
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

/// The Sample Clubhouse choice: one quiet row between the fields and the
/// button, so the first thing a golfer does is say who they are.
class _SampleRow extends StatelessWidget {
  const _SampleRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colours.surface1,
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Start with a Sample Clubhouse',
                  style: typography.small.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Pretend mates, a group and a trip, so you can see what '
                  'Qaddy does. Always labelled; remove any time in Settings.',
                  style: typography.caption.copyWith(
                    color: colours.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
