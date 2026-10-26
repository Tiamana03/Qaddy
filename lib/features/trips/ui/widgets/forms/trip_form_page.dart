/// The frame every Edit Trip form shares: a titled page, the form's fields,
/// a Save button and, for existing items, a Delete button.
///
/// Errors stay hidden until the first Save attempt, so an untouched form
/// doesn't open covered in red. The page only reports "save" once the form's
/// own `validate` passes, then closes itself.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/dialogs/qaddy_confirm_dialog.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

/// A form page.
class TripFormPage extends StatefulWidget {
  const TripFormPage({
    required this.title,
    required this.fallbackRoute,
    required this.builder,
    required this.validate,
    required this.onSave,
    this.saveLabel = 'Save',
    this.onDelete,
    this.deleteTitle,
    this.deleteMessage,
    super.key,
  });

  /// The app bar title.
  final String title;

  /// Where to go when saving or deleting if there is nothing to pop back to
  /// (e.g. the page was opened from a link).
  final String fallbackRoute;

  /// Builds the fields. `submitted` is `true` after the first Save attempt;
  /// fields show their errors from then on.
  final List<Widget> Function(BuildContext context, {required bool submitted})
  builder;

  /// Whether the form is currently valid.
  final bool Function() validate;

  /// Applies the form. Called only when [validate] passes; the page closes
  /// afterwards.
  final VoidCallback onSave;

  /// The Save button's label.
  final String saveLabel;

  /// Removes the item being edited. Omit for a form that is adding something
  /// new (no Delete button is shown).
  final VoidCallback? onDelete;

  /// The delete confirmation's title.
  final String? deleteTitle;

  /// The delete confirmation's message.
  final String? deleteMessage;

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  bool _submitted = false;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.fallbackRoute);
    }
  }

  void _save() {
    setState(() => _submitted = true);
    if (!widget.validate()) {
      return;
    }
    widget.onSave();
    _close();
  }

  Future<void> _delete() async {
    final confirmed = await showQaddyConfirm(
      context,
      title: widget.deleteTitle ?? 'Delete this item?',
      message: widget.deleteMessage ?? 'This can’t be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    widget.onDelete!();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            ...widget.builder(context, submitted: _submitted),
            SizedBox(height: spacing.sectionGap),
            QaddyPrimaryButton(label: widget.saveLabel, onPressed: _save),
            if (widget.onDelete != null) ...<Widget>[
              SizedBox(height: spacing.sm),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: colours.error,
                  minimumSize: Size.fromHeight(spacing.display),
                ),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// A tidy gap between two fields.
class TripFieldGap extends StatelessWidget {
  const TripFieldGap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: Theme.of(context).extension<QaddySpacing>()!.md);
  }
}
