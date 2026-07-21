import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/dagiga_constants.dart';

/// Sheet variant — main tool row uses tighter Figma padding.
enum DagigaBottomSheetVariant {
  /// Bottom tool pills (Text / Sticker / Logo …).
  mainTools,

  /// Paint / crop / filter sub-bars.
  subEditor,
}

/// Rounded top sheet used for the main tool options bar.
///
/// Matches Figma node `6352:12644`: frosted navy glass with 14px top radius.
class DagigaBottomSheet extends StatelessWidget {
  /// Creates a [DagigaBottomSheet].
  const DagigaBottomSheet({
    super.key,
    required this.child,
    this.backgroundColor = kDagigaBottomSheetBackground,
    this.variant = DagigaBottomSheetVariant.subEditor,
  });

  /// Sheet content.
  final Widget child;

  /// Frosted overlay tint (semi-transparent navy).
  final Color backgroundColor;

  /// Layout preset.
  final DagigaBottomSheetVariant variant;

  @override
  Widget build(BuildContext context) {
    final isMain = variant == DagigaBottomSheetVariant.mainTools;
    // Figma `6352:12644` / `6352:12645`: pt 20, pb 40, px 20.
    final horizontal = isMain ? kDagigaMainSheetHorizontal : 20.0;
    final top = isMain ? kDagigaMainSheetTop : 20.0;
    final bottom = isMain ? kDagigaMainSheetBottom : 20.0;
    const radius = BorderRadius.vertical(
      top: Radius.circular(kDagigaBottomSheetRadius),
    );

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: Clip.hardEdge,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: kDagigaBottomSheetBlurSigma,
            sigmaY: kDagigaBottomSheetBlurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: radius,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
