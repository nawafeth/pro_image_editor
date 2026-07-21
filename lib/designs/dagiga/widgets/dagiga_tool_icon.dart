import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/pro_image_editor.dart';
import '../constants/dagiga_constants.dart';

/// Figma tool glyphs for the main bottom bar (SVG when available).
abstract final class DagigaToolIcon {
  /// Builds the icon for a [SubEditorMode], falling back to [fallback].
  static Widget build({
    required SubEditorMode mode,
    required IconData fallback,
    double size = kDagigaToolIconSize,
    Color color = Colors.white,
  }) {
    final asset = _assetForMode(mode);
    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Icon(fallback, size: size, color: color);
  }

  static String? _assetForMode(SubEditorMode mode) {
    return switch (mode) {
      SubEditorMode.text => kDagigaToolTextIconAsset,
      SubEditorMode.sticker => kDagigaToolStickerIconAsset,
      SubEditorMode.paint => kDagigaToolPenIconAsset,
      _ => null,
    };
  }
}
