import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '../../dagiga_design.dart';

/// Tune adjustment toolbar for the Dagiga design kit.
class DagigaTuneBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaTuneBar].
  const DagigaTuneBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
  });

  /// Tune editor state.
  final TuneEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  @override
  State<DagigaTuneBar> createState() => _DagigaTuneBarState();
}

class _DagigaTuneBarState extends State<DagigaTuneBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  TuneEditorState get tuneEditor => widget.editor;

  @override
  Widget build(BuildContext context) {
    return DagigaBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: StreamBuilder(
              stream: tuneEditor.uiStream.stream,
              builder: (context, snapshot) {
                final activeOption =
                    tuneEditor.tuneAdjustmentList[tuneEditor.selectedIndex];
                final activeMatrix =
                    tuneEditor.tuneAdjustmentMatrix[tuneEditor.selectedIndex];
                return SizedBox(
                  height: 40,
                  child: Slider(
                    min: activeOption.min,
                    max: activeOption.max,
                    divisions: activeOption.divisions,
                    activeColor: kDagigaAccent,
                    label: (activeMatrix.value * activeOption.labelMultiplier)
                        .round()
                        .toString(),
                    value: activeMatrix.value,
                    onChangeStart: tuneEditor.onChangedStart,
                    onChanged: tuneEditor.onChanged,
                    onChangeEnd: tuneEditor.onChangedEnd,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: kBottomNavigationBarHeight,
            child: EditorScrollbar(
              controller: tuneEditor.bottomBarScrollCtrl,
              child: SingleChildScrollView(
                controller: tuneEditor.bottomBarScrollCtrl,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    tuneEditor.tuneAdjustmentMatrix.length,
                    (index) {
                      final item = tuneEditor.tuneAdjustmentList[index];
                      final selected = tuneEditor.selectedIndex == index;
                      return FlatIconTextButton(
                        label: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        icon: Icon(
                          item.icon,
                          size: 22,
                          color: selected ? kDagigaAccent : Colors.white,
                        ),
                        onPressed: () {
                          tuneEditor.setState(() {
                            tuneEditor.selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
