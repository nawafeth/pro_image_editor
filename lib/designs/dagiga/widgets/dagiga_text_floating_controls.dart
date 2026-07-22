import 'package:flutter/material.dart';

import '/pro_image_editor.dart';
import '../constants/dagiga_constants.dart';
import 'dagiga_icons.dart';

/// Floating Alignment + Alternate Style controls for the text editor canvas.
class DagigaTextFloatingControls extends StatefulWidget {
  /// Creates [DagigaTextFloatingControls].
  const DagigaTextFloatingControls({
    super.key,
    required this.editor,
    required this.isArabic,
    this.onAlternateStyle,
    this.alignmentLabel = 'Alignment',
    this.alternateStyleLabel = 'Alternate Style',
  });


  /// Text editor state.
  final TextEditorState editor;

  /// Opens the background color strip (Figma Alternate Style).
  ///
  /// When null, falls back to [TextEditorState.toggleBackgroundMode].
  final VoidCallback? onAlternateStyle;

  /// Alignment control label.
  final String alignmentLabel;

  /// Alternate style control label.
  final String alternateStyleLabel;

  ///app language
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

  bool get _isArabicText => RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
      ).hasMatch(widget.editor.textCtrl.text);

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.isArabic;

    final alternateFill = _hasBackground
        ? widget.editor.secondaryColor
        : kDagigaAlternateStyleFill;

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
          child: Column(
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingControl(
                isRtl: isRtl,
                label: widget.alignmentLabel,
                onTap: widget.editor.toggleTextAlign,
                trailing: DagigaIcons.alignBars(width: 32, height: 25),
              ),
              const SizedBox(height: 12),
              _FloatingControl(
                isRtl: isRtl,
                label: widget.alternateStyleLabel,
                onTap: widget.onAlternateStyle ??
                    widget.editor.toggleBackgroundMode,
                trailing: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: alternateFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isArabicText ? 'أبج' : 'Aa',
                    style: widget.editor.selectedTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: _isArabicText ? 11 : 12,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingControl extends StatelessWidget {
  const _FloatingControl({
    required this.label,
    required this.onTap,
    required this.trailing,
    required this.isRtl,
  });

  final bool isRtl;
  final String label;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      this.label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1,
        shadows: [
          Shadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
    const gap = SizedBox(width: 8);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isRtl
                  ? [trailing, gap, label]
                  : [label, gap, trailing],
            ),
          ),
        ),
      ),
    );
  }
}
