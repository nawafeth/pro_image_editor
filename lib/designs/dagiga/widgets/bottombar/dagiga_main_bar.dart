import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/pro_image_editor.dart';
import '/shared/widgets/editor_scrollbar.dart';
import '../../dagiga_design.dart';

/// Main bottom navigation for the Dagiga design kit.
///
/// Tools come from [MainEditorConfigs.tools] and scroll horizontally when
/// there are more chips than fit on screen.
class DagigaMainBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaMainBar].
  const DagigaMainBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    this.toolOverrides,
  });

  /// The editor state.
  final ProImageEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Optional per-tool tap handlers (e.g. Logo → sticker picker).
  final Map<SubEditorMode, VoidCallback>? toolOverrides;

  @override
  State<DagigaMainBar> createState() => DagigaMainBarState();
}

/// State for [DagigaMainBar].
class DagigaMainBarState extends State<DagigaMainBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  final _contentKey = GlobalKey();

  late final ScrollController _bottomBarScrollCtrl;

  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
  }

  void _setContentWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _contentWidth = renderBox.size.width;
      }
    });
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEmojiEditor() async {
    final layer = await widget.editor.openPage(
      DagigaEmojiEditor(configs: configs, callbacks: callbacks),
    );
    if (layer == null || !mounted) return;
    layer.scale = configs.emojiEditor.initScale;
    widget.editor.addLayer(layer);
  }

  void _openStickerEditor() {
    // Same modal DraggableScrollableSheet as Logo / Add Sticker entry —
    // not a full-page route (Figma bottom sheet that collapses).
    widget.editor.openStickerEditor();
  }

  @override
  Widget build(BuildContext context) {
    // Collapse while dragging / transforming any layer so the canvas is clear.
    if (widget.editor.isLayerBeingTransformed) {
      return const SizedBox.shrink();
    }

    final hideTools =
        widget.editor.isSubEditorOpen && !widget.editor.isSubEditorClosing;

    return DagigaBottomSheet(
      variant: DagigaBottomSheetVariant.mainTools,
      child: EditorScrollbar(
        controller: _bottomBarScrollCtrl,
        child: AnimatedSwitcher(
          duration: kDagigaFadeInDuration * 2,
          reverseDuration: Duration.zero,
          child: hideTools
              ? SizedBox(key: const ValueKey('hidden'), width: _contentWidth)
              : _buildToolRow(),
        ),
      ),
    );
  }

  Widget _buildToolRow() {
    _setContentWidth();
    final tools = widget.editor.configs.mainEditor.tools;
    final chips = tools
        .map((tool) => _mapToolToChip(tool, expanded: tools.length <= 3))
        .whereType<Widget>()
        .toList();

    // Figma shows 3 equal pills; scroll when more tools are enabled.
    if (tools.length <= 3) {
      return Row(
        key: const ValueKey('tools-flex'),
        children: _withGaps(chips, kDagigaMainToolGap),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('tools-scroll'),
      controller: _bottomBarScrollCtrl,
      scrollDirection: Axis.horizontal,
      child: Row(
        key: _contentKey,
        children: _withGaps(chips, kDagigaMainToolGap),
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> children, double gap) {
    if (children.isEmpty) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) result.add(SizedBox(width: gap));
      result.add(children[i]);
    }
    return result;
  }

  Widget? _mapToolToChip(SubEditorMode tool, {required bool expanded}) {
    Widget chip({
      required String label,
      required IconData icon,
      required VoidCallback onPressed,
    }) {
      return DagigaToolChip(
        label: label,
        icon: icon,
        expanded: expanded,
        onPressed: widget.toolOverrides?[tool] ?? onPressed,
        leading: DagigaToolIcon.build(mode: tool, fallback: icon),
      );
    }

    switch (tool) {
      case SubEditorMode.paint:
        return chip(
          label: i18n.paintEditor.bottomNavigationBarText,
          icon: paintEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openPaintEditor,
        );
      case SubEditorMode.text:
        return chip(
          label: i18n.textEditor.bottomNavigationBarText,
          icon: textEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openTextEditor,
        );
      case SubEditorMode.cropRotate:
        return chip(
          label: i18n.cropRotateEditor.bottomNavigationBarText,
          icon: cropRotateEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openCropRotateEditor,
        );
      case SubEditorMode.tune:
        return chip(
          label: i18n.tuneEditor.bottomNavigationBarText,
          icon: tuneEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openTuneEditor,
        );
      case SubEditorMode.filter:
        return chip(
          label: i18n.filterEditor.bottomNavigationBarText,
          icon: filterEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openFilterEditor,
        );
      case SubEditorMode.blur:
        return chip(
          label: i18n.blurEditor.bottomNavigationBarText,
          icon: blurEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openBlurEditor,
        );
      case SubEditorMode.emoji:
        return chip(
          label: i18n.emojiEditor.bottomNavigationBarText,
          icon: emojiEditorConfigs.icons.bottomNavBar,
          onPressed: _openEmojiEditor,
        );
      case SubEditorMode.sticker:
        return chip(
          label: i18n.stickerEditor.bottomNavigationBarText,
          icon: stickerEditorConfigs.icons.bottomNavBar,
          onPressed: _openStickerEditor,
        );
      case SubEditorMode.audio:
        return chip(
          label: i18n.audioEditor.bottomNavigationBarText,
          icon: audioEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openAudioEditor,
        );
      case SubEditorMode.videoClips:
        return chip(
          label: i18n.clipsEditor.bottomNavigationBarText,
          icon: clipsEditorConfigs.icons.bottomNavBar,
          onPressed: widget.editor.openClipsEditor,
        );
    }
  }
}
