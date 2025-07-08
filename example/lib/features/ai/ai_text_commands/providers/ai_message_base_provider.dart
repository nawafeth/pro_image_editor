import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../enum/ai_provider_enum.dart';

/// Base class for AI message providers for image editing commands.
abstract class AiMessageBaseProvider {
  /// Creates a base AI message provider with context and API key.
  const AiMessageBaseProvider({
    required this.context,
    required this.apiKey,
  });

  /// The Flutter build context.
  final BuildContext context;

  /// IMPORTANT: Never expose your API key in production.
  /// Handle it securely on your backend.
  /// I just use it like that so you can easily test it.
  final String apiKey;

  /// The AI provider type.
  abstract final AiProvider provider;

  /// The API endpoint for the specific provider.
  @protected
  abstract final String endpoint;

  /// Sends a command to the AI and applies the result to the editor.
  Future<void> sendCommand(
    ProImageEditorState editor,
    String systemConfig,
    String command,
  );

  /// Parses and applies the AI response to the image editor state.
  @protected
  Future<void> handleAiResponse(
    ProImageEditorState editor,
    String response,
  ) async {
    if (!context.mounted) return;
    try {
      final result = json.decode(response) as Map<String, dynamic>;

      final blur =
          result.containsKey('blur') ? safeParseDouble(result['blur']) : null;

      final filters = result.containsKey('filters') && result['filters'] is List
          ? (result['filters'] as List)
              .map((matrix) => (matrix as List)
                  .map((v) => v.toDouble())
                  .toList()
                  .cast<double>())
              .toList()
              .cast<List<double>>()
          : null;

      final tuneAdjustments =
          result.containsKey('tune') && result['tune'] is List
              ? (result['tune'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(TuneAdjustmentMatrix.fromMap)
                  .toList()
              : null;

      final layers = result.containsKey('layers') && result['layers'] is List
          ? (result['layers'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Layer.fromMap)
              .toList()
          : null;

      final isTransformed = result.containsKey('transform') &&
          result['transform'] is Map &&
          (result['transform'] as Map).isNotEmpty;

      final transformConfigs = isTransformed
          ? TransformConfigs.fromMap(
              result['transform'] as Map<String, dynamic>)
          : null;

      editor.addHistory(
        blur: blur,
        filters: filters,
        tuneAdjustments: tuneAdjustments,
        layers: layers,
        transformConfigs: transformConfigs,
      );
    } catch (e) {
      debugPrint('❌ Failed to parse AI response: $e');
    }
  }
}
