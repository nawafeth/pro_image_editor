import 'package:flutter/material.dart';

import '../constants/dagiga_constants.dart';

/// Tappable rainbow color ring that opens a Dagiga color swatch strip.
class DagigaColorRingButton extends StatelessWidget {
  /// Creates a [DagigaColorRingButton].
  const DagigaColorRingButton({
    super.key,
    required this.onPressed,
    this.size = kDagigaControlSize,
    this.assetPath,
    this.package,
  });

  /// Called when the ring is tapped.
  final VoidCallback onPressed;

  /// Diameter of the control (Figma 32).
  final double size;

  /// Asset path. Defaults to [kDagigaColorRingAsset] in [kDagigaAssetsPackage].
  final String? assetPath;

  /// Package that owns [assetPath]. Omit for host-app assets.
  final String? package;

  @override
  Widget build(BuildContext context) {
    final path = assetPath ?? kDagigaColorRingAsset;
    final resolvedPackage =
        package ?? (assetPath == null ? kDagigaAssetsPackage : null);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: Image.asset(
              path,
              package: resolvedPackage,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, _) => _FallbackRing(size: size),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackRing extends StatelessWidget {
  const _FallbackRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFFEB3B),
            Color(0xFF43A047),
            Color(0xFF1E88E5),
            Color(0xFF8E24AA),
            Color(0xFFE53935),
          ],
        ),
      ),
    );
  }
}
