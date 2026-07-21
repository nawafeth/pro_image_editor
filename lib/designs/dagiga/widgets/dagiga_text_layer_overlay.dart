import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/main_editor.dart';
import '../constants/dagiga_constants.dart';

/// Floating menu shown above a selected text layer (Figma `6262:8352`).
///
/// First tap selects the layer and shows this menu. A second tap opens the
/// text editor for re-editing.
class DagigaTextLayerOverlay extends StatefulWidget {
  /// Creates a [DagigaTextLayerOverlay].
  const DagigaTextLayerOverlay({
    super.key,
    required this.info,
    required this.layer,
    required this.interactions,
    required this.editorKey,
    this.safeArea = EdgeInsets.zero,
  });

  /// Layout info from the editor overlay.
  final OverlayChildLayoutInfo info;

  /// Selected layer.
  final Layer layer;

  /// Built-in interaction callbacks (edit / remove / duplicate).
  final LayerItemInteractions interactions;

  /// Editor state key.
  final GlobalKey<ProImageEditorState> editorKey;

  /// Safe-area insets used when clamping the menu position.
  final EdgeInsets safeArea;

  @override
  State<DagigaTextLayerOverlay> createState() => _DagigaTextLayerOverlayState();
}

class _DagigaTextLayerOverlayState extends State<DagigaTextLayerOverlay> {
  final _overlayCtrl = OverlayPortalController();
  final _layerKey = GlobalKey();
  final _stackKey = GlobalKey();
  final _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _overlayCtrl.show();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    if (_overlayCtrl.isShowing) _overlayCtrl.hide();
    super.dispose();
  }

  TextLayer? get _textLayer =>
      widget.layer.isTextLayer ? widget.layer as TextLayer : null;

  ProImageEditorState? get _editor => widget.editorKey.currentState;

  bool get _isBold {
    final weight = _textLayer?.textStyle?.fontWeight ?? FontWeight.w400;
    return weight.value >= FontWeight.w600.value;
  }

  bool get _isItalic =>
      _textLayer?.textStyle?.fontStyle == FontStyle.italic;

  bool get _isUnderline {
    final decoration = _textLayer?.textStyle?.decoration;
    return decoration != null &&
        decoration != TextDecoration.none &&
        decoration.contains(TextDecoration.underline);
  }

  void _updateTextStyle(TextStyle Function(TextStyle base) transform) {
    final editor = _editor;
    final layer = _textLayer;
    if (editor == null || layer == null) return;

    final base = layer.textStyle ?? const TextStyle();
    layer.textStyle = transform(base);
    editor
      ..addHistory()
      ..setState(() {});
    setState(() {});
  }

  void _toggleBold() {
    _updateTextStyle((base) {
      final next = _isBold ? FontWeight.w400 : FontWeight.w700;
      return base.copyWith(fontWeight: next);
    });
  }

  void _toggleItalic() {
    _updateTextStyle((base) {
      return base.copyWith(
        fontStyle: _isItalic ? FontStyle.normal : FontStyle.italic,
      );
    });
  }

  void _toggleUnderline() {
    _updateTextStyle((base) {
      final current = base.decoration ?? TextDecoration.none;
      final next = current.contains(TextDecoration.underline)
          ? TextDecoration.none
          : TextDecoration.underline;
      return base.copyWith(decoration: next);
    });
  }

  Offset _menuOffset() {
    final layerBox = _layerKey.currentContext?.findRenderObject();
    final parentBox = _stackKey.currentContext?.findRenderObject();
    final menuBox = _menuKey.currentContext?.findRenderObject();

    if (layerBox is! RenderBox ||
        parentBox is! RenderBox ||
        !layerBox.hasSize ||
        !parentBox.hasSize) {
      return Offset.zero;
    }

    final layerSize = layerBox.size;
    final parentSize = parentBox.size;

    final topLeft = parentBox.globalToLocal(
      layerBox.localToGlobal(Offset.zero),
    );
    final topRight = parentBox.globalToLocal(
      layerBox.localToGlobal(Offset(layerSize.width, 0)),
    );
    final bottomLeft = parentBox.globalToLocal(
      layerBox.localToGlobal(Offset(0, layerSize.height)),
    );
    final bottomRight = parentBox.globalToLocal(
      layerBox.localToGlobal(Offset(layerSize.width, layerSize.height)),
    );

    final xs = [topLeft.dx, topRight.dx, bottomLeft.dx, bottomRight.dx];
    final ys = [topLeft.dy, topRight.dy, bottomLeft.dy, bottomRight.dy];
    final minX = xs.reduce(min);
    final maxX = xs.reduce(max);
    final minY = ys.reduce(min);
    final centerX = (minX + maxX) / 2;

    var menuWidth = 0.0;
    var menuHeight = 0.0;
    if (menuBox is RenderBox) {
      menuWidth = menuBox.size.width;
      menuHeight = menuBox.size.height;
    }

    final dx = centerX.clamp(
      menuWidth / 2 + widget.safeArea.left,
      parentSize.width - menuWidth / 2 - widget.safeArea.right,
    );
    // Figma places the menu just above the selection (~12px gap).
    final dy = (minY - 12).clamp(
      menuHeight + widget.safeArea.top,
      parentSize.height - widget.safeArea.bottom,
    );

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.layer.isTextLayer) {
      return const SizedBox.shrink();
    }

    final transform = widget.info.childPaintTransform.clone();
    final width = widget.info.childSize.width;
    final height = widget.info.childSize.height;

    return Stack(
      key: _stackKey,
      children: [
        // Border must not absorb gestures so the text layer stays draggable.
        Positioned(
          width: width,
          height: height,
          left: 0,
          child: IgnorePointer(
            child: Transform(
              transform: transform,
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                key: _layerKey,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kDagigaSelectionBorder,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        OverlayPortal(
          controller: _overlayCtrl,
          overlayChildBuilder: (context) {
            final offset = _menuOffset();
            return Positioned(
              top: offset.dy,
              left: offset.dx,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -1),
                child: _TextStyleMenu(
                  key: _menuKey,
                  isBold: _isBold,
                  isItalic: _isItalic,
                  isUnderline: _isUnderline,
                  onBold: _toggleBold,
                  onItalic: _toggleItalic,
                  onUnderline: _toggleUnderline,
                  onDuplicate: widget.interactions.duplicated,
                  onDelete: widget.interactions.remove,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// White floating toolbar matching Figma node `6266:2002`.
class _TextStyleMenu extends StatelessWidget {
  const _TextStyleMenu({
    super.key,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onDuplicate,
    required this.onDelete,
  });

  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      shadowColor: Colors.black,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            // M3 Elevation Light/2 from Figma.
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuIconButton(
                asset: kDagigaMenuBoldAsset,
                selected: isBold,
                tooltip: 'Bold',
                onTap: onBold,
              ),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuItalicAsset,
                selected: isItalic,
                tooltip: 'Italic',
                onTap: onItalic,
              ),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuUnderlineAsset,
                selected: isUnderline,
                tooltip: 'Underline',
                onTap: onUnderline,
              ),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuDuplicateAsset,
                tooltip: 'Duplicate',
                onTap: onDuplicate,
              ),
              const SizedBox(width: 16),
              const _MenuSeparator(),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuDeleteAsset,
                tooltip: 'Delete',
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSeparator extends StatelessWidget {
  const _MenuSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 16,
      color: const Color(0x80000529),
    );
  }
}

class _MenuIconButton extends StatelessWidget {
  const _MenuIconButton({
    required this.asset,
    required this.onTap,
    required this.tooltip,
    this.selected = false,
  });

  final String asset;
  final VoidCallback onTap;
  final String tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected ? const Color(0x14000529) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),    
        ),
      
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 14,
            height: 14,
            child: SvgPicture.asset(
              asset,
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Color(0xFF000529),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
