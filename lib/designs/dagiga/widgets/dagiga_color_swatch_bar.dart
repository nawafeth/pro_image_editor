import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/dagiga_constants.dart';

/// Horizontal color strip: close, eyedropper, and swatches.
///
/// Matches Figma `6347:10414` — 32px circles, gap 16, px 20 / py 8 on parent.
class DagigaColorSwatchBar extends StatelessWidget {
  /// Creates a [DagigaColorSwatchBar].
  const DagigaColorSwatchBar({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onClose,
    this.onEyedropper,
    this.swatches = kDagigaDefaultSwatches,
  });

  /// Currently selected color.
  final Color selectedColor;

  /// Called when a swatch is tapped.
  final ValueChanged<Color> onColorChanged;

  /// Called when the close (X) control is tapped.
  final VoidCallback onClose;

  /// Optional eyedropper action (opens extended picker when pixel pick is
  /// unavailable).
  final VoidCallback? onEyedropper;

  /// Colors to display.
  final List<Color> swatches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kDagigaControlSize,
      child: Row(
        children: [
          _CircleIconButton(
            onPressed: onClose,
            child: SvgPicture.asset(
              kDagigaColorCloseAsset,
              package: kDagigaAssetsPackage,
              width: kDagigaColorCloseIconSize,
              height: kDagigaColorCloseIconSize,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: kDagigaColorStripGap),
          _CircleIconButton(
            onPressed: onEyedropper,
            child: SvgPicture.asset(
              kDagigaColorEyedropperAsset,
              package: kDagigaAssetsPackage,
              width: kDagigaColorEyedropperIconSize,
              height: kDagigaColorEyedropperIconSize,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: kDagigaColorStripGap),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < swatches.length; i++) ...[
                    if (i > 0) const SizedBox(width: kDagigaColorStripGap),
                    _SwatchDot(
                      color: swatches[i],
                      isSelected: _colorsEqual(swatches[i], selectedColor),
                      onTap: () => onColorChanged(swatches[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _colorsEqual(Color a, Color b) {
    if (a.a == 0 && b.a == 0) return true;
    return a.toARGB32() == b.toARGB32();
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.child,
    this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kDagigaCircleControlFill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: kDagigaControlSize,
          height: kDagigaControlSize,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  bool get _isTransparent => color.a == 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: kDagigaControlSize,
        height: kDagigaControlSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isTransparent ? Colors.transparent : color,
            // Figma selected: `border-3 border-[#000529]` (insets the fill).
            border: isSelected
                ? Border.all(
                    color: kDagigaSwatchSelectedBorder,
                    width: kDagigaSwatchSelectedBorderWidth,
                  )
                : null,
          ),
          child: _isTransparent
              ? const ClipOval(
                  child: CustomPaint(painter: _CheckerboardPainter()),
                )
              : null,
        ),
      ),
    );
  }
}

/// Small checkerboard used for the transparent swatch.
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 6.0;
    final light = Paint()..color = const Color(0xFFE8E8E8);
    final dark = Paint()..color = const Color(0xFFB0B0B0);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          isDark ? dark : light,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerboardPainter oldDelegate) => false;
}
