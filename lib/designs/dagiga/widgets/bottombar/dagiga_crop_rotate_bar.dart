import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/features/crop_rotate_editor/widgets/crop_aspect_ratio_button.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '../../dagiga_design.dart';

/// Crop / rotate toolbar for the Dagiga design kit.
class DagigaCropRotateBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaCropRotateBar].
  const DagigaCropRotateBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.selectedRatioColor,
  });

  /// Crop editor state.
  final CropRotateEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Highlight color for the active aspect ratio.
  final Color selectedRatioColor;

  @override
  State<DagigaCropRotateBar> createState() => _DagigaCropRotateBarState();
}

class _DagigaCropRotateBarState extends State<DagigaCropRotateBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _scrollCtrl;

  Color get _fg => cropRotateEditorConfigs.style.appBarColor;
  Color get _fgAccent => _fg.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DagigaBottomSheet(
      child: EditorScrollbar(
        controller: _scrollCtrl,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FlatIconTextButton(
                label: Text(
                  i18n.cropRotateEditor.rotate,
                  style: TextStyle(fontSize: 10, color: _fgAccent),
                ),
                icon: Icon(
                  cropRotateEditorConfigs.icons.rotate,
                  color: _fg,
                ),
                onPressed: widget.editor.rotate,
              ),
              FlatIconTextButton(
                label: Text(
                  i18n.cropRotateEditor.flip,
                  style: TextStyle(fontSize: 10, color: _fgAccent),
                ),
                icon: Icon(
                  cropRotateEditorConfigs.icons.flip,
                  color: _fg,
                ),
                onPressed: widget.editor.flip,
              ),
              if (cropRotateEditorConfigs.aspectRatios.isNotEmpty &&
                  cropRotateEditorConfigs.tools.contains(
                    CropRotateTool.aspectRatio,
                  )) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 36,
                  width: 1,
                  color: paintEditorConfigs.style.bottomBarInactiveItemColor,
                ),
                for (final item in cropRotateEditorConfigs.aspectRatios)
                  FlatIconTextButton(
                    label: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.editor.activeAspectRatio == item.value
                            ? widget.selectedRatioColor
                            : _fgAccent,
                      ),
                    ),
                    icon: SizedBox(
                      height: 28,
                      child: FittedBox(
                        child: AspectRatioButton(
                          aspectRatio: item.value,
                          isSelected:
                              widget.editor.activeAspectRatio == item.value,
                        ),
                      ),
                    ),
                    onPressed: () {
                      widget.editor.updateAspectRatio(item.value ?? -1);
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
