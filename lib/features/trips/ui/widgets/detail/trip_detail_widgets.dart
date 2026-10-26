/// Building blocks shared by the trip detail pages (course, flight,
/// accommodation, transport): a header band, placeholder map and photos,
/// copyable contact rows and small labels.
///
/// There is no maps, photos or link-launching dependency yet, so the map and
/// photos are designed placeholders and phone numbers, addresses and links
/// are copied to the clipboard rather than opened.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Shows a short confirmation at the bottom of the screen.
void tellUser(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Copies [text] to the clipboard and says [confirmation].
Future<void> copyToClipboard(
  BuildContext context,
  String text,
  String confirmation,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    tellUser(context, confirmation);
  }
}

/// The band at the top of a detail page: an icon, a headline, a subline and
/// a few facts, on the brand gradient. Text uses `onPrimary` (the documented
/// "text on a coloured surface" pairing), not `textPrimary`.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    this.facts = const <String>[],
    super.key,
  });

  /// The leading icon (e.g. a flag for a course, a plane for a flight).
  final IconData icon;

  /// The headline.
  final String title;

  /// A line beneath the headline.
  final String? subtitle;

  /// Short facts shown as pills under the subline.
  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        gradient: colours.gradientGreen,
        borderRadius: BorderRadius.circular(radius.extraLarge),
        boxShadow: shadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: spacing.hero,
                height: spacing.hero,
                decoration: BoxDecoration(
                  color: onGradient.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(radius.medium),
                ),
                child: Icon(icon, color: onGradient, size: spacing.xxxl),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: typography.h2.copyWith(color: onGradient),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: typography.body.copyWith(
                          color: onGradient.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (facts.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: <Widget>[
                for (final fact in facts)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: onGradient.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(radius.large),
                    ),
                    child: Text(
                      fact,
                      style: typography.small.copyWith(color: onGradient),
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

/// A placeholder map: a quiet road grid with a pin and the place's name. A
/// real map needs a maps dependency; until then the address is copied.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({required this.label, this.height = 150, super.key});

  /// The place the pin stands for (shown over the map).
  final String label;

  /// The map's height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      label: 'Map preview of $label',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.medium),
        child: Container(
          height: height,
          width: double.infinity,
          color: colours.surface2,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _RoadGridPainter(colours.border)),
              Center(
                child: Icon(Icons.location_on, color: colours.accent, size: 40),
              ),
              Positioned(
                left: spacing.sm,
                right: spacing.sm,
                bottom: spacing.sm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colours.surface1.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(radius.small),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadGridPainter extends CustomPainter {
  const _RoadGridPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // A fixed, hand-placed street pattern, so the placeholder never shifts.
    for (final fraction in <double>[0.18, 0.46, 0.78]) {
      canvas.drawLine(
        Offset(0, size.height * fraction),
        Offset(size.width, size.height * (fraction + 0.08)),
        paint,
      );
    }
    for (final fraction in <double>[0.12, 0.38, 0.64, 0.9]) {
      canvas.drawLine(
        Offset(size.width * fraction, 0),
        Offset(size.width * (fraction - 0.1), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadGridPainter oldDelegate) =>
      oldDelegate.colour != colour;
}

/// A row of photo placeholders ("photos arrive with uploads").
class PhotoPlaceholders extends StatelessWidget {
  const PhotoPlaceholders({required this.icon, this.count = 3, super.key});

  /// The icon drawn in each tile.
  final IconData icon;

  /// How many tiles to show.
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: spacing.hero + spacing.lg,
          child: Row(
            children: <Widget>[
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < count - 1 ? spacing.sm : 0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colours.surface2,
                        borderRadius: BorderRadius.circular(radius.medium),
                      ),
                      child: Icon(icon, color: colours.textTertiary),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          'Photos will appear here once uploads are available.',
          style: typography.small.copyWith(color: colours.textTertiary),
        ),
      ],
    );
  }
}

/// A labelled value with an icon; tapping it copies the value.
class CopyableRow extends StatelessWidget {
  const CopyableRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copiedMessage,
    super.key,
  });

  /// The leading icon.
  final IconData icon;

  /// What the value is ("Phone", "Website", …).
  final String label;

  /// The value shown and copied.
  final String value;

  /// The confirmation shown after copying; defaults to "<label> copied".
  final String? copiedMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      label: '$label, $value. Double tap to copy.',
      excludeSemantics: true,
      onTap: () =>
          copyToClipboard(context, value, copiedMessage ?? '$label copied'),
      child: InkWell(
        onTap: () =>
            copyToClipboard(context, value, copiedMessage ?? '$label copied'),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, color: colours.accent),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.copy_outlined, size: 18, color: colours.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// A heading above a block of related content on a detail page.
class DetailSectionTitle extends StatelessWidget {
  const DetailSectionTitle(this.text, {super.key});

  /// The heading.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.only(top: spacing.sectionGap, bottom: spacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: typography.h3.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}

/// A "label … value" line for plain facts (no copy action).
class FactRow extends StatelessWidget {
  const FactRow({required this.label, required this.value, super.key});

  /// What the fact is.
  final String label;

  /// The fact.
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: typography.body.copyWith(color: colours.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
