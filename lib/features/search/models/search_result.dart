/// Search's own presentation model — see
/// `docs/architecture/search-data-model.md`'s "SearchResult Model".
///
/// Not placeholder data: every field is built at display time from a
/// value already owned by another feature (Friends, Groups, Trips, Rounds
/// or Profile), never stored or duplicated here.
library;

import 'package:flutter/material.dart';

/// Which of Search's five result groups a [SearchResult] belongs to.
enum SearchCategory { friends, rounds, trips, groups, courses }

/// One row in the Search screen's results list.
class SearchResult {
  const SearchResult({
    required this.category,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  /// Which category section this result renders under.
  final SearchCategory category;

  /// The primary matched text.
  final String title;

  /// Supporting detail shown under the title.
  final String? subtitle;

  /// Icon shown when no avatar applies. Friends results show a
  /// `QaddyAvatar` instead and leave this null.
  final IconData? icon;

  /// Opens this result's existing screen. Null when no detail screen
  /// exists for this specific item — see `search-feature-integration.md`'s
  /// "Partial Detail Data".
  final VoidCallback? onTap;
}
