import 'package:example/features/ai/ai_text_commands/widgets/ai_command_input_widget.dart';
import 'package:flutter/material.dart';

import 'ai_example_commands_widget.dart';

/// A toolbar widget for sending AI commands with input and control states.
class AiCommandToolbarWidget extends StatefulWidget {
  /// Creates the AI command toolbar.
  const AiCommandToolbarWidget({
    super.key,
    required this.isProcessingNotifier,
    required this.alignTopNotifier,
    required this.inputCtrl,
    required this.inputFocus,
    required this.onSend,
  });

  /// Indicates whether a command is currently being processed.
  final ValueNotifier<bool> isProcessingNotifier;

  /// Controls whether the toolbar is aligned to the top.
  final ValueNotifier<bool> alignTopNotifier;

  /// Controller for the input text field.
  final TextEditingController inputCtrl;

  /// Focus node for the input field.
  final FocusNode inputFocus;

  /// Callback triggered when the send button is pressed.
  final Function() onSend;

  @override
  State<AiCommandToolbarWidget> createState() => _AiCommandToolbarWidgetState();
}

class _AiCommandToolbarWidgetState extends State<AiCommandToolbarWidget> {
  final _animationDuration = const Duration(milliseconds: 220);

  void _openExampleCommands() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AiExampleCommandsWidget(),
    );

    if (result != null) {
      widget.inputCtrl.value = TextEditingValue(text: result);
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.alignTopNotifier,
        builder: (_, alignTop, __) {
          return AnimatedAlign(
            duration: _animationDuration,
            alignment: alignTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: AiCommandInputWidget(
                      isProcessingNotifier: widget.isProcessingNotifier,
                      inputCtrl: widget.inputCtrl,
                      inputFocus: widget.inputFocus,
                      onSend: widget.onSend,
                    ),
                  ),
                  IconButton(
                    tooltip: 'List of Example Commands',
                    icon: const Icon(Icons.info_outline),
                    onPressed: _openExampleCommands,
                  ),
                  IconButton(
                    tooltip: 'Shift the input to the other side of the screen',
                    icon: AnimatedRotation(
                      duration: _animationDuration,
                      turns: widget.alignTopNotifier.value ? 0.5 : 0,
                      child: const Icon(Icons.arrow_upward),
                    ),
                    onPressed: () {
                      widget.alignTopNotifier.value =
                          !widget.alignTopNotifier.value;
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
