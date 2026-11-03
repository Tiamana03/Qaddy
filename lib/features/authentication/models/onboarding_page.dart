/// The introduction's pages — see
/// `docs/architecture/authentication-data-model.md`'s "OnboardingPage Model"
/// and `docs/features/launch-experience.md`.
///
/// Not user or account data: three short pitches for what Qaddy does for a
/// golfer (the round, the trip, the mates), each with a colour and a few small
/// icons that orbit its main one. The closing "tee it up" page is built by the
/// screen, since it holds the actions.
library;

import 'package:flutter/material.dart';

/// The accent a page wears.
enum OnboardingTone { teal, sky, orange }

/// One page of the introduction.
class OnboardingPage {
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
    required this.satellites,
  });

  /// The feature this page introduces.
  final IconData icon;

  /// Short headline.
  final String title;

  /// One-sentence supporting copy.
  final String description;

  /// The page's accent.
  final OnboardingTone tone;

  /// Three small icons that float around [icon].
  final List<IconData> satellites;
}

/// The introduction's pitches, in display order.
const onboardingPages = <OnboardingPage>[
  OnboardingPage(
    icon: Icons.sports_golf,
    title: 'Score every round',
    description:
        'Keep score hole by hole, watch your form build and unlock '
        'achievements as you play.',
    tone: OnboardingTone.teal,
    satellites: <IconData>[
      Icons.emoji_events_outlined,
      Icons.show_chart,
      Icons.flag_outlined,
    ],
  ),
  OnboardingPage(
    icon: Icons.flight_takeoff,
    title: 'Plan the golf trip',
    description:
        'Courses, tee times, flights and the bill — everything the group '
        'needs in one place.',
    tone: OnboardingTone.sky,
    satellites: <IconData>[
      Icons.luggage_outlined,
      Icons.hotel_outlined,
      Icons.map_outlined,
    ],
  ),
  OnboardingPage(
    icon: Icons.groups_outlined,
    title: 'Play with your mates',
    description:
        'Rally your crew, run the season table and settle the rivalries.',
    tone: OnboardingTone.orange,
    satellites: <IconData>[
      Icons.campaign_outlined,
      Icons.military_tech_outlined,
      Icons.chat_bubble_outline,
    ],
  ),
];
