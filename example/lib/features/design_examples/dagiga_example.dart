import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/dagiga/dagiga_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/mixin/example_helper.dart';
import '/shared/widgets/demo_build_stickers.dart';

/// The Dagiga design example.
class DagigaDesignExample extends StatefulWidget {
  /// Creates a new [DagigaDesignExample] widget.
  const DagigaDesignExample({
    super.key,
    required this.url,
  });

  /// The URL of the image to display.
  final String url;

  @override
  State<DagigaDesignExample> createState() => _DagigaDesignExampleState();
}

class _DagigaDesignExampleState extends State<DagigaDesignExample>
    with ExampleHelperState<DagigaDesignExample> {
  final _mainEditorBarKey = GlobalKey<DagigaMainBarState>();
  final _textBarKey = GlobalKey<DagigaTextBarState>();
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignMode.material;

  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1)
          .floor();

  void _showColorDialog({
    required BuildContext context,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    Color? newColor;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => newColor = color,
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Okay'),
            onPressed: () {
              if (newColor != null) onColorChanged(newColor!);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ProImageEditor.network(
        widget.url,
        key: editorKey,
        callbacks: ProImageEditorCallbacks(
          onImageEditingStarted: onImageEditingStarted,
          onImageEditingComplete: onImageEditingComplete,
          onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
          mainEditorCallbacks: MainEditorCallbacks(
            helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
            onStartCloseSubEditor: (_) {
              _mainEditorBarKey.currentState?.setState(() {});
            },
          ),
          stickerEditorCallbacks: StickerEditorCallbacks(
            onSearchChanged: (value) {
              debugPrint(value);
            },
          ),
        ),
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kDagigaAccent,
              brightness: Brightness.dark,
            ),
          ),
          layerInteraction: LayerInteractionConfigs(
            selectable: LayerInteractionSelectable.enabled,
            hideToolbarOnInteraction: false,
            style: const LayerInteractionStyle(
              overlayPadding: EdgeInsets.all(4),
              borderColor: kDagigaAccent,
            ),
            widgets: LayerInteractionWidgets(
              overlayChildBuilder: (rebuildStream, info, layer, interactions) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (context) {
                    if (!layer.isTextLayer) {
                      return const SizedBox.shrink();
                    }
                    return DagigaTextLayerOverlay(
                      info: info,
                      layer: layer,
                      interactions: interactions,
                      editorKey: editorKey,
                      safeArea: MediaQuery.viewPaddingOf(context),
                    );
                  },
                );
              },
            ),
          ),
          mainEditor: MainEditorConfigs(
            // Let the frosted bottom sheet sit flush — no empty gap under it.
            safeArea: const EditorSafeArea(bottom: false),
            tools: const [
              SubEditorMode.text,
              SubEditorMode.sticker,
              SubEditorMode.paint,
              SubEditorMode.cropRotate,
              SubEditorMode.tune,
              SubEditorMode.filter,
              SubEditorMode.blur,
              SubEditorMode.emoji,
            ],
            widgets: MainEditorWidgets(
              appBar: (editor, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,

                  title: 'Edit Image',
                  backLabel: 'Image',
                  saveLabel: editor.configs.i18n.done,
                  onBack: editor.closeEditor,
                  onSave: editor.doneEditing,
                  onUndo: editor.undoAction,
                  undoEnabled: editor.canUndo,
                  undoTooltip: editor.configs.i18n.undo,
                ),
              ),
              bottomBar: (editor, rebuildStream, key) => ReactiveWidget(
                key: key,
                stream: rebuildStream,
                builder: (context) {
                  return DagigaMainBar(
                    key: _mainEditorBarKey,
                    editor: editor,
                    configs: editor.configs,
                    callbacks: editor.callbacks,
                    toolOverrides: {
                      SubEditorMode.paint: editor.openStickerEditor,
                    },
                  );
                },
              ),
            ),
            style: const MainEditorStyle(
              background: kDagigaBackground,
              bottomBarBackground: Colors.transparent,
            ),
          ),
          paintEditor: PaintEditorConfigs(
            safeArea: const EditorSafeArea(bottom: false),
            style: const PaintEditorStyle(
              background: kDagigaBackground,
              bottomBarBackground: kDagigaBottomSheetBackground,
              initialStrokeWidth: 5,
              bottomBarActiveItemColor: kDagigaAccent,
            ),
            widgets: PaintEditorWidgets(
              appBar: (paintEditor, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,
                  title: 'Paint',
                  backLabel: 'Edit Image',
                  saveLabel: paintEditor.configs.i18n.done,
                  onBack: paintEditor.close,
                  onSave: paintEditor.done,
                  onUndo: paintEditor.undoAction,
                  undoEnabled: paintEditor.canUndo,
                  undoTooltip: paintEditor.configs.i18n.undo,
                ),
              ),
              colorPicker:
                  (paintEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (context) {
                    return DagigaPaintBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                      i18nColor: 'Color',
                      showColorPicker: (currentColor) {
                        _showColorDialog(
                          context: context,
                          currentColor: currentColor,
                          onColorChanged: editorState.setColor,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          textEditor: TextEditorConfigs(
            safeArea: const EditorSafeArea(bottom: false),
            initialBackgroundColorMode: LayerBackgroundMode.onlyColor,
            customTextStyles: [
              GoogleFonts.poppins(fontSize: 40),
              GoogleFonts.inter(fontSize: 40),
              GoogleFonts.nunito(fontSize: 40),
              GoogleFonts.montserrat(fontSize: 40),
              GoogleFonts.playfairDisplay(fontSize: 40),
              GoogleFonts.lora(fontSize: 40),
              GoogleFonts.merriweather(fontSize: 40),
              GoogleFonts.cormorantGaramond(fontSize: 40),
            ],

            style: const TextEditorStyle(
              textFieldMargin: EdgeInsets.zero,
              bottomBarBackground: kDagigaBottomSheetBackground,
              inputCursorColor: kDagigaAccent,
            ),
            widgets: TextEditorWidgets(
              appBar: (textEditor, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,
                  title: 'Add text',
                  backLabel: 'Edit Image',
                  saveLabel: textEditor.configs.i18n.done,
                  onBack: textEditor.close,
                  onSave: textEditor.done,
                ),
              ),
              colorPicker:
                  (textEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (editorState, rebuildStream) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (context) {
                    return DagigaTextBar(
                      key: _textBarKey,
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                      arabicTextStyles: [
                        GoogleFonts.cairo(fontSize: 40),
                        GoogleFonts.tajawal(fontSize: 40),
                        GoogleFonts.almarai(fontSize: 40),
                        GoogleFonts.ibmPlexSansArabic(fontSize: 40),
                        GoogleFonts.amiri(fontSize: 40),
                        GoogleFonts.notoNaskhArabic(fontSize: 40),
                        GoogleFonts.lateef(fontSize: 40),
                        GoogleFonts.arefRuqaa(fontSize: 40),
                      ],
                      showColorPicker: (currentColor, apply) {
                        _showColorDialog(
                          context: context,
                          currentColor: currentColor,
                          onColorChanged: apply,
                        );
                      },
                    );
                  },
                );
              },
              bodyItems: (editorState, rebuildStream) => [
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => DagigaTextFloatingControls(
                    isArabic: false,
                    editor: editorState,
                    onAlternateStyle: () {
                      _textBarKey.currentState?.openBackgroundColorPicker();
                    },
                  ),
                ),
              ],
            ),
          ),
          cropRotateEditor: CropRotateEditorConfigs(
            safeArea: const EditorSafeArea(bottom: false),
            style: const CropRotateEditorStyle(
              cropCornerColor: Colors.white,
              cropCornerLength: 36,
              cropCornerThickness: 4,
              background: kDagigaBackground,
              bottomBarBackground: kDagigaBottomSheetBackground,
              helperLineColor: Color(0x25FFFFFF),
            ),
            widgets: CropRotateEditorWidgets(
              appBar: (cropRotateEditor, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,
                  title: 'Crop',
                  backLabel: 'Edit Image',
                  saveLabel: cropRotateEditor.configs.i18n.done,
                  onBack: cropRotateEditor.close,
                  onSave: cropRotateEditor.done,
                  onUndo: cropRotateEditor.undoAction,
                  undoEnabled: cropRotateEditor.canUndo,
                  undoTooltip: cropRotateEditor.configs.i18n.undo,
                ),
              ),
              bottomBar: (cropRotateEditor, rebuildStream) => ReactiveWidget(
                stream: rebuildStream,
                builder: (_) => DagigaCropRotateBar(
                  configs: cropRotateEditor.configs,
                  callbacks: cropRotateEditor.callbacks,
                  editor: cropRotateEditor,
                  selectedRatioColor: kDagigaAccent,
                ),
              ),
            ),
          ),
          filterEditor: FilterEditorConfigs(
            safeArea: const EditorSafeArea(bottom: false),
            fadeInUpDuration: kDagigaFadeInDuration,
            fadeInUpStaggerDelayDuration: kDagigaFadeInStaggerDelay,
            style: const FilterEditorStyle(
              filterListSpacing: 7,
              filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
              background: kDagigaBackground,
            ),
            widgets: FilterEditorWidgets(
              appBar: (editorState, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,
                  title: 'Filter',
                  backLabel: 'Edit Image',
                  saveLabel: editorState.configs.i18n.done,
                  onBack: editorState.close,
                  onSave: editorState.done,
                ),
              ),
              slider:
                  (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
                      ReactiveWidget(
                stream: rebuildStream,
                builder: (_) => Slider(
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  value: value,
                  activeColor: kDagigaAccent,
                ),
              ),
              bottomBar: (editorState, rebuildStream) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (context) {
                    return DagigaFilterBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                    );
                  },
                );
              },
            ),
          ),
          tuneEditor: TuneEditorConfigs(
            safeArea: const EditorSafeArea(bottom: false),
            style: const TuneEditorStyle(
              background: kDagigaBackground,
              bottomBarBackground: kDagigaBottomSheetBackground,
              bottomBarActiveItemColor: kDagigaAccent,
            ),
            widgets: TuneEditorWidgets(
              appBar: (editor, rebuildStream) => ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => DagigaAppBar(
                  isArabic: false,
                  title: 'Tune',
                  backLabel: 'Edit Image',
                  saveLabel: editor.configs.i18n.done,
                  onBack: editor.close,
                  onSave: editor.done,
                  onUndo: editor.undo,
                  undoEnabled: editor.canUndo,
                  undoTooltip: editor.configs.i18n.undo,
                ),
              ),
              bottomBar: (editorState, rebuildStream) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (context) {
                    return DagigaTuneBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                    );
                  },
                );
              },
            ),
          ),
          emojiEditor: EmojiEditorConfigs(
            checkPlatformCompatibility: !kIsWeb,
            style: EmojiEditorStyle(
              backgroundColor: Colors.transparent,
              textStyle: DefaultEmojiTextStyle.copyWith(
                fontFamily:
                    !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                fontSize: _useMaterialDesign ? 48 : 30,
              ),
              emojiViewConfig: EmojiViewConfig(
                gridPadding: EdgeInsets.zero,
                horizontalSpacing: 0,
                verticalSpacing: 0,
                recentsLimit: 40,
                backgroundColor: Colors.transparent,
                buttonMode: !_useMaterialDesign
                    ? ButtonMode.CUPERTINO
                    : ButtonMode.MATERIAL,
                loadingIndicator:
                    const Center(child: CircularProgressIndicator()),
                columns: _calculateEmojiColumns(constraints),
                emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                replaceEmojiOnLimitExceed: false,
              ),
              bottomActionBarConfig:
                  const BottomActionBarConfig(enabled: false),
            ),
          ),
          i18n: const I18n(
            done: 'Save',
            paintEditor: I18nPaintEditor(
              bottomNavigationBarText: 'Logo',
              changeOpacity: 'Opacity',
              lineWidth: 'Thickness',
            ),
            textEditor: I18nTextEditor(
              bottomNavigationBarText: 'Text',
              backgroundMode: 'Mode',
              textAlign: 'Align',
            ),
            stickerEditor: I18nStickerEditor(
              bottomNavigationBarText: 'Sticker',
            ),
          ),
          stickerEditor: StickerEditorConfigs(
            builder: (setLayer, scrollController) => DemoBuildStickers(
              categoryColor: kDagigaBottomSheetBackground,
              setLayer: setLayer,
              scrollController: scrollController,
            ),
          ),
          dialogConfigs: DialogConfigs(
            widgets: DialogWidgets(
              loadingDialog: (message, configs) => DagigaLoadingDialog(
                message: message,
                configs: configs,
              ),
            ),
          ),
        ),
      );
    });
  }
}
