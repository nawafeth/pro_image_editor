import 'package:flutter/material.dart';

import '../constants/dagiga_constants.dart';
import 'dagiga_icons.dart';

/// Alignment, background, and border controls shared by the text editor and
/// selected-layer overlay.
class DagigaTextStyleControlsColumn extends StatelessWidget {
  /// Creates [DagigaTextStyleControlsColumn].
  const DagigaTextStyleControlsColumn({
    super.key,
    required this.isArabic,
    required this.alignmentLabel,
    required this.alternateStyleLabel,
    required this.borderStyleLabel,
    required this.onToggleAlign,
    required this.onAlternateStyle,
    required this.onBorderStyle,
    required this.textAlign,
    required this.hasBackground,
    required this.hasBorder,
    required this.backgroundPreviewColor,
    required this.borderPreviewColor,
    required this.previewTextStyle,
    required this.previewText,
  });

  /// Layout direction for labels and control order.
  final bool isArabic;

  /// Alignment control label.
  final String alignmentLabel;

  /// Background fill control label.
  final String alternateStyleLabel;

  /// Text border control label.
  final String borderStyleLabel;

  /// Cycles text alignment.
  final VoidCallback onToggleAlign;

  /// Current text alignment (updates the align icon).
  final TextAlign textAlign;

  /// Opens background color selection.
  final VoidCallback onAlternateStyle;

  /// Opens border color selection.
  final VoidCallback onBorderStyle;

  /// Whether a background fill is active.
  final bool hasBackground;

  /// Whether a text border is active.
  final bool hasBorder;

  /// Swatch preview for background fill.
  final Color backgroundPreviewColor;

  /// Swatch preview for text border stroke.
  final Color borderPreviewColor;

  /// Font style for the `Aa` / `أبج` previews.
  final TextStyle previewTextStyle;

  /// Localized preview glyph (`Aa` or `أبج`).
  final String previewText;

  @override
  Widget build(BuildContext context) {
    final isRtl = isArabic;
    final alternateFill =
        hasBackground ? backgroundPreviewColor : kDagigaAlternateStyleFill;
    final borderFill =
        hasBorder ? borderPreviewColor : kDagigaAlternateStyleFill;
    final previewFontSize = isArabic ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        DagigaTextStyleControl(
          isRtl: isRtl,
          label: alignmentLabel,
          onTap: onToggleAlign,
          trailing: DagigaIcons.textAlignIcon(
            align: textAlign,
            width: 32,
            height: 25,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        DagigaTextStyleControl(
          isRtl: isRtl,
          label: alternateStyleLabel,
          onTap: onAlternateStyle,
          trailing: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: alternateFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              previewText,
              style: previewTextStyle.copyWith(
                color: Colors.white,
                fontSize: previewFontSize,
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
        const SizedBox(height: 12),
        DagigaTextStyleControl(
          isRtl: isRtl,
          label: borderStyleLabel,
          onTap: onBorderStyle,
          trailing: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderFill,
                width: hasBorder ? 3 : 1.5,
              ),
            ),
            child: Text(
              previewText,
              style: previewTextStyle.copyWith(
                color: const Color(0xFF111111),
                fontSize: previewFontSize,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single floating label + trailing control row.
class DagigaTextStyleControl extends StatelessWidget {
  /// Creates [DagigaTextStyleControl].
  const DagigaTextStyleControl({
    super.key,
    required this.label,
    required this.onTap,
    required this.trailing,
    required this.isRtl,
  });

  /// Layout direction for label/trailing order.
  final bool isRtl;

  /// Control label.
  final String label;

  /// Tap handler.
  final VoidCallback onTap;

  /// Trailing widget (icon or swatch preview).
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
