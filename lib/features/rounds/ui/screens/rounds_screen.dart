/// Qaddy's Round Setup screen — the Rounds destination.
///
/// Sprint 2.2 replaces the Sprint 1.2 placeholder with a production-ready
/// interface for preparing a golf round before play begins — see
/// `docs/sprints/sprint-02-02-round-setup.md`. Visual foundation only: every
/// value shown is placeholder data from `docs/standards/placeholder-data.md`.
/// No backend, business logic or real navigation is wired up (see the
/// sprint's "Do Not Build" section).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/ui/widgets/player_card.dart';

/// The Rounds destination (route `/rounds`) — prepare a round before play.
class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _PageHeader(),
            SizedBox(height: spacing.sectionGap),
            const _UpcomingRoundCard(),
            SizedBox(height: spacing.sectionGap),
            const _PlayersSection(),
            SizedBox(height: spacing.sectionGap),
            const _RoundInformationCard(),
            SizedBox(height: spacing.sectionGap),
            const _SideGamesCard(),
            SizedBox(height: spacing.sectionGap),
            const _PrimaryActions(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Page title and short description — the sprint document's own example.
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Rounds',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.xs),
        Text(
          'Create and manage your golf rounds.',
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
      ],
    );
  }
}

/// Placeholder Upcoming Round — see placeholder-data.md's "Upcoming Round".
class _UpcomingRoundCard extends StatelessWidget {
  const _UpcomingRoundCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Upcoming Round',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  upcomingRound.course,
                  style: typography.h4.copyWith(color: colours.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: spacing.sm),
              const QaddyStatusBadge(label: 'Upcoming'),
            ],
          ),
          SizedBox(height: spacing.md),
          QaddyInfoRow(label: 'Date', value: upcomingRound.date),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Tee Time', value: upcomingRound.teeTime),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Players', value: '${upcomingRound.players}'),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Weather', value: upcomingRound.weather),
        ],
      ),
    );
  }
}

/// Placeholder players — see placeholder-data.md's "Friends" table (8
/// entries, matching the Upcoming Round's Player Count of 8).
class _PlayersSection extends StatelessWidget {
  const _PlayersSection();

  static const List<(String, String, PlayerStatus)> _players =
      <(String, String, PlayerStatus)>[
        ('Tom', '8', PlayerStatus.confirmed),
        ('Ben', '12', PlayerStatus.confirmed),
        ('Luke', '5', PlayerStatus.confirmed),
        ('Josh', '15', PlayerStatus.pending),
        ('Nick', '10', PlayerStatus.confirmed),
        ('Sam', '18', PlayerStatus.confirmed),
        ('Liam', '7', PlayerStatus.confirmed),
        ('Tiamana', '8.4', PlayerStatus.confirmed),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Players',
          style: typography.h3.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.md),
        for (final (name, handicap, status) in _players) ...<Widget>[
          PlayerCard(name: name, handicap: handicap, status: status),
          SizedBox(height: spacing.cardGap),
        ],
      ],
    );
  }
}

/// Placeholder Round Information — see placeholder-data.md's "Upcoming
/// Round" (Course, Tee Time, Format, Holes).
class _RoundInformationCard extends StatelessWidget {
  const _RoundInformationCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Round Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyInfoRow(label: 'Course', value: upcomingRound.course),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Tee Time', value: upcomingRound.teeTime),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Format', value: upcomingRound.format),
          SizedBox(height: spacing.sm),
          QaddyInfoRow(label: 'Holes', value: '${upcomingRound.holes}'),
        ],
      ),
    );
  }
}

/// Placeholder Side Games — see placeholder-data.md's "Side Games". Only
/// the configured hole is shown; Winner/Distance describe a completed
/// round's results, which don't belong on a pre-round setup screen.
class _SideGamesCard extends StatelessWidget {
  const _SideGamesCard();

  static const List<(String, int)> _games = <(String, int)>[
    ('Longest Drive', 5),
    ('Nearest The Pin', 12),
    ('Drive & Chip', 16),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Side Games',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, game) in _games.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            QaddyInfoRow(label: game.$1, value: 'Hole ${game.$2}'),
          ],
        ],
      ),
    );
  }
}

/// Visual-only primary actions — no functionality, per the sprint document.
class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Column(
      children: <Widget>[
        const SizedBox(
          width: double.infinity,
          child: QaddyPrimaryButton(label: 'Start Round', onPressed: null),
        ),
        SizedBox(height: spacing.sm),
        const SizedBox(
          width: double.infinity,
          child: QaddySecondaryButton(label: 'Edit Round', onPressed: null),
        ),
        SizedBox(height: spacing.sm),
        const QaddyTertiaryButton(label: 'Cancel Round', onPressed: null),
      ],
    );
  }
}
