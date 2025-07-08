import 'dart:convert';

import 'package:example/features/ai/ai_text_commands/providers/ai_message_base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pro_image_editor/pro_image_editor.dart';

import '../enum/ai_provider_enum.dart';
import '../schemas/gemini_response_schema.dart';

/// Sends image editing commands using the Gemini AI provider.
class AiMessageGeminiProvider extends AiMessageBaseProvider {
  /// Creates an instance with the given API key and context.
  const AiMessageGeminiProvider({
    required super.apiKey,
    required super.context,
  });

  @override
  final AiProvider provider = AiProvider.gemini;
  @override
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  @override
  Future<void> sendCommand(
    ProImageEditorState editor,
    String systemConfig,
    String command,
  ) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemConfig\nUser Message: $command'}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': geminiResponseSchema,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result =
          data['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString();
      if (result != null) await handleAiResponse(editor, result);
    } else {
      debugPrint('❌ Gemini error: ${response.statusCode} ${response.body}');
      if (response.statusCode == 400 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid API key')),
        );
      }
    }
  }
}
