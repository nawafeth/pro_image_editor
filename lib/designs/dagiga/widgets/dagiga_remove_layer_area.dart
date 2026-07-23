import 'package:flutter/material.dart';

import '/features/main_editor/main_editor.dart';

/// Drag-to-delete zone for Dagiga — bottom-left instead of the default top-left.
class DagigaRemoveLayerArea extends StatelessWidget {
  /// Creates a [DagigaRemoveLayerArea].
  const DagigaRemoveLayerArea({
    super.key,
    required this.removeAreaKey,
    required this.editor,
    required this.rebuildStream,
    required this.isLayerBeingTransformed,
  });

  /// Key used by [LayerInteractionManager] for hover hit-testing.
  final GlobalKey removeAreaKey;

  /// Main editor state.
  final ProImageEditorState editor;

  /// Rebuild stream from the remove-button controller.
  final Stream<void> rebuildStream;

  /// Whether a layer is currently being dragged or scaled.
  final bool isLayerBeingTransformed;

  @override
  Widget build(BuildContext context) {
    final layerInteraction = editor.configs.layerInteraction;
    final manager = editor.layerInteractionManager;

    return Positioned(
      key: removeAreaKey,
      // bottom: editor.sizesManager.bottomBarHeight,
      bottom: 24,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        bottom: false,
        child: StreamBuilder(
          stream: rebuildStream,
          builder: (_, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isLayerBeingTransformed
                  ? Container(
                height: kToolbarHeight,
                width: kToolbarHeight,
                decoration: BoxDecoration(
                  color: manager.hoverRemoveBtn
                      ? layerInteraction.style.removeAreaBackgroundActive
                      .withOpacity(.2)
                      : layerInteraction.style
                      .copyWith(
                      removeAreaBackgroundInactive: Colors.grey.withOpacity(.2))
                      .removeAreaBackgroundInactive,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                // padding: const EdgeInsets.only(right: 12, top: 7),
                child: Center(
                  child: Icon(
                    editor.mainEditorConfigs.icons.removeElementZone,
                    size: 28,
                  ),
                ),
              )
                  : SizedBox.shrink(key: UniqueKey()),
            );
          },
        ),
      ),
    );
  }
}
