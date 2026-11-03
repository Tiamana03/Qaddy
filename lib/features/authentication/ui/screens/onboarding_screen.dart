/// Qaddy's Onboarding screen — a short, confident introduction to what Qaddy
/// does for a golfer (the round, the trip, the mates), ending with the way in.
///
/// See `docs/features/launch-experience.md`. Reaching the last page records
/// that the introduction has been seen, so the golfer is not shown it again.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/features/authentication/models/onboarding_page.dart';
import 'package:qaddy/features/authentication/state/session_controller.dart';
import 'package:qaddy/features/authentication/ui/widgets/accounts_notice.dart';
import 'package:qaddy/features/authentication/ui/widgets/launch_scaffold.dart';

/// Onboarding (route `/onboarding`).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  int _page = 0;

  /// The pitches plus the closing "tee it up" page.
  int get _pageCount => onboardingPages.length + 1;

  bool get _onLastPage => _page == _pageCount - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The small icons drift gently — unless the golfer asked for stillness.
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _page = index);
    if (index == _pageCount - 1) {
      ref.read(sessionProvider.notifier).completeOnboarding();
    }
  }

  void _next() {
    QaddyHaptics.selection();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _pageController.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
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

          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  spacing.sm,
                  spacing.sm,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    const QaddyMark(size: 30, animate: false),
                    SizedBox(width: spacing.sm),
                    Text(
                      'Qaddy',
                      style: typography.h3.copyWith(
                        color: colours.gold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    // Skip goes to the last page and fades once there, so the
                    // header never jumps.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _onLastPage ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: _onLastPage,
                        child: QaddyTertiaryButton(
                          label: 'Skip',
                          onPressed: _skip,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: <Widget>[
                    for (final (index, page) in onboardingPages.indexed)
                      _PitchPage(
                        index: index,
                        page: page,
                        controller: _pageController,
                        float: _float,
                      ),
                    _TeeItUpPage(index: onboardingPages.length),
                  ],
                ),
              ),
              _PageDots(count: _pageCount, current: _page),
              SizedBox(height: spacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _onLastPage
                        ? const _Entrances(key: ValueKey<String>('entrances'))
                        : QaddyGoldButton(
                            key: const ValueKey<String>('next'),
                            label: 'Next',
                            onPressed: _next,
                          ),
                  ),
                ),
              ),
              SizedBox(height: spacing.xl),
            ],
          );
        },
      ),
    );
  }
}

/// The three ways in, on the last page.
class _Entrances extends ConsumerWidget {
  const _Entrances({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        QaddyGoldButton(
          label: 'Continue as guest',
          icon: Icons.sports_golf,
          tall: true,
          onPressed: () => enterAsGuest(context, ref),
        ),
        SizedBox(height: spacing.sm),
        QaddySecondaryButton(
          label: 'Sign in',
          onPressed: () => context.push(AppRoutes.login),
        ),
        QaddyTertiaryButton(
          label: 'Create an account',
          onPressed: () => context.push(AppRoutes.signUp),
        ),
      ],
    );
  }
}

/// One pitch: a glowing orb with small icons drifting round it, a headline
/// and a line. The orb and the words move at different speeds as the page is
/// swiped, so the introduction has depth.
class _PitchPage extends StatelessWidget {
  const _PitchPage({
    required this.index,
    required this.page,
    required this.controller,
    required this.float,
  });

  final int index;
  final OnboardingPage page;
  final PageController controller;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final accent = switch (page.tone) {
      OnboardingTone.teal => colours.accentTeal,
      OnboardingTone.sky => colours.accentSky,
      OnboardingTone.orange => colours.accentOrange,
      OnboardingTone.indigo => colours.accentIndigo,
    };

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.hasClients && controller.page != null
            ? controller.page!
            : 0.0;
        final delta = (current - index).clamp(-1.0, 1.0);
        final visible = 1 - delta.abs();

        return LayoutBuilder(
          builder: (context, constraints) {
            final orb = math.min<double>(260, constraints.maxHeight * 0.38);
            return _PageBody(
              height: constraints.maxHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(-delta * 70, 0),
                    child: Opacity(
                      opacity: visible,
                      child: _Orb(
                        size: orb,
                        icon: page.icon,
                        accent: accent,
                        satellites: page.satellites,
                        float: float,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  Transform.translate(
                    offset: Offset(-delta * 30, 0),
                    child: Opacity(
                      opacity: visible,
                      child: Column(
                        children: <Widget>[
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: typography.h1.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                          SizedBox(height: spacing.md),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: typography.body.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// The closing page: the mark, and a straight word about where things stand.
class _TeeItUpPage extends StatelessWidget {
  const _TeeItUpPage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mark = math.min<double>(140, constraints.maxHeight * 0.28);
        return _PageBody(
          height: constraints.maxHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              QaddyMark(size: mark),
              SizedBox(height: spacing.xl),
              Text(
                'Tee it up',
                textAlign: TextAlign.center,
                style: typography.h1.copyWith(color: colours.textPrimary),
              ),
              SizedBox(height: spacing.md),
              Text(
                'Start as a guest and your rounds, bag and trips are saved on '
                'this phone.',
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
              SizedBox(height: spacing.lg),
              const AccountsNotice(),
            ],
          ),
        );
      },
    );
  }
}

/// A glowing orb with [icon] at its heart and [satellites] drifting round it.
class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.icon,
    required this.accent,
    required this.satellites,
    required this.float,
  });

  final double size;
  final IconData icon;
  final Color accent;
  final List<IconData> satellites;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final core = size * 0.46;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
            ),
            Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
            ),
            Container(
              width: core,
              height: core,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    accent,
                    Color.lerp(accent, colours.backgroundBase, 0.45)!,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: size * 0.16,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: core * 0.5),
            ),
            for (final (i, satellite) in satellites.indexed)
              AnimatedBuilder(
                animation: float,
                builder: (context, child) {
                  // Spread round the orb, each drifting on its own beat.
                  final angle =
                      (-60 + i * 130) * math.pi / 180 +
                      math.sin(2 * math.pi * float.value + i * 2) * 0.12;
                  final radius = size * 0.5;
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * radius,
                      math.sin(angle) * radius,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: size * 0.18,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colours.surface1,
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(satellite, color: accent, size: size * 0.09),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dots for each page; the current one stretches into a gold pill.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;

    return Semantics(
      label: 'Page ${current + 1} of $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var index = 0; index < count; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == current ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == current
                      ? colours.gold
                      : colours.textTertiary.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A page's content, centred when there is room and scrollable when there is
/// not (a small phone, large text), so nothing is ever cut off.
class _PageBody extends StatelessWidget {
  const _PageBody({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Center(child: child),
      ),
    );
  }
}
