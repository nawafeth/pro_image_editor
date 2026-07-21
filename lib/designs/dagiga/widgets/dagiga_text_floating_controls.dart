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

  @override
  Widget build(BuildContext context) {
    final isArabic = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(widget.editor.textCtrl.text);

    final alternateFill = _hasBackground
        ? widget.editor.secondaryColor
        : kDagigaAlternateStyleFill;

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 12, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingControl(
                label: widget.alignmentLabel,
                onTap: widget.editor.toggleTextAlign,
                trailing: DagigaIcons.alignBars(width: 32, height: 25),
              ),
              const SizedBox(height: 12),
              _FloatingControl(
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
                    isArabic ? 'أبج' : 'Aa',
                    style: widget.editor.selectedTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: isArabic ? 11 : 12,
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
  });

  final String label;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
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
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
