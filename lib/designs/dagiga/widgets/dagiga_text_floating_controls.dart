import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '../constants/dagiga_constants.dart';
import 'bottombar/dagiga_text_bar.dart';
import 'dagiga_text_style_controls.dart';

/// Floating Alignment + Alternate Style controls for the text editor canvas.
class DagigaTextFloatingControls extends StatefulWidget {
  /// Creates [DagigaTextFloatingControls].
  const DagigaTextFloatingControls({
    super.key,
    required this.editor,
    required this.isArabic,
    this.onAlternateStyle,
    this.onBorderStyle,
    this.alignmentLabel = 'Alignment',
    this.alternateStyleLabel = 'Alternate Style',
    this.borderStyleLabel = 'Text Border',
  });

  /// Text editor state.
  final TextEditorState editor;

  /// Opens the background color strip (Figma Alternate Style).
  ///
  /// When null, falls back to [TextEditorState.toggleBackgroundMode].
  final VoidCallback? onAlternateStyle;

  /// Opens the text border color strip.
  final VoidCallback? onBorderStyle;

  /// Alignment control label.
  final String alignmentLabel;

  /// Alternate style control label.
  final String alternateStyleLabel;

  /// Text border control label.
  final String borderStyleLabel;

  /// App language direction.
  final bool isArabic;

  @override
  State<DagigaTextFloatingControls> createState() =>
      _DagigaTextFloatingControlsState();
}

class _DagigaTextFloatingControlsState
    extends State<DagigaTextFloatingControls> {
  @override
  void initState() {
    super.initState();
    widget.editor.textCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.editor.textCtrl.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasBackground =>
      widget.editor.backgroundColorMode != LayerBackgroundMode.onlyColor;

  bool get _hasBorder => widget.editor.borderColor != null;

  bool get _isArabicText =>
      dagigaTextContainsArabic(widget.editor.textCtrl.text);

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.isArabic;

    return SafeArea(
      child: Align(
        alignment: isRtl
            ? AlignmentDirectional.topStart
            : AlignmentDirectional.topEnd,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: kToolbarHeight + 12,
            start: isRtl ? 16 : 0,
            end: isRtl ? 0 : 16,
          ),
          child: DagigaTextStyleControlsColumn(
            isArabic: isRtl,
            alignmentLabel: widget.alignmentLabel,
            alternateStyleLabel: widget.alternateStyleLabel,
            borderStyleLabel: widget.borderStyleLabel,
            onToggleAlign: widget.editor.toggleTextAlign,
            textAlign: widget.editor.align,
            onAlternateStyle: widget.onAlternateStyle ??
                widget.editor.toggleBackgroundMode,
            onBorderStyle: widget.onBorderStyle ?? () {},
            hasBackground: _hasBackground,
            hasBorder: _hasBorder,
            backgroundPreviewColor: widget.editor.secondaryColor,
            borderPreviewColor:
                widget.editor.borderColor ?? kDagigaAlternateStyleFill,
            previewTextStyle: widget.editor.selectedTextStyle,
            previewText: _isArabicText ? 'أبج' : 'Aa',
          ),
        ),
      ),
    );
  }
}
