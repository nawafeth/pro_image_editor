import 'package:flutter/material.dart';

import '../constants/dagiga_constants.dart';

/// A pill-shaped tool button with icon + label (Figma bottom options).
class DagigaToolChip extends StatelessWidget {
  /// Creates a [DagigaToolChip].
  const DagigaToolChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.leading,
    this.isSelected = false,
    this.foregroundColor = Colors.white,
    this.expanded = false,
    this.minWidth = kDagigaToolChipMinWidth,
  });

  /// Chip label.
  final String label;

  /// Fallback [IconData] when [leading] is null.
  final IconData icon;

  /// Optional custom leading icon (Figma SVG).
  final Widget? leading;

  /// Tap callback.
  final VoidCallback onPressed;

  /// Whether this chip is selected.
  final bool isSelected;

  /// Icon and label color.
  final Color foregroundColor;

  /// When true, chip expands to fill available row space (Figma equal pills).
  final bool expanded;

  /// Minimum width when not expanded (scroll row).
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(kDagigaToolChipRadius),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: kDagigaToolChipPaddingH,
            vertical: kDagigaToolChipPaddingV,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? kDagigaAccent.withValues(alpha: 0.15)
                : kDagigaChipBackground,
            borderRadius: BorderRadius.circular(kDagigaToolChipRadius),
            border: isSelected
                ? Border.all(color: kDagigaAccent.withValues(alpha: 0.5))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: kDagigaToolIconSize,
                height: kDagigaToolIconSize,
                child: leading ??
                    Icon(
                      icon,
                      size: kDagigaToolIconSize,
                      color: foregroundColor,
                    ),
              ),
              const SizedBox(height: kDagigaToolChipIconGap),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  color: foregroundColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expanded) return Expanded(child: chip);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: chip,
    );
  }
}
