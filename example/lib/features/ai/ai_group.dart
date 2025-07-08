import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ai_text_commands/ai_text_commands_page_example.dart';
import 'background_remover/background_remover_stub_example.dart'
    if (dart.library.io) 'background_remover/background_remover_example.dart';

/// A [StatefulWidget] that represents the AI group page in the application.
class AiGroupPage extends StatefulWidget {
  /// Creates an instance of [AiGroupPage].
  const AiGroupPage({super.key});

  @override
  State<AiGroupPage> createState() => _AiGroupPageState();
}

class _AiGroupPageState extends State<AiGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ai-Integration'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('AI-Text-Commands'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openExample(const AiTextCommandsExample()),
          ),
          ListTile(
            leading: const Icon(Icons.content_cut_outlined),
            title: const Text('AI-Background-Remover'),
            trailing: const Icon(Icons.chevron_right),
            subtitle: kIsWeb
                ? const Text('That function is not supported on the web.')
                : null,
            onTap: kIsWeb
                ? null
                : () => _openExample(const BackgroundRemoverExample()),
          ),
        ],
      ),
    );
  }

  void _openExample(Widget example) async {
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => example,
        ),
      );
    }
  }
}
