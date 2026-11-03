/// The Golf Bag's starter set.
///
/// A new golfer has not told Qaddy what they carry, so the bag starts as a
/// typical 14-club set (the most the rules allow) plus the ball, with
/// believable carries for a mid-handicap golfer: just enough for the distance
/// ladder to show how Golf Bag works. **Only the distances are a starting
/// point.** There are no brands, no notes and no trust ratings, because those
/// are the golfer's own words and claiming them would be pretending; the
/// screen says plainly that the distances are a starter set until the golfer
/// sets their own (see [starterClubCount]).
/// See `docs/features/golf-bag-release-candidate.md`.
library;

import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// The bag as it starts, before the golfer changes anything.
const List<BagClub> seedBagClubs = <BagClub>[
  BagClub(
    id: 'driver',
    name: 'Driver',
    family: ClubFamily.wood,
    model: '',
    carryMetres: 235,
  ),
  BagClub(
    id: '3-wood',
    name: '3 wood',
    family: ClubFamily.wood,
    model: '',
    carryMetres: 217,
  ),
  BagClub(
    id: '5-wood',
    name: '5 wood',
    family: ClubFamily.wood,
    model: '',
    carryMetres: 202,
  ),
  BagClub(
    id: 'hybrid',
    name: 'Hybrid',
    family: ClubFamily.hybrid,
    model: '',
    carryMetres: 188,
  ),
  BagClub(
    id: '5-iron',
    name: '5 iron',
    family: ClubFamily.iron,
    model: '',
    carryMetres: 165,
  ),
  BagClub(
    id: '6-iron',
    name: '6 iron',
    family: ClubFamily.iron,
    model: '',
    carryMetres: 155,
  ),
  BagClub(
    id: '7-iron',
    name: '7 iron',
    family: ClubFamily.iron,
    model: '',
    carryMetres: 145,
  ),
  BagClub(
    id: '8-iron',
    name: '8 iron',
    family: ClubFamily.iron,
    model: '',
    carryMetres: 135,
  ),
  BagClub(
    id: '9-iron',
    name: '9 iron',
    family: ClubFamily.iron,
    model: '',
    carryMetres: 125,
  ),
  BagClub(
    id: 'pitching-wedge',
    name: 'Pitching wedge',
    family: ClubFamily.wedge,
    model: '',
    carryMetres: 110,
  ),
  BagClub(
    id: 'gap-wedge',
    name: 'Gap wedge',
    family: ClubFamily.wedge,
    model: '',
    carryMetres: 100,
  ),
  BagClub(
    id: 'sand-wedge',
    name: 'Sand wedge',
    family: ClubFamily.wedge,
    model: '',
    carryMetres: 88,
  ),
  BagClub(
    id: 'lob-wedge',
    name: 'Lob wedge',
    family: ClubFamily.wedge,
    model: '',
    carryMetres: 76,
  ),
  BagClub(id: 'putter', name: 'Putter', family: ClubFamily.putter, model: ''),
  BagClub(id: 'ball', name: 'Ball', family: ClubFamily.ball, model: ''),
];

/// How many clubs in [bag] still carry the starter distance, i.e. the golfer
/// has not set their own yet.
int starterClubCount(List<BagClub> bag) {
  var count = 0;
  for (final club in bag) {
    if (!club.hasCarry) {
      continue;
    }
    for (final seed in seedBagClubs) {
      if (seed.id == club.id && seed.carryMetres == club.carryMetres) {
        count++;
      }
    }
  }
  return count;
}
