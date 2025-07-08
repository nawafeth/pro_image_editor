import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';
import '/features/ai/ai_text_commands/utils/build_ai_system_config.dart';
import 'providers/ai_message_base_provider.dart';
import 'utils/ai_message_provider_factory.dart';
import 'widgets/ai_command_toolbar_widget.dart';
import 'widgets/ai_setup_widget.dart';

/// A Flutter image-editor that demonstrates the usage of
/// AI-powered text commands.
class AiTextCommandsExample extends StatefulWidget {
  /// Creates an instance of [AiTextCommandsExample].
  const AiTextCommandsExample({super.key});

  @override
  State<AiTextCommandsExample> createState() => _AiTextCommandsExampleState();
}

class _AiTextCommandsExampleState extends State<AiTextCommandsExample>
    with ExampleHelperState<AiTextCommandsExample> {
  final _alignTopNotifier = ValueNotifier(false);
  final _isProcessingNotifier = ValueNotifier(false);

  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

  late final _editorConfigs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    imageGeneration: const ImageGenerationConfigs(
      outputFormat: OutputFormat.png,
    ),
    mainEditor: MainEditorConfigs(
      enableCloseButton: !isDesktopMode(context),
      widgets: _buildBodyItems(),
    ),
  );
  late final _editorCallbacks = ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
    ),
  );

  AiMessageBaseProvider? _aiProvider;

  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  void dispose() {
    _alignTopNotifier.dispose();
    _isProcessingNotifier.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _sendCommand() async {
    final command = _inputCtrl.value.text.trim();
    if (command.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    _isProcessingNotifier.value = true;

    final editor = editorKey.currentState!;

    final state = editor.stateManager;
    final sizesManager = editor.sizesManager;

    final history = {
      'layers': state.activeLayers.map((layer) => layer.toMap()).toList(),
      'blur': state.activeBlur,
      'transform': state.transformConfigs.isNotEmpty
          ? state.transformConfigs.toMap()
          : null,
      'filters': state.activeFilters,
      'tune': state.activeTuneAdjustments.map((tune) => tune.toMap()).toList(),
    };
    final systemConfig = buildAiSystemConfig(
      configs: _editorConfigs,
      imageSize: sizesManager.decodedImageSize,
      editorBodySize: sizesManager.bodySize,
      activeHistory: json.encode(history),
      safeArea: const EdgeInsets.all(24),
      enablePaint: true,
      enableText: true,
      enableEmoji: true,
      enableTransform: true,
      enableTune: true,
      enableFilters: true,
      enableBlur: true,
      // TODO:
      enableImageGeneration: false, // _provider == AiProvider.chatGpt
    );

    await _aiProvider!.sendCommand(editor, systemConfig, command);
    if (!mounted) return;

    /// Reset
    _inputCtrl.value = TextEditingValue.empty;
    _isProcessingNotifier.value = false;
    if (isDesktop) _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_aiProvider == null) {
      return AiSetupWidget(onChanged: (apiKey, provider) {
        _aiProvider = AiMessageProviderFactory.create(
          apiKey: apiKey,
          provider: provider,
          context: context,
        );
        setState(() {});
      });
    } else if (!isPreCached) {
      return const PrepareImageWidget();
    }

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: _editorCallbacks,
      configs: _editorConfigs,
    );
  }

  MainEditorWidgets _buildBodyItems() {
    return MainEditorWidgets(
      bodyItems: (editor, rebuildStream) {
        return [
          ReactiveWidget(
            stream: rebuildStream,
            builder: (_) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: editor.selectedLayerIndex >= 0 || editor.isSubEditorOpen
                    ? SizedBox.shrink(key: UniqueKey())
                    : _buildCommandLine(),
              );
            },
          ),
        ];
      },
    );
  }

  Widget _buildCommandLine() {
    return AiCommandToolbarWidget(
      isProcessingNotifier: _isProcessingNotifier,
      alignTopNotifier: _alignTopNotifier,
      inputCtrl: _inputCtrl,
      inputFocus: _inputFocus,
      onSend: _sendCommand,
    );
  }
}
