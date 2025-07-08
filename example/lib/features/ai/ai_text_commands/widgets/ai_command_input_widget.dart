import 'package:flutter/material.dart';

/// A stateless widget for inputting and sending AI text commands.
class AiCommandInputWidget extends StatelessWidget {
  /// Creates the AI command input widget.
  const AiCommandInputWidget({
    super.key,
    required this.isProcessingNotifier,
    required this.inputCtrl,
    required this.inputFocus,
    required this.onSend,
  });

  /// Indicates whether a command is currently being processed.
  final ValueNotifier<bool> isProcessingNotifier;

  /// Controller for the text input field.
  final TextEditingController inputCtrl;

  /// Focus node for managing the text field's focus.
  final FocusNode inputFocus;

  /// Callback triggered when the send button is pressed.
  final Function() onSend;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isProcessingNotifier,
      builder: (_, isProcessing, __) {
        return TextField(
          readOnly: isProcessing,
          onEditingComplete: onSend,
          controller: inputCtrl,
          focusNode: inputFocus,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF28282C),
            border: const OutlineInputBorder(),
            hint: const Text(
              'Enter your command for what the AI should add or change...',
              style: TextStyle(color: Colors.white54),
            ),
            suffixIcon: _buildSuffixIcon(isProcessing),
          ),
        );
      },
    );
  }

  Widget _buildSuffixIcon(bool isProcessing) {
    return Padding(
      padding: const EdgeInsets.only(right: 7.0),
      child: isProcessing
          ? const SizedBox.square(
              dimension: 24,
              child: FittedBox(
                child: CircularProgressIndicator(),
              ),
            )
          : IconButton(
              tooltip: 'Send to AI',
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
    );
  }
}
