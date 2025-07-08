import 'dart:convert';

import 'package:example/features/ai/ai_text_commands/providers/ai_message_base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pro_image_editor/pro_image_editor.dart';

import '../enum/ai_provider_enum.dart';

/// Sends image editing commands using OpenAI's chat completions API.
class AiMessageOpenAiProvider extends AiMessageBaseProvider {
  /// Creates an instance with the given API key and context.
  const AiMessageOpenAiProvider({
    required super.apiKey,
    required super.context,
  });

  @override
  final AiProvider provider = AiProvider.openAi;
  @override
  final String endpoint = 'https://api.openai.com/v1/chat/completions';

  @override
  Future<void> sendCommand(
    ProImageEditorState editor,
    String systemConfig,
    String command,
  ) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {'role': 'system', 'content': systemConfig},
          {'role': 'user', 'content': command},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['choices']?[0]?['message']?['content']?.toString();
      if (result != null) await handleAiResponse(editor, result);
    } else {
      debugPrint('❌ OpenAI error: ${response.statusCode} ${response.body}');
      if (response.statusCode == 401 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid API key')),
        );
      }
    }
  }
}
