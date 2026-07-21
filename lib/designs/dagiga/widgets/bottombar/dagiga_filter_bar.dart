   import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/utils/size_utils.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '../../dagiga_design.dart';

/// Filter toolbar for the Dagiga design kit.
class DagigaFilterBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaFilterBar].
  const DagigaFilterBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    this.image,
  });

  /// Filter editor state.
  final FilterEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Optional preview image override.
  final Widget? image;

  @override
  State<DagigaFilterBar> createState() => _DagigaFilterBarState();
}

class _DagigaFilterBarState extends State<DagigaFilterBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _scrollCtrl;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.editor.selectedFilter.filters.isNotEmpty
                ? StatefulBuilder(
                    builder: (context, setState) {
                      return Slider(
                        min: 0,
                        max: 1,
                        divisions: 100,
                        activeColor: kDagigaAccent,
                        value: widget.editor.filterOpacity,
                        onChanged: (value) {
                          widget.editor.setFilterOpacity(value);
                          setState(() {});
                        },
                      );
                    },
                  )
                : const SizedBox(height: 8),
          ),
          EditorScrollbar(
            controller: _scrollCtrl,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: FilterEditorItemList(
                listHeight: kDagigaFilterListHeight,
                previewImageSize: const Size(48, 48),
                borderRadius: BorderRadius.circular(8),
                mainBodySize: getValidSizeOrDefault(
                  widget.editor.mainBodySize,
                  widget.editor.editorBodySize,
                ),
                mainImageSize: getValidSizeOrDefault(
                  widget.editor.mainImageSize,
                  widget.editor.editorBodySize,
                ),
                editorImage: widget.editor.editorImage,
                image: widget.image,
                activeFilters: widget.editor.appliedFilters,
                blurFactor: widget.editor.appliedBlurFactor,
                configs: configs,
                transformConfigs: widget.editor.initialTransformConfigs,
                selectedFilter: widget.editor.selectedFilter.filters,
                onSelectFilter: widget.editor.setFilter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
