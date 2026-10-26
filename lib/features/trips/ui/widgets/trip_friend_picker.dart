/// A checklist of the user's confirmed friends, for inviting them to a trip.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';

/// The friends who can be invited: confirmed friends, favourites first, minus
/// anyone in [exclude] (e.g. people already on the trip).
List<Friend> invitableFriends({Set<String> exclude = const <String>{}}) {
  return confirmedFriends
      .where((friend) => !exclude.contains(friend.displayName))
      .toList()
    ..sort((a, b) {
      if (a.favourite != b.favourite) {
        return a.favourite ? -1 : 1;
      }
      return a.displayName.compareTo(b.displayName);
    });
}

/// Tickable rows, one per invitable friend.
class TripFriendPicker extends StatelessWidget {
  const TripFriendPicker({
    required this.selected,
    required this.onChanged,
    this.exclude = const <String>{},
    super.key,
  });

  /// Display names of the friends currently ticked.
  final Set<String> selected;

  /// Called with the new selection whenever a row is toggled.
  final ValueChanged<Set<String>> onChanged;

  /// Friends to leave out of the list (already on the trip).
  final Set<String> exclude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final candidates = invitableFriends(exclude: exclude);

    if (candidates.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.md),
        child: Text(
          'Everyone you play with is already on this trip.',
          style: typography.small.copyWith(color: colours.textSecondary),
        ),
      );
    }

    void toggle(String name) {
      final next = Set<String>.of(selected);
      if (!next.remove(name)) {
        next.add(name);
      }
      onChanged(next);
    }

    return Column(
      children: <Widget>[
        for (final friend in candidates)
          Semantics(
            checked: selected.contains(friend.displayName),
            label: '${friend.displayName}, handicap ${friend.handicap}',
            excludeSemantics: true,
            onTap: () => toggle(friend.displayName),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius.medium),
              onTap: () => toggle(friend.displayName),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.xs),
                child: Row(
                  children: <Widget>[
                    QaddyAvatar(name: friend.displayName),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            friend.displayName,
                            style: typography.body.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                          Text(
                            'Handicap ${friend.handicap.toStringAsFixed(1)}'
                            ' · ${friend.homeClub}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.small.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ExcludeSemantics(
                      child: Checkbox(
                        value: selected.contains(friend.displayName),
                        onChanged: (_) => toggle(friend.displayName),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
