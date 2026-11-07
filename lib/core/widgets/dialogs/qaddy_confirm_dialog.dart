/// A themed yes/no confirmation, for actions that are hard to undo (delete,
/// leave, archive).
///
/// Built to the Dialogs Library: a `large`-radius surface with the `large`
/// shadow, an icon medallion, a centred title and message, and the two
/// actions side by side (Cancel on the left, the confirm action on the right).
/// A destructive confirmation uses the error colour (the library's Delete
/// Dialog) so it cannot be mistaken for a routine action.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';

/// Asks the user to confirm. Resolves to `true` only if they choose
/// [confirmLabel]; dismissing the dialog or tapping Cancel resolves to
/// `false`.
///
/// A [destructive] confirmation paints its medallion and confirm button with
/// the error colour. [icon] overrides the medallion's icon (a question mark
/// for a routine confirmation, a bin for a destructive one).
Future<bool> showQaddyConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colours = theme.extension<QaddyColours>()!;
      final spacing = theme.extension<QaddySpacing>()!;

      final tone = destructive ? colours.error : colours.secondary;
      final onTone = destructive
          ? theme.colorScheme.onError
          : theme.colorScheme.onPrimary;
      final medallionIcon =
          icon ??
          (destructive ? Icons.delete_outline : Icons.help_outline_rounded);

      return _DialogSurface(
        tone: tone,
        onTone: onTone,
        icon: medallionIcon,
        title: title,
        message: message,
        actions: Row(
          children: <Widget>[
            Expanded(
              child: QaddySecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: destructive
                  ? _DestructiveButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    )
                  : QaddyGoldButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

/// The library's Destructive Button: the error colour, white text, the same
/// Medium (48) size and shape as the other buttons.
class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final shape = BorderRadius.circular(radius.medium);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colours.error,
          borderRadius: shape,
          boxShadow: shadows.small,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: shape,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                minHeight: QaddyButtonHeight.medium,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.md),
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.button.copyWith(
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells the golfer something and, optionally, lets them carry on: the
/// Dialogs Library's Info / Success dialog. With no [actionLabel] there is no
/// button and (with [dismissible] false) no way out, for the rare message the
/// app must not move past.
Future<void> showQaddyNotice(
  BuildContext context, {
  required String title,
  required String message,
  String? actionLabel,
  IconData icon = Icons.check_rounded,
  bool dismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colours = theme.extension<QaddyColours>()!;

      return PopScope(
        canPop: dismissible,
        child: _DialogSurface(
          tone: colours.secondary,
          onTone: theme.colorScheme.onPrimary,
          icon: icon,
          title: title,
          message: message,
          actions: actionLabel == null
              ? null
              : QaddyGoldButton(
                  label: actionLabel,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
        ),
      );
    },
  );
}

/// The shared look of every Qaddy dialog: a `large`-radius surface with the
/// `large` shadow, an icon medallion and centred copy, then [actions].
class _DialogSurface extends StatelessWidget {
  const _DialogSurface({
    required this.tone,
    required this.onTone,
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });

  final Color tone;
  final Color onTone;
  final IconData icon;
  final String title;
  final String message;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: spacing.xl,
        vertical: spacing.xl,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: EdgeInsets.all(spacing.xl),
        decoration: BoxDecoration(
          color: colours.surface1,
          borderRadius: BorderRadius.circular(radius.large),
          border: Border.all(color: colours.border),
          boxShadow: shadows.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: spacing.display + spacing.sm,
              height: spacing.display + spacing.sm,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
              child: Icon(icon, size: spacing.xl + spacing.xs, color: onTone),
            ),
            SizedBox(height: spacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typography.h4.copyWith(
                color: colours.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
            if (actions != null) ...<Widget>[
              SizedBox(height: spacing.xl),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
