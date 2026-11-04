/// The fields that make Qaddy the golfer's own: a first name, and — if they
/// like — a handicap and a home course. Used on first launch and again in
/// Settings, so they look and behave the same in both.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';

/// What the golfer filled in, already checked.
typedef GolferFormSubmit =
    void Function(String firstName, double? handicap, String? homeCourse);

/// The golfer's details form.
class GolferForm extends StatefulWidget {
  const GolferForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
    this.autofocus = false,
    this.nameEditable = true,
    super.key,
  });

  /// What the fields start with (the golfer's current details), if any.
  final GolferProfile? initial;

  /// The button's text, e.g. "Let's play" or "Save".
  final String submitLabel;

  /// Called with the checked values when the golfer submits.
  final GolferFormSubmit onSubmit;

  /// Whether the name field takes the keyboard straight away.
  final bool autofocus;

  /// Whether the name can be changed. Once the golfer's rounds are recorded
  /// under it, it cannot.
  final bool nameEditable;

  @override
  State<GolferForm> createState() => _GolferFormState();
}

class _GolferFormState extends State<GolferForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.firstName,
  );
  late final TextEditingController _handicap = TextEditingController(
    text: widget.initial?.handicap == null
        ? ''
        : handicapLabel(widget.initial!.handicap!),
  );
  late final TextEditingController _course = TextEditingController(
    text: widget.initial?.homeCourse,
  );

  /// Errors only show once the golfer has tried to save.
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _handicap.dispose();
    _course.dispose();
    super.dispose();
  }

  String? get _nameError => _submitted ? validateFirstName(_name.text) : null;

  String? get _handicapError =>
      _submitted ? validateHandicapText(_handicap.text) : null;

  void _submit() {
    setState(() => _submitted = true);
    if (validateFirstName(_name.text) != null ||
        validateHandicapText(_handicap.text) != null) {
      return;
    }
    widget.onSubmit(
      _name.text.trim(),
      parseHandicap(_handicap.text),
      _course.text.trim().isEmpty ? null : _course.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final name = _name.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The avatar fills in as the name is typed: a small "that's me".
        Center(
          child: AnimatedSwitcher(
            duration: QaddyMotion.standard.fast,
            child: Row(
              key: ValueKey<String>(name),
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 72,
                  height: 72,
                  child: FittedBox(
                    child: QaddyAvatar(name: name.isEmpty ? '?' : name),
                  ),
                ),
                SizedBox(width: spacing.lg),
                Text(
                  name.isEmpty ? 'You' : name,
                  style: typography.h2.copyWith(color: colours.textPrimary),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.xl),
        QaddyTextField(
          controller: _name,
          label: 'First name',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofocus: widget.autofocus,
          enabled: widget.nameEditable,
          prefixIcon: const Icon(Icons.person_outline),
          errorText: _nameError,
          onChanged: (_) => setState(() {}),
        ),
        if (!widget.nameEditable)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: Text(
              'Your name stays while Qaddy holds your rounds. '
              '"Start over" in Settings lets you choose another.',
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ),
        SizedBox(height: spacing.md),
        QaddyTextField(
          controller: _handicap,
          label: 'Handicap (optional)',
          hintText: 'e.g. 12 or 8.4',
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.speed),
          errorText: _handicapError,
        ),
        SizedBox(height: spacing.md),
        QaddyTextField(
          controller: _course,
          label: 'Home course (optional)',
          hintText: 'Where do you play most?',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.flag_outlined),
          onSubmitted: (_) => _submit(),
        ),
        SizedBox(height: spacing.sm),
        Text(
          'Only ever kept on this phone.',
          textAlign: TextAlign.center,
          style: typography.small.copyWith(color: colours.textSecondary),
        ),
        SizedBox(height: spacing.lg),
        QaddyGoldButton(
          label: widget.submitLabel,
          icon: Icons.sports_golf,
          tall: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}
