/// Who is signed in, until accounts exist.
///
/// Release 1 has no authentication, so the signed-in golfer is the shared
/// placeholder subject Tiamana (see `docs/standards/placeholder-data.md`).
/// Features that need "me" read it from here rather than from another
/// feature's placeholder data, so no feature has to import another just to
/// learn the golfer's name.
library;

/// The signed-in golfer's display name.
const String currentUserName = 'Tiamana';
