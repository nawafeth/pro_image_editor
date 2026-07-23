import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';

/// The `StickerEditor` class is responsible for creating a widget that allows
/// users to select stickers
class StickerEditor extends StatefulWidget with SimpleConfigsAccess {
  /// Creates an `StickerEditor` widget.
  const StickerEditor({
    super.key,
    required this.configs,
    this.callbacks = const ProImageEditorCallbacks(),
    required this.scrollController,
    this.builderOverride,
    this.keepOpenOnSelect = false,
    this.onLayerSelected,
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Controller for managing scroll actions.
  final ScrollController scrollController;

  /// Optional builder override (e.g. logo library). Falls back to configs.
  final StickerBuilder? builderOverride;

  /// When true, [setLayer] notifies [onLayerSelected] instead of popping.
  final bool keepOpenOnSelect;

  /// Called when a layer is selected while [keepOpenOnSelect] is true.
  final ValueChanged<WidgetLayer>? onLayerSelected;

  @override
  createState() => StickerEditorState();
}

/// The state class for the `StickerEditor` widget.
class StickerEditorState extends State<StickerEditor>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    callbacks.stickerEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callbacks.stickerEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final builder =
        widget.builderOverride ?? stickerEditorConfigs.builder;
    assert(builder != null, '`builder` is required');

    return ExtendedPopScope(
      canPop: stickerEditorConfigs.enableGesturePop,
      child: builder!.call(
        setLayer,
        widget.scrollController,
      ),
    );
  }

  /// Applies the selected widget-layer.
  ///
  /// Closes the sheet unless [StickerEditor.keepOpenOnSelect] is enabled.
  void setLayer(WidgetLayer widgetLayer) {
    if (widget.keepOpenOnSelect) {
      widget.onLayerSelected?.call(widgetLayer);
      return;
    }
    Navigator.of(context).pop(widgetLayer);
  }
}
