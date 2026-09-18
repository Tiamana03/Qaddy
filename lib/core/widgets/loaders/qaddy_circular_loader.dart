/// Qaddy's circular loading indicator.
///
/// See `design/ui-components/loaders/loaders-library-v1.png`, panel 1
/// ("Circular Loader") and its "Loader Sizes" panel (Small 16px / Medium
/// 24px / Large 40px — asset-sourced, but not yet formalised as a design
/// token; see the Sprint 1.3 report's recommendations). Defaults to Medium.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';

/// Qaddy's circular loading indicator.
class QaddyCircularLoader extends StatelessWidget {
  const QaddyCircularLoader({this.size = 24, super.key});

  /// Diameter in logical pixels. Defaults to the Loaders Library's "Medium"
  /// size (24px); the asset also shows Small (16px) and Large (40px).
  final double size;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size / 8,
        valueColor: AlwaysStoppedAnimation<Color>(colours.primary),
        backgroundColor: colours.surface2,
      ),
    );
  }
}
