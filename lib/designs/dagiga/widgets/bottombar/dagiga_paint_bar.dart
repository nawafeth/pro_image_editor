import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '../../dagiga_design.dart';

/// Paint toolbar for the Dagiga design kit.
class DagigaPaintBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaPaintBar].
  const DagigaPaintBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.i18nColor,
    required this.showColorPicker,
  });

  /// Paint editor state.
  final PaintEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Localized color label.
  final String i18nColor;

  /// Shows the color picker sheet.
  final void Function(Color currentColor) showColorPicker;

  @override
  State<DagigaPaintBar> createState() => _DagigaPaintBarState();
}

class _DagigaPaintBarState extends State<DagigaPaintBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late final ScrollController _scrollCtrl;

  Color get _fg => paintEditorConfigs.style.appBarColor;
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
              ..._buildConfigs(),
              _divider(),
              if (paintEditorConfigs.enableZoom) ...[
                _toolButton(
                  label: i18n.paintEditor.moveAndZoom,
                  icon: paintEditorConfigs.icons.moveAndZoom,
                  selected: widget.editor.paintMode == PaintMode.moveAndZoom,
                  onPressed: () =>
                      widget.editor.setMode(PaintMode.moveAndZoom),
                ),
                _divider(),
              ],
              for (final item in widget.editor.tools)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _toolButton(
                    label: item.label,
                    icon: item.icon,
                    selected: widget.editor.paintMode == item.mode,
                    onPressed: () => widget.editor.setMode(item.mode),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfigs() {
    return [
      _toolButton(
        label: widget.i18nColor,
        icon: Icons.color_lens_outlined,
        onPressed: () => widget.showColorPicker(widget.editor.activeColor),
      ),
      _toolButton(
        label: i18n.paintEditor.lineWidth,
        icon: paintEditorConfigs.icons.lineWeight,
        onPressed: widget.editor.openLinWidthBottomSheet,
      ),
      _toolButton(
        label: i18n.paintEditor.changeOpacity,
        icon: paintEditorConfigs.icons.changeOpacity,
        onPressed: widget.editor.openOpacityBottomSheet,
      ),
      if (widget.editor.paintMode == PaintMode.rect ||
          widget.editor.paintMode == PaintMode.circle)
        _toolButton(
          label: i18n.paintEditor.toggleFill,
          icon: widget.editor.fillBackground
              ? paintEditorConfigs.icons.fill
              : paintEditorConfigs.icons.noFill,
          onPressed: widget.editor.toggleFill,
        ),
    ];
  }

  Widget _toolButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool selected = false,
  }) {
    final color = selected
        ? paintEditorConfigs.style.bottomBarActiveItemColor
        : _fgAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FlatIconTextButton(
        label: Text(label, style: TextStyle(fontSize: 10, color: color)),
        icon: Icon(icon, color: selected ? color : _fg),
        onPressed: onPressed,
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 36,
      width: 1,
      color: paintEditorConfigs.style.bottomBarInactiveItemColor,
    );
  }
}
