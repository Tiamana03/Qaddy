/// Authentication's only new placeholder content — see
/// `docs/architecture/authentication-data-model.md`'s "OnboardingPage
/// Model". Not user or account data: three introductions to existing
/// Release 1 features (Rounds, Friends, Trips), chosen per
/// `docs/architecture/authentication-engineering-decisions.md`'s
/// "Onboarding Introduces Rounds, Friends and Trips — Not a Generic Pitch".
library;

import 'package:flutter/material.dart';

/// One page of Onboarding's introduction carousel.
class OnboardingPage {
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// The existing feature this page introduces.
  final IconData icon;

  /// Short headline.
  final String title;

  /// One-sentence supporting copy.
  final String description;
}

/// Onboarding's three pages, in display order.
const onboardingPages = <OnboardingPage>[
  OnboardingPage(
    icon: Icons.sports_golf,
    title: 'Track Every Round',
    description: 'Log your scores, stats and personal bests in one place.',
  ),
  OnboardingPage(
    icon: Icons.groups_outlined,
    title: 'Play With Friends',
    description: 'Organise rounds, trips and rivalries with your golf crew.',
  ),
  OnboardingPage(
    icon: Icons.flight_takeoff,
    title: 'Plan Your Next Trip',
    description: 'Itineraries, accommodation and expenses, all in Qaddy.',
  ),
];
