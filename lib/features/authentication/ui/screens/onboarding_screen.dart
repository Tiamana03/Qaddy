/// Qaddy's Onboarding screen — a three-page introduction to Rounds,
/// Friends and Trips.
///
/// See `docs/features/authentication-feature-integration.md` and
/// `docs/architecture/authentication-engineering-decisions.md`'s
/// "Onboarding Introduces Rounds, Friends and Trips — Not a Generic Pitch".
/// Reachable only by navigating to `/onboarding` directly — not part of the
/// app's boot sequence. Visual only: Skip and Get Started both go straight
/// to Login; nothing is persisted, so Onboarding is not a one-time gate.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/authentication/models/onboarding_page.dart';

/// Onboarding (route `/onboarding`).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final isLastPage = _page == onboardingPages.length - 1;

    return QaddyScaffold(
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: spacing.lg, right: spacing.lg),
              child: QaddyTertiaryButton(label: 'Skip', onPressed: _goToLogin),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _page = index),
              children: <Widget>[
                for (final page in onboardingPages)
                  _OnboardingPageView(page: page),
              ],
            ),
          ),
          _PageIndicator(pageCount: onboardingPages.length, currentPage: _page),
          SizedBox(height: spacing.lg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.lg),
            child: QaddyPrimaryButton(
              label: isLastPage ? 'Get Started' : 'Next',
              onPressed: isLastPage
                  ? _goToLogin
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
            ),
          ),
          SizedBox(height: spacing.xl),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(page.icon, size: spacing.display, color: colours.gold),
          SizedBox(height: spacing.xl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: typography.h2.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.pageCount, required this.currentPage});

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var index = 0; index < pageCount; index++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xs / 2),
            child: Container(
              width: spacing.sm,
              height: spacing.sm,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentPage
                    ? colours.primary
                    : colours.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
