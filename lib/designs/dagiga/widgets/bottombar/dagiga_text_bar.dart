import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/pro_image_editor.dart';
import '../../dagiga_design.dart';

/// Text editor bottom chrome for Dagiga: fonts by default, colors on demand.
class DagigaTextBar extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [DagigaTextBar].
  const DagigaTextBar({
    super.key,
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.showColorPicker,
    this.arabicTextStyles,
    this.initialMode = DagigaTextBarMode.styles,
  });

  /// Text editor state.
  final TextEditorState editor;

  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Opens an extended color picker (eyedropper fallback).
  ///
  /// [apply] must set the active target (text or background).
  final void Function(Color currentColor, ValueChanged<Color> apply)
      showColorPicker;

  /// Fonts shown when the input contains Arabic script.
  ///
  /// Falls back to [TextEditorConfigs.customTextStyles] when null.
  final List<TextStyle>? arabicTextStyles;

  /// Initial strip mode (defaults to fonts).
  final DagigaTextBarMode initialMode;

  @override
  State<DagigaTextBar> createState() => DagigaTextBarState();
}

/// Modes for the text bottom strip.
enum DagigaTextBarMode {
  /// Color swatches.
  colors,

  /// Font / style chips.
  styles,
}

/// Which color the swatch strip is editing.
enum DagigaTextBarColorTarget {
  /// Text / foreground color ([TextEditorState.primaryColor]).
  text,

  /// Text background fill ([TextEditorState.secondaryColor]).
  background,
}

/// Returns true when [text] contains Arabic letters.
bool dagigaTextContainsArabic(String text) {
  return RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  ).hasMatch(text);
}

/// State for [DagigaTextBar].
class DagigaTextBarState extends State<DagigaTextBar>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late DagigaTextBarMode _mode;
  var _colorTarget = DagigaTextBarColorTarget.text;
  var _isArabic = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _isArabic = dagigaTextContainsArabic(widget.editor.textCtrl.text);
    widget.editor.textCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.editor.textCtrl.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final next = dagigaTextContainsArabic(widget.editor.textCtrl.text);
    if (next == _isArabic) return;
    setState(() => _isArabic = next);
    _ensureSelectedStyleMatchesScript();
  }

  List<TextStyle> get _activeStyles {
    if (_isArabic) {
      return widget.arabicTextStyles ??
          textEditorConfigs.customTextStyles ??
          const <TextStyle>[];
    }
    return textEditorConfigs.customTextStyles ?? const <TextStyle>[];
  }

  void _ensureSelectedStyleMatchesScript() {
    final styles = _activeStyles;
    if (styles.isEmpty) return;
    final selected = widget.editor.selectedTextStyle;
    final matched = styles.any((s) => s.hashCode == selected.hashCode);
    if (!matched) {
      widget.editor.setTextStyle(styles.first);
    }
  }

  /// Switch to color or style mode.
  void setMode(DagigaTextBarMode mode) {
    if (_mode == mode && mode == DagigaTextBarMode.styles) return;
    setState(() {
      _mode = mode;
      if (mode == DagigaTextBarMode.styles) {
        _colorTarget = DagigaTextBarColorTarget.text;
      }
    });
  }

  /// Opens the swatch strip for text (foreground) color.
  void openTextColorPicker() {
    setState(() {
      _colorTarget = DagigaTextBarColorTarget.text;
      _mode = DagigaTextBarMode.colors;
    });
  }

  /// Opens the swatch strip for text background color (Figma Alternate Style).
  void openBackgroundColorPicker() {
    setState(() {
      _colorTarget = DagigaTextBarColorTarget.background;
      _mode = DagigaTextBarMode.colors;
    });
  }

  Color get _selectedColor {
    if (_colorTarget == DagigaTextBarColorTarget.background) {
      if (widget.editor.backgroundColorMode == LayerBackgroundMode.onlyColor) {
        return Colors.transparent;
      }
      // Use the stored secondary only — never the auto-contrast fallback,
      // so text-color changes cannot appear as a selected background swatch.
      return widget.editor.secondaryColor;
    }
    return widget.editor.primaryColor;
  }

  void _onSwatchSelected(Color color) {
    if (_colorTarget == DagigaTextBarColorTarget.background) {
      if (color.a == 0) {
        // Transparent → remove background fill; keep text color untouched.
        widget.editor.backgroundColorMode = LayerBackgroundMode.onlyColor;
        widget.editor.setState(() {});
        setState(() {});
        return;
      }
      widget.editor.backgroundColorMode =
          LayerBackgroundMode.backgroundAndColor;
      widget.editor.secondaryColor = color;
      setState(() {});
      return;
    }
    // Text/font color only — never mutates background.
    widget.editor.primaryColor = color;
    setState(() {});
  }

  void _onEyedropper() {
    // Eyedropper is only meaningful for opaque colors.
    if (_colorTarget == DagigaTextBarColorTarget.background &&
        _selectedColor.a == 0) {
      widget.showColorPicker(Colors.white, _onSwatchSelected);
      return;
    }
    widget.showColorPicker(_selectedColor, _onSwatchSelected);
  }

  @override
  Widget build(BuildContext context) {
    final isBackground =
        _colorTarget == DagigaTextBarColorTarget.background;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ColoredBox(
        color: kDagigaStripBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: AnimatedSwitcher(
            duration: kDagigaFadeInDuration,
            child: _mode == DagigaTextBarMode.colors
                ? DagigaColorSwatchBar(
                    key: ValueKey('colors-$_colorTarget'),
                    selectedColor: _selectedColor,
                    swatches: isBackground
                        ? kDagigaBackgroundSwatches
                        : kDagigaDefaultSwatches,
                    onColorChanged: _onSwatchSelected,
                    onClose: () => setMode(DagigaTextBarMode.styles),
                    onEyedropper: _onEyedropper,
                  )
                : _buildFontStrip(),
          ),
        ),
      ),
    );
  }

  Widget _buildFontStrip() {
    final styles = _activeStyles;
    // Figma uses "Abc"; Arabic product copy uses أبج.
    final label = _isArabic ? 'أبج' : 'Abc';

    return SizedBox(
      key: ValueKey(_isArabic ? 'styles-ar' : 'styles-en'),
      height: kDagigaSubBarHeight,
      child: Row(
        children: [
          _ColorModeButton(onPressed: openTextColorPicker),
          const SizedBox(width: 16),
          Expanded(
            child: styles.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: openBackgroundColorPicker,
                      icon: Icon(
                        textEditorConfigs.icons.backgroundMode,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        i18n.textEditor.backgroundMode,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: styles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = styles[index];
                      final isSelected = widget.editor.selectedTextStyle
                              .hashCode ==
                          item.hashCode;
                      return Material(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => widget.editor.setTextStyle(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: item.copyWith(
                                  color: isSelected
                                      ? const Color(0xFF111111)
                                      : kDagigaFontChipForeground,
                                  fontSize: 16,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Circular color entry control that opens the color swatch strip.
class _ColorModeButton extends StatelessWidget {
  const _ColorModeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: ClipOval(
          child: Image.asset(
            kDagigaColorRingAsset,
            width: kDagigaControlSize,
            height: kDagigaControlSize,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: kDagigaControlSize,
              height: kDagigaControlSize,
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
            ),
          ),
        ),
      ),
    );
  }
}
