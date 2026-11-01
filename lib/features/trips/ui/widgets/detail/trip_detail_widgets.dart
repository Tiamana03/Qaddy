/// Building blocks shared by the trip detail pages (course, flight,
/// accommodation, transport): a header band, a placeholder map, copyable
/// contact rows and small labels.
///
/// There is no maps, photos or link-launching dependency yet, so the map is a
/// designed placeholder and phone numbers, addresses and links are copied to
/// the clipboard rather than opened. Photos are left out until uploads exist,
/// rather than shown as empty boxes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/services/share_service.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';

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
  QaddyHaptics.light();
  if (context.mounted) {
    tellUser(context, confirmation);
  }
}

/// Opens [uri] outside the app (dialler, browser, maps). When nothing can open
/// it — no handler, or a platform without one — copies [fallback] instead and
/// says so, so the golfer is never left with a dead tap.
Future<void> openLinkOrCopy(
  BuildContext context,
  WidgetRef ref, {
  required Uri uri,
  required String fallback,
  required String label,
}) async {
  final opened = await ref.read(linkLauncherProvider).open(uri);
  if (opened) {
    QaddyHaptics.light();
    return;
  }
  if (context.mounted) {
    await copyToClipboard(
      context,
      fallback,
      'Could not open $label — copied it instead',
    );
  }
}

/// Shares [text] through the system share sheet. Where there is none, copies
/// it and says so.
Future<void> shareOrCopy(
  BuildContext context,
  WidgetRef ref, {
  required String text,
  String? subject,
}) async {
  final outcome = await ref
      .read(shareServiceProvider)
      .shareText(text, subject: subject);
  if (outcome == ShareOutcome.unavailable && context.mounted) {
    await copyToClipboard(context, text, 'Copied — paste it into a message');
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
  const MapPlaceholder({
    required this.label,
    this.height = 150,
    this.onTap,
    super.key,
  });

  /// The place the pin stands for (shown over the map).
  final String label;

  /// The map's height.
  final double height;

  /// Opens the real map (in a maps app) when the placeholder is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final tap = onTap;

    return Semantics(
      button: tap != null,
      label: tap == null
          ? 'Map preview of $label'
          : 'Map of $label. Open in Maps.',
      excludeSemantics: true,
      onTap: tap,
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
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.small.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                      ),
                      if (tap != null) ...<Widget>[
                        SizedBox(width: spacing.sm),
                        Icon(
                          Icons.open_in_new,
                          size: spacing.lg,
                          color: colours.accent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (tap != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: tap),
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

/// What a [ContactRow] does when tapped.
enum ContactKind {
  /// Calls the number.
  phone,

  /// Opens the website.
  website,

  /// Opens the address in a maps app.
  address,
}

/// A contact detail you can act on: tap it to call, browse or navigate; tap
/// the small copy button to copy it instead.
class ContactRow extends ConsumerWidget {
  const ContactRow({
    required this.kind,
    required this.value,
    this.label,
    super.key,
  });

  /// What kind of detail this is, which decides what tapping does.
  final ContactKind kind;

  /// The phone number, website or address.
  final String value;

  /// Overrides the default label (Phone, Website, Address).
  final String? label;

  String get _label =>
      label ??
      switch (kind) {
        ContactKind.phone => 'Phone',
        ContactKind.website => 'Website',
        ContactKind.address => 'Address',
      };

  IconData get _icon => switch (kind) {
    ContactKind.phone => Icons.phone_outlined,
    ContactKind.website => Icons.language,
    ContactKind.address => Icons.place_outlined,
  };

  String get _action => switch (kind) {
    ContactKind.phone => 'Call',
    ContactKind.website => 'Open website',
    ContactKind.address => 'Open in Maps',
  };

  Uri get _uri => switch (kind) {
    ContactKind.phone => phoneUri(value),
    ContactKind.website => websiteUri(value),
    ContactKind.address => mapSearchUri(value),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    void open() => openLinkOrCopy(
      context,
      ref,
      uri: _uri,
      fallback: value,
      label: _label.toLowerCase(),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            button: true,
            label: '$_label, $value. $_action.',
            excludeSemantics: true,
            onTap: open,
            child: InkWell(
              onTap: open,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.sm),
                child: Row(
                  children: <Widget>[
                    Icon(_icon, color: colours.accent),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _label,
                            style: typography.small.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                          Text(
                            value,
                            style: typography.body.copyWith(
                              color: colours.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy ${_label.toLowerCase()}',
          onPressed: () => copyToClipboard(context, value, '$_label copied'),
          icon: Icon(
            Icons.copy_outlined,
            size: 18,
            color: colours.textTertiary,
          ),
        ),
      ],
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
