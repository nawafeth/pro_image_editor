// Flutter imports:
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/mixin/example_helper.dart';
import '/features/video_examples/pages/chewie_player_example.dart';
import '/features/video_examples/pages/flick_video_player_example.dart';
import '/features/video_examples/pages/video_player_example.dart';
import 'pages/video_media_kit_example.dart';

/// The video example widget
class VideoExample extends StatefulWidget {
  /// Creates a new [VideoExample] widget.
  const VideoExample({super.key});

  @override
  State<VideoExample> createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample>
    with ExampleHelperState<VideoExample> {
  final _isWebEditingSupported = false;

  late final bool _isVideoPlayerSupported =
      (kIsWeb && _isWebEditingSupported) ||
          Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS;
  late final bool _isFlickPlayerSupported =
      (kIsWeb && _isWebEditingSupported) ||
          Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS;
  late final bool _isChewiePlayerSupported =
      (kIsWeb && _isWebEditingSupported) ||
          Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video-Example'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'The video editor is still in development and cannot generate an '
              'exported video yet. This is just a preview of how the video '
              'editor will look for users who want to prepare for its '
              'implementation.',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'For a reduced bundle size and fewer dependencies, no video '
              'player package is included. However, the image editor supports '
              'easy integration with an external video player, allowing video '
              'editing to be set up in just a few lines of code.\n\n'
              'Choose one of the packages below that best suits your needs. '
              'Be sure to review which platforms each package supports, as '
              'well as their pros and cons, before making a decision.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('Package "media_kit"'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoMediaKitExample(),
                ),
              );
            },
          ),
          ListTile(
            enabled: _isVideoPlayerSupported,
            leading: const Icon(Icons.movie),
            title: const Text('Package "video_player"'),
            subtitle: _isVideoPlayerSupported ? null : _buildNotSupportedMsg(),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isVideoPlayerSupported
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VideoPlayerExample(),
                      ),
                    );
                  }
                : null,
          ),
          ListTile(
            enabled: _isFlickPlayerSupported,
            leading: const Icon(Icons.movie),
            title: const Text('Package "flick_video_player"'),
            subtitle: _isFlickPlayerSupported ? null : _buildNotSupportedMsg(),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isFlickPlayerSupported
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FlickVideoPlayerExample(),
                      ),
                    );
                  }
                : null,
          ),
          ListTile(
            enabled: _isChewiePlayerSupported,
            leading: const Icon(Icons.movie),
            title: const Text('Package "chewie"'),
            subtitle: _isChewiePlayerSupported ? null : _buildNotSupportedMsg(),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isChewiePlayerSupported
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChewiePlayerExample(),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotSupportedMsg() {
    return const Text('This package is not supported on that platform.');
  }
}
