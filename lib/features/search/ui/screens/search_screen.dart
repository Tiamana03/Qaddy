/// Qaddy's Search screen — global search across Friends, Rounds, Trips,
/// Groups and Courses.
///
/// See `docs/features/search-feature-integration.md`. Not the same feature
/// as Search Friends (`docs/architecture/search.md`), a narrower,
/// already-implemented Friends-feature sub-screen. Matches
/// case-insensitively against any part of each result's name, against the
/// placeholder data each category already owns — see
/// `docs/architecture/search-data-model.md`. No backend search exists yet.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/profile/models/placeholder_profile.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/search/models/search_result.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';

/// Search (route `/home/search`).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final query = _query.trim().toLowerCase();
    final results = _buildResults(context, query);

    final byCategory = <SearchCategory, List<SearchResult>>{};
    for (final result in results) {
      byCategory
          .putIfAbsent(result.category, () => <SearchResult>[])
          .add(result);
    }

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySearchField(
              controller: _controller,
              hintText: 'Search friends, rounds, trips, groups, courses…',
              onChanged: (value) => setState(() => _query = value),
            ),
            SizedBox(height: spacing.sectionGap),
            if (results.isEmpty)
              const QaddyEmptyState(
                icon: Icons.search_off,
                title: 'No results found',
                message: 'Try a different search.',
              )
            else
              for (final category in SearchCategory.values)
                if (byCategory[category] case final categoryResults?
                    when categoryResults.isNotEmpty) ...<Widget>[
                  _CategoryHeader(label: _categoryLabel(category)),
                  SizedBox(height: spacing.sm),
                  for (final (index, result)
                      in categoryResults.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.cardGap),
                    _SearchResultRow(result: result),
                  ],
                  SizedBox(height: spacing.sectionGap),
                ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }

  List<SearchResult> _buildResults(BuildContext context, String query) {
    bool matches(String value) =>
        query.isEmpty || value.toLowerCase().contains(query);

    final results = <SearchResult>[];

    for (final friend in friends) {
      if (!matches(friend.displayName)) continue;
      final isDetailed = friend.id == tom.id;
      results.add(
        SearchResult(
          category: SearchCategory.friends,
          title: friend.displayName,
          subtitle: 'HCP ${friend.handicap}',
          onTap: isDetailed
              ? () => context.push(AppRoutes.friendProfile)
              : null,
        ),
      );
    }

    if (matches(upcomingRound.course)) {
      results.add(
        SearchResult(
          category: SearchCategory.rounds,
          title: upcomingRound.course,
          subtitle: '${upcomingRound.date} • ${upcomingRound.teeTime}',
          icon: Icons.sports_golf,
          onTap: () => context.push(AppRoutes.rounds),
        ),
      );
    }

    for (final trip in <Trip>[...upcomingTrips, ...pastTrips]) {
      if (!matches(trip.name)) continue;
      final isDetailed = trip.id == melbourneGolfWeekend.id;
      results.add(
        SearchResult(
          category: SearchCategory.trips,
          title: trip.name,
          subtitle: trip.destination,
          icon: Icons.flight_takeoff,
          onTap: isDetailed ? () => context.push(AppRoutes.tripDetails) : null,
        ),
      );
    }

    for (final group in groups) {
      if (!matches(group.name)) continue;
      final isDetailed = group.id == saturdayBoys.id;
      results.add(
        SearchResult(
          category: SearchCategory.groups,
          title: group.name,
          subtitle: '${group.totalMembers} members',
          icon: Icons.groups_outlined,
          onTap: isDetailed
              ? () => context.push(AppRoutes.friendsGroupDetails)
              : null,
        ),
      );
    }

    for (final course in profileFavouriteCourses) {
      if (!matches(course)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.courses,
          title: course,
          subtitle: 'Favourite Course',
          icon: Icons.golf_course_outlined,
          onTap: () => context.push(AppRoutes.profile),
        ),
      );
    }

    for (final course in melbourneGolfWeekendCourses) {
      if (!matches(course.name)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.courses,
          title: course.name,
          subtitle: melbourneGolfWeekend.name,
          icon: Icons.golf_course_outlined,
          onTap: () => context.push(AppRoutes.tripGolf),
        ),
      );
    }

    return results;
  }
}

String _categoryLabel(SearchCategory category) => switch (category) {
  SearchCategory.friends => 'Friends',
  SearchCategory.rounds => 'Rounds',
  SearchCategory.trips => 'Trips',
  SearchCategory.groups => 'Groups',
  SearchCategory.courses => 'Courses',
};

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Text(
      label,
      style: typography.h3.copyWith(color: colours.textPrimary),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      onTap: result.onTap,
      child: Row(
        children: <Widget>[
          if (result.icon != null)
            Icon(result.icon, color: colours.textSecondary)
          else
            QaddyAvatar(name: result.title),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  result.title,
                  style: typography.body.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (result.subtitle != null) ...<Widget>[
                  SizedBox(height: spacing.xs),
                  Text(
                    result.subtitle!,
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (result.onTap != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ],
      ),
    );
  }
}
