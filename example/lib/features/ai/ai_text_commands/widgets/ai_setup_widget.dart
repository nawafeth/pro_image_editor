import 'package:flutter/material.dart';

import '../enum/ai_provider_enum.dart';

/// A widget that provides a UI for setting up AI configuration options,
/// such as selecting a provider and entering an API key.
class AiSetupWidget extends StatefulWidget {
  /// Creates an instance of [AiSetupWidget].
  const AiSetupWidget({
    super.key,
    required this.onChanged,
  });

  /// Called when the user changes the AI provider or API key.
  final Function(String apiKey, AiProvider provider) onChanged;

  @override
  State<AiSetupWidget> createState() => _AiSetupWidgetState();
}

class _AiSetupWidgetState extends State<AiSetupWidget> {
  final _apiKeyController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.openAi;
  bool _obscureText = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _startTest() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key')),
      );
      return;
    }

    widget.onChanged(apiKey, _selectedProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'AI Setup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ This key is only for testing. Never expose your real API '
              'key in production apps.',
              style: TextStyle(fontSize: 14, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            _buildProviderSelector(),
            const SizedBox(height: 20),
            _buildApiKeyInput(),
            const SizedBox(height: 24),
            Center(
              child: FilledButton(
                onPressed: _startTest,
                child: const Text('Start Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return TextField(
      controller: _apiKeyController,
      decoration: InputDecoration(
        labelText: 'API Key',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
    );
  }

  Widget _buildProviderSelector() {
    return DropdownButtonFormField<AiProvider>(
      value: _selectedProvider,
      decoration: const InputDecoration(
        labelText: 'Provider',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: AiProvider.openAi,
          child: Text('ChatGPT (OpenAI)'),
        ),
        DropdownMenuItem(
          value: AiProvider.gemini,
          child: Text('Gemini (Google)'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedProvider = value);
        }
      },
    );
  }
}
