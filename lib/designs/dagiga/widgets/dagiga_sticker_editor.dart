import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '../constants/dagiga_constants.dart';

/// Sticker picker page styled for the Dagiga kit.
///
/// Content comes from [StickerEditorConfigs.builder] (Figma `6300:3557`).
class DagigaStickerEditor extends StatefulWidget {
  /// Creates a [DagigaStickerEditor].
  const DagigaStickerEditor({
    super.key,
    required this.configs,
    required this.callbacks,
  });

  /// Editor configs.
  final ProImageEditorConfigs configs;

  /// Editor callbacks.
  final ProImageEditorCallbacks callbacks;

  @override
  State<DagigaStickerEditor> createState() => _DagigaStickerEditorState();
}

class _DagigaStickerEditorState extends State<DagigaStickerEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDagigaStickerSheetBackground,
      body: SafeArea(
        child: StickerEditor(
          configs: widget.configs,
          callbacks: widget.callbacks,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}
