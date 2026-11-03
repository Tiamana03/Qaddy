/// The Golf Bag feature's shared placeholder data.
///
/// See `docs/standards/placeholder-golf-bag-data.md` (superseded) and
/// `docs/features/golf-bag-release-candidate.md`. Golf Bag now owns the whole
/// bag; Profile no longer carries an equipment list. The models are the ones
/// the golfer's placeholder kit has always had (TaylorMade Qi35 driver and
/// P790 irons, Cleveland RTX wedges, an Odyssey White Hot putter, Titleist Pro
/// V1 balls); the woods, the hybrid and the individual irons and wedges fill
/// out a realistic bag, with carries whose averages match the old
/// "Driver 235 m / Irons 145 m / Wedges 95 m".
library;

import 'package:qaddy/features/my_bag/models/bag_club.dart';

/// The bag as it starts, before the golfer changes anything.
const List<BagClub> seedBagClubs = <BagClub>[
  BagClub(
    id: 'driver',
    name: 'Driver',
    family: ClubFamily.wood,
    model: 'TaylorMade Qi35',
    carryMetres: 235,
    note: 'Tee it high and commit. Fairway first, distance second.',
    confidence: 3,
  ),
  BagClub(
    id: '3-wood',
    name: '3 wood',
    family: ClubFamily.wood,
    model: 'TaylorMade Qi35 Fairway',
    carryMetres: 215,
    confidence: 3,
  ),
  BagClub(
    id: 'hybrid',
    name: 'Hybrid',
    family: ClubFamily.hybrid,
    model: 'TaylorMade Qi35 Rescue',
    carryMetres: 190,
    note: 'Out of the rough, this is my friend.',
    confidence: 4,
  ),
  BagClub(
    id: '5-iron',
    name: '5 iron',
    family: ClubFamily.iron,
    model: 'TaylorMade P790',
    carryMetres: 165,
    confidence: 3,
  ),
  BagClub(
    id: '6-iron',
    name: '6 iron',
    family: ClubFamily.iron,
    model: 'TaylorMade P790',
    carryMetres: 155,
    confidence: 4,
  ),
  BagClub(
    id: '7-iron',
    name: '7 iron',
    family: ClubFamily.iron,
    model: 'TaylorMade P790',
    carryMetres: 145,
    note: 'My go-to. Smooth tempo, never force it.',
    confidence: 5,
  ),
  BagClub(
    id: '8-iron',
    name: '8 iron',
    family: ClubFamily.iron,
    model: 'TaylorMade P790',
    carryMetres: 135,
    confidence: 4,
  ),
  BagClub(
    id: '9-iron',
    name: '9 iron',
    family: ClubFamily.iron,
    model: 'TaylorMade P790',
    carryMetres: 125,
    confidence: 4,
  ),
  BagClub(
    id: 'pitching-wedge',
    name: 'Pitching wedge',
    family: ClubFamily.wedge,
    model: 'Cleveland RTX',
    carryMetres: 110,
    confidence: 5,
  ),
  BagClub(
    id: 'gap-wedge',
    name: 'Gap wedge',
    family: ClubFamily.wedge,
    model: 'Cleveland RTX',
    carryMetres: 95,
    confidence: 4,
  ),
  BagClub(
    id: 'sand-wedge',
    name: 'Sand wedge',
    family: ClubFamily.wedge,
    model: 'Cleveland RTX',
    carryMetres: 80,
    note: 'Open the face, trust the bounce.',
    confidence: 3,
  ),
  BagClub(
    id: 'putter',
    name: 'Putter',
    family: ClubFamily.putter,
    model: 'Odyssey White Hot',
    note: 'Read the low side. Brave on the short ones.',
    confidence: 4,
  ),
  BagClub(
    id: 'ball',
    name: 'Ball',
    family: ClubFamily.ball,
    model: 'Titleist Pro V1',
  ),
];
