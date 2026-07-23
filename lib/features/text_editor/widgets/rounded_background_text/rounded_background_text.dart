import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/rounded_background_painter.dart';

/// Creates a [RoundedBackgroundText] widget with plain text and optional
/// styling.
///
/// The [text] parameter is a simple `String` which will be wrapped in a
/// [TextSpan].
class RoundedBackgroundText extends StatelessWidget {
  /// Creates a [RoundedBackgroundText] widget from a plain [String] with
  /// optional styling.
  ///
  /// This constructor converts the [text] into a [TextSpan] using the
  /// provided [style].
  ///
  /// Use this constructor when you don't need rich text formatting.
  RoundedBackgroundText(
    String text, {
    super.key,
    TextStyle? style,
    this.textAlign,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
  }) : text = TextSpan(text: text, style: style);

  /// Creates a [RoundedBackgroundText] widget with rich text using
  /// [InlineSpan].
  ///
  /// Use this constructor when you want to provide styled or nested spans via
  /// the [text] parameter.
  const RoundedBackgroundText.rich({
    super.key,
    required this.text,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.textAlign,
    this.onHitTestResult,
    required this.maxTextWidth,
    this.cursorWidth = 0,
    this.enableHitBoxCorrection = false,
    this.leadingDistribution = TextLeadingDistribution.proportional,
  });

  /// A flag to enable or disable hitBox correction for the text.
  final bool enableHitBoxCorrection;

  /// The text content to be displayed, supporting rich formatting through
  /// [InlineSpan].
  final InlineSpan text;

  /// How the text should be aligned horizontally within its container.
  final TextAlign? textAlign;

  /// The optional background color behind the text.
  final Color? backgroundColor;

  /// Optional stroke color around text glyphs via [BorderedText].
  final Color? borderColor;

  /// Stroke width when [borderColor] is set.
  final double borderWidth;

  /// The maximum width the text is allowed to occupy. If null, the text can
  /// expand freely.
  final double maxTextWidth;

  /// The width of the text cursor when displayed.
  final double cursorWidth;

  /// Controls how extra leading is distributed above and below the text.
  ///
  /// Defaults to [TextLeadingDistribution.proportional].
  /// Set to [TextLeadingDistribution.even] to visually centre glyphs inside
  /// their rounded background rects when [TextStyle.height] > 1.0.
  final TextLeadingDistribution leadingDistribution;

  /// Callback function triggered with the result of a hit test.
  final Function(bool hasHit)? onHitTestResult;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;
    final align = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;

    final painter = TextPainter(
      text: TextSpan(
        children: [text],
        style: TextStyle(leadingDistribution: leadingDistribution).merge(style),
      ),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      maxLines: defaultTextStyle.maxLines,
      textAlign: align,
      textWidthBasis: defaultTextStyle.textWidthBasis,
      textHeightBehavior: defaultTextStyle.textHeightBehavior,
    );
    double height = painter.preferredLineHeight;

    double horizontalSpace = enableHitBoxCorrection ? height * 0.3 : 0;
    double verticalSpace = enableHitBoxCorrection ? height * 0.1 : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        painter.layout(maxWidth: maxTextWidth);

        final size = Size(
          painter.width.clamp(0, constraints.maxWidth) + horizontalSpace * 2,
          painter.height.clamp(0, constraints.maxHeight) + verticalSpace * 2,
        );

        final useBorderedText =
            borderColor != null && painter.plainText.isNotEmpty;

        return CustomPaint(
          isComplex: true,
          painter: RoundedBackgroundTextPainter(
            backgroundColor: backgroundColor ?? Colors.transparent,
            painter: painter,
            onHitTestResult: onHitTestResult,
            textAlign: align,
            cursorWidth: cursorWidth,
            textDirection: Directionality.of(context),
            hitBoxCorrectionOffset: Offset(horizontalSpace, verticalSpace),
            paintText: !useBorderedText,
          ),
          child: useBorderedText
              ? IgnorePointer(
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: horizontalSpace,
                        top: verticalSpace,
                      ),
                      child: _BorderedTextOverlay(
                        text: painter.plainText,
                        style:
                            TextStyle(leadingDistribution: leadingDistribution)
                                .merge(style),
                        textAlign: align,
                        borderColor: borderColor!,
                        borderWidth: borderWidth,
                        maxWidth: maxTextWidth,
                      ),
                    ),
                  ),
                )
              : null,
          size: size,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<InlineSpan>('text', text))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null))
      ..add(
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(ColorProperty('borderColor', borderColor, defaultValue: null))
      ..add(DoubleProperty('borderWidth', borderWidth, defaultValue: 2.0))
      ..add(DoubleProperty('maxTextWidth', maxTextWidth))
      ..add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 0))
      ..add(
        FlagProperty(
          'enableHitBoxCorrection',
          value: enableHitBoxCorrection,
          ifTrue: 'hitBoxCorrection enabled',
        ),
      )
      ..add(
        FlagProperty(
          'hasOnHitTestResult',
          value: onHitTestResult != null,
          ifTrue: 'callback set',
        ),
      )
      ..add(
        EnumProperty<TextLeadingDistribution>(
          'leadingDistribution',
          leadingDistribution,
          defaultValue: TextLeadingDistribution.proportional,
        ),
      );
  }
}

class _BorderedTextOverlay extends StatelessWidget {
  const _BorderedTextOverlay({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.borderColor,
    required this.borderWidth,
    required this.maxWidth,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Color borderColor;
  final double borderWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return BorderedText(
      strokeWidth: borderWidth,
      strokeColor: borderColor,
      child: Text(
        text,
        style: style.copyWith(decoration: TextDecoration.none),
        textAlign: textAlign,
        maxLines: null,
      ),
    );
  }
}
