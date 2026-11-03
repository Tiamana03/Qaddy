/// Qaddy's Search screen — one box for everything in the golfer's world:
/// mates, the next round, trips, groups and courses.
///
/// See `docs/features/search-feature-integration.md` and
/// `docs/features/search-release-candidate.md`. Not the same feature as Search
/// Friends (`docs/architecture/search.md`), a narrower Friends sub-screen.
/// Matches case-insensitively against any part of each result's name, against
/// the data each category already owns — see
/// `docs/architecture/search-data-model.md`. No backend search exists yet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_field.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_crest.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/search/models/search_result.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// Search (route `/home/search`).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final query = _query.trim();
    final results = _buildResults(context, query.toLowerCase(), colours);

    final byCategory = <SearchCategory, List<SearchResult>>{};
    for (final result in results) {
      byCategory
          .putIfAbsent(result.category, () => <SearchResult>[])
          .add(result);
    }

    final summary = query.isEmpty
        ? 'Mates, rounds, trips, groups and courses'
        : results.isEmpty
        ? 'Nothing for “$query”'
        : results.length == 1
        ? '1 result for “$query”'
        : '${results.length} results for “$query”';

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Find anything',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                summary,
                key: ValueKey<String>(summary),
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ),
            SizedBox(height: spacing.lg),
            QaddySearchField(
              controller: _controller,
              hintText: 'Try a mate, a course, a trip…',
              onChanged: (value) => setState(() => _query = value),
            ),
            SizedBox(height: spacing.sectionGap),
            if (results.isEmpty)
              QaddyEmptyState(
                icon: Icons.search_off,
                title: 'No results found',
                message:
                    'Nothing on the fairway for “$query”. Try a mate’s name, '
                    'a course, a trip or a group.',
                actionLabel: 'Clear search',
                onAction: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              )
            else
              for (final category in SearchCategory.values)
                if (byCategory[category] case final found?
                    when found.isNotEmpty) ...<Widget>[
                  QaddySectionHeading(
                    title: _categoryLabel(category),
                    badge: found.length,
                  ),
                  SizedBox(height: spacing.md),
                  for (final (index, result) in found.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.cardGap),
                    QaddyFadeSlideIn(
                      key: ValueKey<String>(
                        '${category.name}|${result.title}|${result.subtitle}',
                      ),
                      offset: 8,
                      delay: staggerDelay(index, stepMs: 35),
                      child: _SearchResultRow(result: result, query: query),
                    ),
                  ],
                  SizedBox(height: spacing.sectionGap),
                ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }

  List<SearchResult> _buildResults(
    BuildContext context,
    String query,
    QaddyColours colours,
  ) {
    bool matches(String value) =>
        query.isEmpty || value.toLowerCase().contains(query);

    final results = <SearchResult>[];

    for (final friend in ref.watch(confirmedFriendsProvider)) {
      if (!matches(friend.displayName)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.friends,
          title: friend.displayName,
          subtitle:
              'HCP ${handicapLabel(friend.handicap)} · ${friend.homeClub}',
          onTap: () => showFriendPeek(
            context,
            ref,
            friend,
            now: ref.read(friendsClockProvider)(),
          ),
        ),
      );
    }

    if (matches(upcomingRound.course)) {
      results.add(
        SearchResult(
          category: SearchCategory.rounds,
          title: upcomingRound.course,
          subtitle:
              'Next round · ${upcomingRound.date}, ${upcomingRound.teeTime}',
          icon: Icons.sports_golf,
          accent: colours.accentTeal,
          onTap: () => context.go(AppRoutes.rounds),
        ),
      );
    }

    final tripsState = ref.watch(tripsProvider);
    for (final trip in tripsState.trips) {
      if (!matches(trip.name)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.trips,
          title: trip.name,
          subtitle: trip.destination,
          icon: Icons.flight_takeoff,
          accent: colours.accentSky,
          onTap: () => context.push(AppRoutes.tripDetails(trip.id)),
        ),
      );
    }

    for (final group in groups) {
      if (!matches(group.name)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.groups,
          title: group.name,
          subtitle: groupLine(group),
          icon: Icons.groups_outlined,
          accent: accentForGroup(colours, group),
          onTap: () => context.push(AppRoutes.friendsGroup(group.id)),
        ),
      );
    }

    final home = ref.watch(golferDetailsProvider).homeCourse;
    for (final course in <String>[if (home != null) home]) {
      if (!matches(course)) continue;
      results.add(
        SearchResult(
          category: SearchCategory.courses,
          title: course,
          subtitle: 'Your home course',
          icon: Icons.golf_course_outlined,
          accent: colours.accentOrange,
          onTap: () => context.go(AppRoutes.profile),
        ),
      );
    }

    for (final trip in tripsState.trips) {
      for (final course in tripsState.planFor(trip.id).courses) {
        if (!matches(course.name)) continue;
        results.add(
          SearchResult(
            category: SearchCategory.courses,
            title: course.name,
            subtitle: 'On ${trip.name}',
            icon: Icons.golf_course_outlined,
            accent: colours.accentOrange,
            onTap: () => context.push(AppRoutes.tripCourse(trip.id, course.id)),
          ),
        );
      }
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

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.result, required this.query});

  final SearchResult result;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final icon = result.icon;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${result.title}. ${result.subtitle ?? ''} '
          '${result.category.name}. Opens it.',
      onTap: result.onTap,
      child: QaddyCard(
        onTap: result.onTap,
        child: Row(
          children: <Widget>[
            if (icon != null)
              QaddyIconBadge(
                icon: icon,
                colour: result.accent ?? colours.textSecondary,
              )
            else
              SizedBox(
                width: 40,
                height: 40,
                child: FittedBox(child: QaddyAvatar(name: result.title)),
              ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _Highlighted(
                    text: result.title,
                    query: query,
                    style: typography.body.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    highlight: colours.accent,
                  ),
                  if (result.subtitle != null) ...<Widget>[
                    SizedBox(height: spacing.xs),
                    Text(
                      result.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// [text] with the part that matches [query] in gold, so the golfer sees why
/// it was found.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.text,
    required this.query,
    required this.style,
    required this.highlight,
  });

  final String text;
  final String query;
  final TextStyle style;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final start = query.isEmpty
        ? -1
        : text.toLowerCase().indexOf(query.toLowerCase());
    if (start < 0) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(color: highlight),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
