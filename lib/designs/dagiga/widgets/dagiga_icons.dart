import 'package:flutter/material.dart';

/// Stroke icons matching Dagiga Figma SVGs (no flutter_svg dependency).
abstract final class DagigaIcons {
  /// Back chevron (Figma arrow flipped for leading navigation).
  static Widget chevronBack({
    double width = 32,
    double height = 32,
    Color color = Colors.white,
    required bool isArabic,
  }) {
    return Transform.flip(
      flipX: !isArabic,
      child: CustomPaint(
        size: Size(width, height),
        painter: _StrokePathPainter(
          color: color,
          strokeWidth: 1.2,
          viewBox: const Size(11, 7),
          paths: const [
            'M9.02875 3.81063H0.96875',
            'M7.6875 6.1543L10.0312 3.81055L7.6875 1.4668',
          ],
        ),
      ),
    );
  }

  /// Close X used on the color strip (9×9 viewBox).
  static Widget close({double size = 9, Color color = Colors.white}) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StrokePathPainter(
        color: color,
        strokeWidth: 1.2,
        viewBox: const Size(9, 9),
        paths: const ['M0.5 8.5L8.5 0.5', 'M8.5 8.5L0.5 0.5'],
      ),
    );
  }

  /// Eyedropper glyph from Figma color strip.
  static Widget eyedropper({double size = 14, Color color = Colors.white}) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StrokePathPainter(
        color: color,
        strokeWidth: 1,
        viewBox: const Size(13.9, 13.9),
        paths: const [_kEyedropperOutline, 'M4.46912 1.49414L12.4059 9.43088'],
      ),
    );
  }

  /// Alignment bars (32×25) from Figma floating controls.
  static Widget alignBars({
    double width = 32,
    double height = 25,
    Color color = Colors.white,
  }) {
    return CustomPaint(
      size: Size(width, height),
      painter: _StrokePathPainter(
        color: color,
        strokeWidth: 2.2,
        viewBox: const Size(32, 25),
        paths: const [
          'M7.38461 5H27.0769',
          'M2.46154 12.5H27.0769',
          'M9.84616 20H24.6154',
        ],
      ),
    );
  }
}

/// Eyedropper outline path from Figma (kept as one string for the parser).
// ignore: lines_longer_than_80_chars
const _kEyedropperOutline =
    'M12.3663 1.53378C12.0416 1.20623 11.6553 0.946223 11.2296 0.768788C10.8039 0.591354 10.3472 0.5 9.88599 0.5C9.42479 0.5 8.96816 0.591354 8.54246 0.768788C8.11676 0.946223 7.73042 1.20623 7.40575 1.53378L2.85205 6.08748C2.40087 6.53793 2.10627 7.12134 2.01161 7.75181C1.91695 8.38229 2.02724 9.0265 2.32624 9.58958L0.788493 11.1273C0.603715 11.3132 0.5 11.5647 0.5 11.8268C0.5 12.0888 0.603715 12.3403 0.788493 12.5262L1.37383 13.1115C1.55971 13.2963 1.81116 13.4 2.07325 13.4C2.33535 13.4 2.5868 13.2963 2.77268 13.1115L4.31042 11.5738C4.8735 11.8728 5.51771 11.9831 6.14818 11.8884C6.77865 11.7937 7.36207 11.4991 7.81251 11.048L12.3663 6.49425C12.6938 6.16958 12.9538 5.78323 13.1313 5.35753C13.3087 4.93183 13.4 4.4752 13.4 4.01401C13.4 3.55281 13.3087 3.09619 13.1313 2.67049C12.9538 2.24479 12.6938 1.85845 12.3663 1.53378Z';

class _StrokePathPainter extends CustomPainter {
  const _StrokePathPainter({
    required this.color,
    required this.strokeWidth,
    required this.viewBox,
    required this.paths,
  });

  final Color color;
  final double strokeWidth;
  final Size viewBox;
  final List<String> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final sx = size.width / viewBox.width;
    final sy = size.height / viewBox.height;
    canvas
      ..save()
      ..scale(sx, sy);
    for (final raw in paths) {
      canvas.drawPath(_parseSvgPath(raw), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StrokePathPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.paths != paths;
  }
}

/// Minimal SVG path parser for absolute M/L/H/C/Z commands used above.
Path _parseSvgPath(String data) {
  final path = Path();
  final tokens = RegExp(
    r'[MmLlHhVvCcZz]|-?\d*\.?\d+(?:e[-+]?\d+)?',
  ).allMatches(data).map((m) => m.group(0)!).toList();

  var i = 0;
  var cx = 0.0;
  var cy = 0.0;

  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    final cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        cx = next();
        cy = next();
        path.moveTo(cx, cy);
        while (i < tokens.length && _isNumber(tokens[i])) {
          cx = next();
          cy = next();
          path.lineTo(cx, cy);
        }
      case 'L':
        while (i < tokens.length && _isNumber(tokens[i])) {
          cx = next();
          cy = next();
          path.lineTo(cx, cy);
        }
      case 'H':
        while (i < tokens.length && _isNumber(tokens[i])) {
          cx = next();
          path.lineTo(cx, cy);
        }
      case 'V':
        while (i < tokens.length && _isNumber(tokens[i])) {
          cy = next();
          path.lineTo(cx, cy);
        }
      case 'C':
        while (i < tokens.length && _isNumber(tokens[i])) {
          final x1 = next();
          final y1 = next();
          final x2 = next();
          final y2 = next();
          cx = next();
          cy = next();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
        }
      case 'Z':
      case 'z':
        path.close();
      default:
        // Relative / unsupported commands are not used by Dagiga icons.
        break;
    }
  }
  return path;
}

bool _isNumber(String token) =>
    token.isNotEmpty &&
    (token.codeUnitAt(0) == 45 /* - */ ||
        token.codeUnitAt(0) == 46 /* . */ ||
        (token.codeUnitAt(0) >= 48 && token.codeUnitAt(0) <= 57));
