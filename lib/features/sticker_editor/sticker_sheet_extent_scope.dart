import 'package:flutter/material.dart';

/// Provides [DraggableScrollableSheet] extent to sticker picker content.
class StickerSheetExtentScope extends InheritedWidget {
  /// Creates a [StickerSheetExtentScope].
  const StickerSheetExtentScope({
    super.key,
    required this.extent,
    required this.collapsedSize,
    required this.expandedSize,
    required this.maxSize,
    required this.sheetController,
    required super.child,
  });

  /// Current sheet size as a fraction of the parent (0–1).
  final double extent;

  /// Snap size for the collapsed (one-row) state.
  final double collapsedSize;

  /// Snap size for the expanded browse state (Figma ~409/874).
  final double expandedSize;

  /// Maximum draggable sheet size (can exceed [expandedSize]).
  final double maxSize;

  /// Controller used to animate expand / collapse.
  final DraggableScrollableController sheetController;

  /// Whether the sheet is at (or near) the collapsed snap.
  bool get isCollapsed => extent <= collapsedSize + 0.04;

  /// Looks up the nearest [StickerSheetExtentScope].
  static StickerSheetExtentScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StickerSheetExtentScope>();
  }

  @override
  bool updateShouldNotify(StickerSheetExtentScope oldWidget) {
    return extent != oldWidget.extent ||
        collapsedSize != oldWidget.collapsedSize ||
        expandedSize != oldWidget.expandedSize ||
        maxSize != oldWidget.maxSize;
  }
}
