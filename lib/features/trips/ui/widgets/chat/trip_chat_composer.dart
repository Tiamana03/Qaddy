/// The message box at the foot of Trip Chat: emoji button, text field, send.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/forms/qaddy_text_field.dart';

/// The emoji offered by the tray — golf, travel and banter.
const List<String> chatEmoji = <String>[
  '😀', '😂', '😍', '😎', '🤝', '👍', //
  '👏', '🙌', '💪', '🔥', '🎯', '🏆',
  '⛳', '🏌️', '🍺', '🍻', '🥂', '🍽️',
  '✈️', '🚗', '🏨', '☀️', '🌤️', '🌧️',
];

/// Text field + emoji tray + send button. The parent owns the
/// [controller] and decides what "send" does.
class TripChatComposer extends StatefulWidget {
  const TripChatComposer({
    required this.controller,
    required this.onSend,
    super.key,
  });

  /// The message being typed.
  final TextEditingController controller;

  /// Called when the golfer taps Send with a non-blank message.
  final VoidCallback onSend;

  @override
  State<TripChatComposer> createState() => _TripChatComposerState();
}

class _TripChatComposerState extends State<TripChatComposer> {
  final FocusNode _focus = FocusNode();
  bool _showEmoji = false;

  bool get _canSend => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    // Typing and the emoji tray are alternatives, like Messenger's.
    _focus.addListener(() {
      if (_focus.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  @override
  void didUpdateWidget(TripChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _toggleEmoji() {
    if (_showEmoji) {
      setState(() => _showEmoji = false);
      _focus.requestFocus();
    } else {
      _focus.unfocus();
      setState(() => _showEmoji = true);
    }
  }

  /// Inserts [emoji] at the cursor (or at the end if there is none).
  void _insert(String emoji) {
    final controller = widget.controller;
    final value = controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    controller.value = value.copyWith(
      text: value.text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colours.background,
        border: Border(top: BorderSide(color: colours.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  tooltip: _showEmoji ? 'Show keyboard' : 'Add emoji',
                  onPressed: _toggleEmoji,
                  icon: Icon(
                    _showEmoji
                        ? Icons.keyboard_outlined
                        : Icons.emoji_emotions_outlined,
                    color: colours.textSecondary,
                  ),
                ),
                Expanded(
                  child: QaddyTextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    hintText: 'Message',
                    minLines: 1,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                SizedBox(width: spacing.sm),
                IconButton.filled(
                  tooltip: 'Send message',
                  onPressed: _canSend ? widget.onSend : null,
                  style: IconButton.styleFrom(
                    backgroundColor: colours.accent,
                    foregroundColor: colours.background,
                    disabledBackgroundColor: colours.surface2,
                    disabledForegroundColor: colours.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius.medium),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
          if (_showEmoji)
            SizedBox(
              height: 168,
              child: GridView.count(
                crossAxisCount: 6,
                padding: EdgeInsets.only(bottom: spacing.sm),
                children: <Widget>[
                  for (final emoji in chatEmoji)
                    Semantics(
                      button: true,
                      label: 'Insert $emoji',
                      excludeSemantics: true,
                      onTap: () => _insert(emoji),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(radius.medium),
                        onTap: () => _insert(emoji),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
