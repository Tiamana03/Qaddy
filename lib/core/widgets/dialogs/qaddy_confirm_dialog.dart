/// A themed yes/no confirmation, for actions that are hard to undo (delete,
/// leave, archive).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';

/// Asks the user to confirm. Resolves to `true` only if they choose
/// [confirmLabel]; dismissing the dialog or tapping Cancel resolves to
/// `false`.
///
/// A [destructive] confirmation paints its confirm button with the error
/// colour so it can't be mistaken for a routine action.
Future<bool> showQaddyConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colours = theme.extension<QaddyColours>()!;
      final radius = theme.extension<QaddyRadius>()!;
      final spacing = theme.extension<QaddySpacing>()!;
      final typography = theme.extension<QaddyTypography>()!;

      return AlertDialog(
        backgroundColor: colours.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.large),
        ),
        title: Text(
          title,
          style: typography.h4.copyWith(color: colours.textPrimary),
        ),
        content: Text(
          message,
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          spacing.lg,
          0,
          spacing.lg,
          spacing.lg,
        ),
        actions: <Widget>[
          QaddyTertiaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          if (destructive)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colours.error,
                foregroundColor: theme.colorScheme.onError,
                minimumSize: Size(spacing.hero, spacing.display),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius.medium),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel, style: typography.button),
            )
          else
            QaddyPrimaryButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
        ],
      );
    },
  );
  return result ?? false;
}
