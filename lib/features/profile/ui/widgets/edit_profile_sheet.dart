/// The sheet where the golfer changes their handicap and home course. Profile
/// and Settings both open it, so there is one place the details are edited.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/user/golfer_form.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// Opens the edit sheet for the current golfer.
Future<void> showEditProfileSheet(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final colours = theme.extension<QaddyColours>()!;
  final spacing = theme.extension<QaddySpacing>()!;
  final golfer = ref.read(golferDetailsProvider);

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colours.surface1,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        0,
        spacing.lg,
        MediaQuery.viewInsetsOf(sheetContext).bottom + spacing.xl,
      ),
      child: SingleChildScrollView(
        child: GolferForm(
          initial: golfer,
          nameEditable: false,
          submitLabel: 'Save',
          onSubmit: (name, handicap, course) {
            ref
                .read(golferProvider.notifier)
                .save(firstName: name, handicap: handicap, homeCourse: course);
            QaddyHaptics.success();
            Navigator.of(sheetContext).pop();
          },
        ),
      ),
    ),
  );
}
