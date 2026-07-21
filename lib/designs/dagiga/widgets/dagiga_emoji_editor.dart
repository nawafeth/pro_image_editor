import 'package:flutter/material.dart';

import '/designs/grounded/widgets/grounded_emoji_editor.dart';
import '/pro_image_editor.dart';

/// Emoji picker page styled for the Dagiga kit (delegates to Grounded UI).
class DagigaEmojiEditor extends StatelessWidget {
  /// Creates a [DagigaEmojiEditor].
  const DagigaEmojiEditor({
    super.key,
    required this.configs,
    required this.callbacks,
  });

  /// Editor configs.
  final ProImageEditorConfigs configs;

  /// Editor callbacks.
  final ProImageEditorCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return GroundedEmojiEditor(configs: configs, callbacks: callbacks);
  }
}
