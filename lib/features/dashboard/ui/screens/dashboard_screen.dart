/// Qaddy's Dashboard — the Home destination and the application's control
/// centre.
///
/// Sprint 2.1 replaces the Sprint 1.2 placeholder with the first
/// production feature screen — see
/// `docs/sprints/sprint-02-01-dashboard.md`. This sprint builds the visual
/// foundation only: every value shown is placeholder data from
/// `docs/standards/placeholder-data.md`. No backend, business logic or
/// real navigation is wired up (see the sprint's "Do Not Build" section).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/dashboard/ui/widgets/quick_action_card.dart';

/// The Home / Dashboard destination (route `/home`) — Qaddy's control
/// centre and most-visited screen.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            const _WelcomeHeader(),
            SizedBox(height: spacing.sectionGap),
            const _QuickActions(),
            SizedBox(height: spacing.sectionGap),
            const _UpcomingRoundCard(),
            SizedBox(height: spacing.sectionGap),
            const _RecentRoundCard(),
            SizedBox(height: spacing.sectionGap),
            const _StatisticsPreview(),
            SizedBox(height: spacing.sectionGap),
            const _RecentActivity(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Greeting, placeholder user name and current date.
///
/// "Tiamana" is the placeholder Display Name from placeholder-data.md's
/// User Profile. The greeting is the sprint document's own worked example
/// ("Good Morning") rendered as static text — a time-of-day-conditional
/// greeting would require inventing undocumented hour boundaries, which
/// `docs/project-rules.md` (Principle 10, "Stop When Uncertain") forbids.
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

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
          'Good Morning,',
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
        SizedBox(height: spacing.xs),
        Text(
          'Tiamana',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.xs),
        Text(
          DateTime.now().toWeekdayAndDate(),
          style: typography.small.copyWith(color: colours.textTertiary),
        ),
      ],
    );
  }
}

/// Four placeholder quick actions — visual only, per the sprint document
/// ("Buttons remain disabled or placeholder. No navigation logic is
/// implemented.").
///
/// Icons deliberately avoid `NavigationShell`'s bottom-nav icon set
/// (`home`/`flag`/`card_travel`/`people`/`person`), which stays visible on
/// screen alongside this content.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const List<(IconData, String)> _actions = <(IconData, String)>[
    (Icons.add_circle_outline, 'Create Round'),
    (Icons.play_circle_outline, 'Continue Round'),
    (Icons.bar_chart, 'Statistics'),
    (Icons.diversity_3, 'Friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      children: <Widget>[
        for (final (icon, label) in _actions)
          QuickActionCard(icon: icon, label: label),
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
                  'Richmond Golf Club',
                  style: typography.h4.copyWith(color: colours.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: spacing.sm),
              const QaddyStatusBadge(label: 'Upcoming'),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Saturday · 8:20 AM · 8 Players',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Placeholder Recent Round — see placeholder-data.md's "Recent Round".
///
/// "Winner" is the sprint's own required field; placeholder-data.md records
/// this round's Position as "1st" for the placeholder user (Tiamana), so
/// the winner is the placeholder user themselves.
class _RecentRoundCard extends StatelessWidget {
  const _RecentRoundCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Recent Round',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'The Dunes Golf Links',
            style: typography.h4.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Winner: Tiamana · Score: 78 · Last Saturday',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          const QaddySecondaryButton(label: 'View Summary', onPressed: null),
        ],
      ),
    );
  }
}

/// Four placeholder statistic summaries — see placeholder-data.md's
/// "Statistics".
class _StatisticsPreview extends StatelessWidget {
  const _StatisticsPreview();

  @override
  Widget build(BuildContext context) {
    return const _ResponsiveGrid(
      children: <Widget>[
        QaddyStatisticCard(label: 'Rounds Played', value: '68'),
        QaddyStatisticCard(label: 'Average Score', value: '83'),
        QaddyStatisticCard(label: 'Handicap', value: '8.4'),
        QaddyStatisticCard(label: 'Best Round', value: '74'),
      ],
    );
  }
}

/// A simple vertical activity timeline — see placeholder-data.md's "Recent
/// Activity".
///
/// Icons deliberately avoid `NavigationShell`'s bottom-nav icon set
/// (`home`/`flag`/`card_travel`/`people`/`person`), which stays visible on
/// screen alongside this content.
class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const List<(IconData, String)> _entries = <(IconData, String)>[
    (Icons.golf_course, 'Round completed at Richmond Golf Club'),
    (Icons.group_add, 'Josh joined the Saturday Boys group'),
    (Icons.luggage, 'New golf trip created'),
    (Icons.trending_down, 'Handicap reduced to 8.4'),
    (Icons.emoji_events, 'Achievement unlocked: Personal Best'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Recent Activity',
      child: Column(
        children: <Widget>[
          for (final (index, entry) in _entries.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                Icon(entry.$1, color: colours.gold, size: spacing.lg),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    entry.$2,
                    style: typography.body.copyWith(color: colours.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Lays out [children] two-per-row on mobile and one-per-row-of-four on
/// tablet/desktop, per the sprint document's Responsive Behaviour section.
/// Shared by [_QuickActions] and [_StatisticsPreview] to avoid duplicating
/// the same responsive grid logic twice.
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final perRow = context.isMobile ? 2 : children.length;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += perRow) {
      final rowItems = children.skip(i).take(perRow).toList();
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: spacing.cardGap));
      }
      rows.add(
        Row(
          children: <Widget>[
            for (final (index, item) in rowItems.indexed) ...<Widget>[
              if (index > 0) SizedBox(width: spacing.cardGap),
              Expanded(child: item),
            ],
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}
