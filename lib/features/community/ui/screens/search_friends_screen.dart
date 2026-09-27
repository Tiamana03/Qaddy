/// Qaddy's Search Friends screen — find another golfer by name.
///
/// See `docs/architecture/search.md`. Matches case-insensitively against
/// any part of the name, against the placeholder golfer directory in
/// `placeholder_friends.dart` — no backend search exists yet.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_field.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

/// Search Friends (route `/friends/search`).
class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
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
    final results = query.isEmpty
        ? friends
        : friends
              .where(
                (friend) => friend.displayName.toLowerCase().contains(query),
              )
              .toList();

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Search Friends')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySearchField(
              controller: _controller,
              hintText: 'Search golfers…',
              onChanged: (value) => setState(() => _query = value),
            ),
            SizedBox(height: spacing.sectionGap),
            if (results.isEmpty)
              const QaddyEmptyState(
                icon: Icons.search_off,
                title: 'No golfers found',
                message: 'Try a different name.',
              )
            else
              for (final (index, friend) in results.indexed) ...<Widget>[
                if (index > 0) SizedBox(height: spacing.cardGap),
                _SearchResultRow(friend: friend),
              ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Row(
        children: <Widget>[
          QaddyAvatar(name: friend.displayName),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  friend.displayName,
                  style: typography.body.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'HCP ${friend.handicap}',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          // "Visual only" per friends-feature-integration.md's Button
          // Behaviour table — wired to a no-op rather than left disabled.
          QaddySecondaryButton(label: 'Add Friend', onPressed: () {}),
        ],
      ),
    );
  }
}
