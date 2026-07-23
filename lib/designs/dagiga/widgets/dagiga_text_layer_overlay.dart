import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '/core/models/layers/enums/layer_background_mode.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/main_editor.dart';
import '../constants/dagiga_constants.dart';
import 'bottombar/dagiga_text_bar.dart';
import 'dagiga_color_swatch_bar.dart';
import 'dagiga_icons.dart';

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
    this.alignmentTooltip = 'Alignment',
    this.textColorTooltip = 'Text Color',
    this.backgroundTooltip = 'Alternate Style',
    this.borderTooltip = 'Text Border',
    this.showColorPicker,
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

  /// Tooltip for the alignment menu action.
  final String alignmentTooltip;

  /// Tooltip for the text color menu action.
  final String textColorTooltip;

  /// Tooltip for the background fill menu action.
  final String backgroundTooltip;

  /// Tooltip for the text border menu action.
  final String borderTooltip;

  /// Optional extended color picker for the eyedropper control.
  final void Function(Color currentColor, ValueChanged<Color> apply)?
      showColorPicker;

  @override
  State<DagigaTextLayerOverlay> createState() => _DagigaTextLayerOverlayState();
}

class _DagigaTextLayerOverlayState extends State<DagigaTextLayerOverlay> {
  final _overlayCtrl = OverlayPortalController();
  final _layerKey = GlobalKey();
  final _stackKey = GlobalKey();
  final _menuKey = GlobalKey();

  DagigaTextBarColorTarget? _activeColorTarget;

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

  bool get _hideMenuWhileDragging =>
      _editor?.isLayerBeingTransformed ?? false;

  bool get _hasBackground =>
      _textLayer?.colorMode != LayerBackgroundMode.onlyColor;

  bool get _hasBorder => _textLayer?.borderColor != null;

  void _commitLayerChange() {
    final editor = _editor;
    if (editor == null) return;
    editor
      ..addHistory()
      ..setState(() {});
    setState(() {});
  }

  void _updateTextStyle(TextStyle Function(TextStyle base) transform) {
    final layer = _textLayer;
    if (layer == null) return;

    final base = layer.textStyle ?? const TextStyle();
    layer.textStyle = transform(base);
    _commitLayerChange();
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

  void _toggleTextAlign() {
    final layer = _textLayer;
    if (layer == null) return;

    TextAlign nextAlign(TextAlign current) {
      switch (current) {
        case TextAlign.left:
          return TextAlign.center;
        case TextAlign.center:
          return TextAlign.right;
        case TextAlign.right:
        default:
          return TextAlign.left;
      }
    }

    layer.align = nextAlign(layer.align);
    _commitLayerChange();
  }

  void _openTextColorPicker() {
    setState(() {
      _activeColorTarget = DagigaTextBarColorTarget.text;
    });
  }

  void _openBackgroundPicker() {
    setState(() {
      _activeColorTarget = DagigaTextBarColorTarget.background;
    });
  }

  void _openBorderPicker() {
    setState(() {
      _activeColorTarget = DagigaTextBarColorTarget.border;
    });
  }

  void _closeColorPicker() {
    setState(() => _activeColorTarget = null);
  }

  Color get _selectedSwatchColor {
    final layer = _textLayer!;
    switch (_activeColorTarget) {
      case DagigaTextBarColorTarget.background:
        if (!_hasBackground) return Colors.transparent;
        return layer.background;
      case DagigaTextBarColorTarget.border:
        return layer.borderColor ?? Colors.transparent;
      case DagigaTextBarColorTarget.text:
      case null:
        return layer.color;
    }
  }

  void _onSwatchSelected(Color color) {
    final layer = _textLayer;
    if (layer == null) return;

    switch (_activeColorTarget) {
      case DagigaTextBarColorTarget.text:
        layer.color = color;
      case DagigaTextBarColorTarget.background:
        if (color.a == 0) {
          layer
            ..colorMode = LayerBackgroundMode.onlyColor
            ..background = Colors.transparent;
        } else {
          layer
            ..colorMode = LayerBackgroundMode.backgroundAndColor
            ..background = color
            ..customSecondaryColor = true;
        }
      case DagigaTextBarColorTarget.border:
        layer.borderColor = color.a == 0 ? null : color;
      case null:
        break;
    }

    _commitLayerChange();
  }

  void _onEyedropper() {
    final picker = widget.showColorPicker;
    if (picker == null) return;

    var current = _selectedSwatchColor;
    if (_activeColorTarget == DagigaTextBarColorTarget.background &&
        current.a == 0) {
      current = Colors.white;
    } else if (_activeColorTarget == DagigaTextBarColorTarget.border &&
        current.a == 0) {
      current = Colors.white;
    }
    picker(current, _onSwatchSelected);
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

    final layer = _textLayer!;
    final transform = widget.info.childPaintTransform.clone();
    final width = widget.info.childSize.width;
    final height = widget.info.childSize.height;
    final bottomBarHeight = _editor?.sizesManager.bottomBarHeight ?? 0;

    return Stack(
      key: _stackKey,
      children: [
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
            if (_hideMenuWhileDragging) return const SizedBox.shrink();

            final menuOffset = _menuOffset();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (_activeColorTarget != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomBarHeight,
                    child: ColoredBox(
                      color: kDagigaStripBackground,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: DagigaColorSwatchBar(
                          selectedColor: _selectedSwatchColor,
                          swatches:
                              _activeColorTarget ==
                                      DagigaTextBarColorTarget.background
                                  ? kDagigaBackgroundSwatches
                                  : kDagigaDefaultSwatches,
                          onColorChanged: _onSwatchSelected,
                          onClose: _closeColorPicker,
                          onEyedropper: widget.showColorPicker == null
                              ? null
                              : _onEyedropper,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: menuOffset.dy,
                  left: menuOffset.dx,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1),
                    child: _TextStyleMenu(
                      key: _menuKey,
                      isBold: _isBold,
                      isItalic: _isItalic,
                      isUnderline: _isUnderline,
                      hasBackground: _hasBackground,
                      hasBorder: _hasBorder,
                      backgroundColor: _hasBackground
                          ? layer.background
                          : kDagigaAlternateStyleFill,
                      borderColor:
                          layer.borderColor ?? kDagigaAlternateStyleFill,
                      textAlign: layer.align,
                      onBold: _toggleBold,
                      onItalic: _toggleItalic,
                      onUnderline: _toggleUnderline,
                      textColor: layer.color,
                      onAlign: _toggleTextAlign,
                      onTextColor: _openTextColorPicker,
                      onBackground: _openBackgroundPicker,
                      onBorder: _openBorderPicker,
                      alignmentTooltip: widget.alignmentTooltip,
                      textColorTooltip: widget.textColorTooltip,
                      backgroundTooltip: widget.backgroundTooltip,
                      borderTooltip: widget.borderTooltip,
                      onDuplicate: widget.interactions.duplicated,
                      onDelete: widget.interactions.remove,
                    ),
                  ),
                ),
              ],
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
    required this.hasBackground,
    required this.hasBorder,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textAlign,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onAlign,
    required this.onTextColor,
    required this.onBackground,
    required this.onBorder,
    required this.alignmentTooltip,
    required this.textColorTooltip,
    required this.backgroundTooltip,
    required this.borderTooltip,
    required this.onDuplicate,
    required this.onDelete,
  });

  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool hasBackground;
  final bool hasBorder;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final TextAlign textAlign;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onAlign;
  final VoidCallback onTextColor;
  final VoidCallback onBackground;
  final VoidCallback onBorder;
  final String alignmentTooltip;
  final String textColorTooltip;
  final String backgroundTooltip;
  final String borderTooltip;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuIconButton(
                asset: kDagigaMenuBoldAsset,
                selected: isBold,
                tooltip: 'Bold',
                onTap: onBold,
              ),
              const SizedBox(width: 10),
              _MenuIconButton(
                asset: kDagigaMenuItalicAsset,
                selected: isItalic,
                tooltip: 'Italic',
                onTap: onItalic,
              ),
              const SizedBox(width: 10),
              _MenuIconButton(
                asset: kDagigaMenuUnderlineAsset,
                selected: isUnderline,
                tooltip: 'Underline',
                onTap: onUnderline,
              ),
              const SizedBox(width: 10),
              const _MenuSeparator(),
              const SizedBox(width: 10),
              _MenuAlignButton(
                align: textAlign,
                tooltip: alignmentTooltip,
                onTap: onAlign,
              ),
              const SizedBox(width: 10),
              _MenuTextColorButton(
                tooltip: textColorTooltip,
                color: textColor,
                onTap: onTextColor,
              ),
              const SizedBox(width: 10),
              _MenuFillButton(
                tooltip: backgroundTooltip,
                color: backgroundColor,
                active: hasBackground,
                onTap: onBackground,
              ),
              const SizedBox(width: 10),
              _MenuBorderButton(
                tooltip: borderTooltip,
                color: borderColor,
                active: hasBorder,
                onTap: onBorder,
              ),
              const SizedBox(width: 10),
              const _MenuSeparator(),
              const SizedBox(width: 10),
              _MenuIconButton(
                asset: kDagigaMenuDuplicateAsset,
                tooltip: 'Duplicate',
                onTap: onDuplicate,
              ),
              const SizedBox(width: 10),
              const _MenuSeparator(),
              const SizedBox(width: 10),
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

class _MenuAlignButton extends StatelessWidget {
  const _MenuAlignButton({
    required this.onTap,
    required this.tooltip,
    required this.align,
  });

  final VoidCallback onTap;
  final String tooltip;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: DagigaIcons.textAlignIcon(align: align),
        ),
      ),
    );
  }
}

class _MenuTextColorButton extends StatelessWidget {
  const _MenuTextColorButton({
    required this.onTap,
    required this.tooltip,
    required this.color,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x80000529),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuFillButton extends StatelessWidget {
  const _MenuFillButton({
    required this.onTap,
    required this.tooltip,
    required this.color,
    required this.active,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: active ? color : kDagigaAlternateStyleFill,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: const Color(0x80000529),
                width: active ? 0 : 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuBorderButton extends StatelessWidget {
  const _MenuBorderButton({
    required this.onTap,
    required this.tooltip,
    required this.color,
    required this.active,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: active ? color : kDagigaAlternateStyleFill,
                width: active ? 2 : 1,
              ),
            ),
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
        padding: const EdgeInsets.all(3),
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
