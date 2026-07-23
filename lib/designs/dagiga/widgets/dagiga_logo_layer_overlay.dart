import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/main_editor.dart';
import '../constants/dagiga_constants.dart';

/// Floating selection chrome for logo layers (Figma `6266:2020`).
///
/// Shows a Replace / Duplicate / Delete toolbar above the logo, a lime
/// selection border with corner + side handles, and a rotate control below.
class DagigaLogoLayerOverlay extends StatefulWidget {
  /// Creates a [DagigaLogoLayerOverlay].
  const DagigaLogoLayerOverlay({
    super.key,
    required this.info,
    required this.layer,
    required this.interactions,
    required this.editorKey,
    this.safeArea = EdgeInsets.zero,
    this.replaceTooltip = 'Replace',
    this.duplicateTooltip = 'Duplicate',
    this.deleteTooltip = 'Delete',
    this.onReplace,
  });

  /// Layout info from the editor overlay.
  final OverlayChildLayoutInfo info;

  /// Selected layer.
  final Layer layer;

  /// Built-in interaction callbacks.
  final LayerItemInteractions interactions;

  /// Editor state key.
  final GlobalKey<ProImageEditorState> editorKey;

  /// Safe-area insets used when clamping the menu position.
  final EdgeInsets safeArea;

  /// Tooltip for replace.
  final String replaceTooltip;

  /// Tooltip for duplicate.
  final String duplicateTooltip;

  /// Tooltip for delete.
  final String deleteTooltip;

  /// Opens the logo library to swap this layer's source.
  final VoidCallback? onReplace;

  @override
  State<DagigaLogoLayerOverlay> createState() => _DagigaLogoLayerOverlayState();
}

class _DagigaLogoLayerOverlayState extends State<DagigaLogoLayerOverlay> {
  final _overlayCtrl = OverlayPortalController();
  final _layerKey = GlobalKey();
  final _stackKey = GlobalKey();
  final _menuKey = GlobalKey();

  static const double _cornerHandle = 9.0;
  static const double _sideHandleWidth = 6.0;
  static const double _rotateSize = 32.0;

  ProImageEditorState? get _editor => widget.editorKey.currentState;

  bool get _hideMenuWhileDragging =>
      _editor?.isLayerBeingTransformed ?? false;

  bool get _isLogoLayer {
    final meta = widget.layer.meta;
    return widget.layer.isWidgetLayer && meta?['kind'] == 'logo';
  }

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

  Offset _rotateOffset() {
    final layerBox = _layerKey.currentContext?.findRenderObject();
    final parentBox = _stackKey.currentContext?.findRenderObject();

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
    final maxY = ys.reduce(max);
    final centerX = (minX + maxX) / 2;

    final dx = centerX.clamp(
      _rotateSize / 2 + widget.safeArea.left,
      parentSize.width - _rotateSize / 2 - widget.safeArea.right,
    );
    final dy = (maxY + 12).clamp(
      widget.safeArea.top,
      parentSize.height - _rotateSize - widget.safeArea.bottom,
    );

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLogoLayer) {
      return const SizedBox.shrink();
    }

    final transform = widget.info.childPaintTransform.clone();
    final width = widget.info.childSize.width;
    final height = widget.info.childSize.height;

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
              child: Stack(
                key: _layerKey,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kDagigaSelectionBorder,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // Corner handles
                  const Positioned(
                    top: -_cornerHandle / 2,
                    left: -_cornerHandle / 2,
                    child: _CornerHandle(),
                  ),
                  const Positioned(
                    top: -_cornerHandle / 2,
                    right: -_cornerHandle / 2,
                    child: _CornerHandle(),
                  ),
                  const Positioned(
                    bottom: -_cornerHandle / 2,
                    left: -_cornerHandle / 2,
                    child: _CornerHandle(),
                  ),
                  const Positioned(
                    bottom: -_cornerHandle / 2,
                    right: -_cornerHandle / 2,
                    child: _CornerHandle(),
                  ),
                  // Side handles
                  const Positioned(
                    left: -_sideHandleWidth / 2,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _SideHandle()),
                  ),
                  const Positioned(
                    right: -_sideHandleWidth / 2,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _SideHandle()),
                  ),
                ],
              ),
            ),
          ),
        ),
        OverlayPortal(
          controller: _overlayCtrl,
          overlayChildBuilder: (context) {
            if (_hideMenuWhileDragging) return const SizedBox.shrink();

            final menuOffset = _menuOffset();
            final rotateOffset = _rotateOffset();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: menuOffset.dy,
                  left: menuOffset.dx,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1),
                    child: _LogoActionMenu(
                      key: _menuKey,
                      replaceTooltip: widget.replaceTooltip,
                      duplicateTooltip: widget.duplicateTooltip,
                      deleteTooltip: widget.deleteTooltip,
                      onReplace: widget.onReplace ?? () {},
                      onDuplicate: widget.interactions.duplicated,
                      onDelete: widget.interactions.remove,
                    ),
                  ),
                ),
                Positioned(
                  top: rotateOffset.dy,
                  left: rotateOffset.dx,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: Listener(
                      onPointerDown: widget.interactions.scaleRotateDown,
                      onPointerUp: widget.interactions.scaleRotateUp,
                      child: Material(
                        color: kDagigaSelectionBorder,
                        shape: const CircleBorder(),
                        child: SizedBox(
                          width: _rotateSize,
                          height: _rotateSize,
                          child: Center(
                            child: SvgPicture.asset(
                              kDagigaLogoRotateAsset,
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
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

class _CornerHandle extends StatelessWidget {
  const _CornerHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: kDagigaSelectionBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SideHandle extends StatelessWidget {
  const _SideHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDagigaAccent),
      ),
    );
  }
}

class _LogoActionMenu extends StatelessWidget {
  const _LogoActionMenu({
    super.key,
    required this.replaceTooltip,
    required this.duplicateTooltip,
    required this.deleteTooltip,
    required this.onReplace,
    required this.onDuplicate,
    required this.onDelete,
  });

  final String replaceTooltip;
  final String duplicateTooltip;
  final String deleteTooltip;
  final VoidCallback onReplace;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuIconButton(
                asset: kDagigaMenuReplaceAsset,
                tooltip: replaceTooltip,
                onTap: onReplace,
              ),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuDuplicateAsset,
                tooltip: duplicateTooltip,
                onTap: onDuplicate,
              ),
              const SizedBox(width: 16),
              Container(
                width: 0.5,
                height: 16,
                color: const Color(0x80000529),
              ),
              const SizedBox(width: 16),
              _MenuIconButton(
                asset: kDagigaMenuDeleteAsset,
                tooltip: deleteTooltip,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuIconButton extends StatelessWidget {
  const _MenuIconButton({
    required this.asset,
    required this.onTap,
    required this.tooltip,
  });

  final String asset;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 16,
          height: 16,
          child: SvgPicture.asset(
            asset,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Color(0xFF000529),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
