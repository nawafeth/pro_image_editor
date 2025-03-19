import 'dart:async';

import 'package:example/core/constants/example_constants.dart';
import 'package:example/core/mixin/example_helper.dart';
import 'package:example/features/video_examples/mixins/thumbnail_generator_mixin.dart';
import 'package:example/features/video_examples/widgets/video_initializing_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A widget that demonstrates video editing using MediaKit and ProImageEditor.
class VideoMediaKitExample extends StatefulWidget {
  /// Creates a [VideoMediaKitExample] widget.
  const VideoMediaKitExample({super.key});

  @override
  State<VideoMediaKitExample> createState() => _VideoMediaKitExampleState();
}

class _VideoMediaKitExampleState extends State<VideoMediaKitExample>
    with ExampleHelperState<VideoMediaKitExample>, ThumbnailGeneratorMixin {
  /// IMPORTANT: Ensure that you have called `MediaKit.ensureInitialized();`
  /// in the main method.

  final _player = Player();
  late final _controller = VideoController(_player);

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    var bytes = await loadAssetImageAsUint8List(kVideoEditorExampleAssetPath);

    await _player.open(
      await Media.memory(bytes),
      play: videoConfigs.initialPlay,
    );
    await _player.setPlaylistMode(PlaylistMode.none);
    await _player.setVolume(videoConfigs.initialMuted ? 0 : 100);

    Completer<void> durationCompleter = Completer();
    Completer<void> resolutionCompleter = Completer();
    Size initialSize = Size.zero;
    Duration videoDuration = Duration.zero;

    /// Read duration
    _player.stream.duration.listen((event) {
      if (!mounted) return;

      videoDuration = event;

      if (!durationCompleter.isCompleted) {
        durationCompleter.complete();
      }
      setState(() {});
    });

    /// Read resolution
    _player.stream.width.listen((event) {
      if (!mounted) return;

      initialSize = Size(
        _player.state.width?.toDouble() ?? 0,
        _player.state.height?.toDouble() ?? 0,
      );

      if (!resolutionCompleter.isCompleted) {
        resolutionCompleter.complete();
      }
      setState(() {});
    });

    /// Listen to play time
    _player.stream.position.listen((position) {
      if (!mounted || proVideoController == null) return;
      proVideoController!.setPlayTime(position);

      if (isSeeking || durationSpan == null || position < durationSpan!.end) {
        return;
      }

      _seekToPosition(durationSpan!);
    });

    /// Listen video end
    _player.stream.completed.listen((isEnded) {
      if (!mounted || !isEnded || isSeeking || durationSpan == null) {
        return;
      }

      _seekToPosition(durationSpan!);
    });

    await durationCompleter.future;
    await resolutionCompleter.future;

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: initialSize,
      videoDuration: videoDuration,
      fileSize: bytes.lengthInBytes,
      thumbnails: thumbnails,
    );
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    durationSpan = span;

    if (isSeeking) {
      tempDurationSpan = span; // Store the latest seek request
      return;
    }
    isSeeking = true;

    proVideoController!.pause();
    proVideoController!.setPlayTime(durationSpan!.start);

    await _player.pause();
    await _player.seek(span.start);

    isSeeking = false;

    // Check if there's a pending seek request
    if (tempDurationSpan != null) {
      TrimDurationSpan nextSeek = tempDurationSpan!;
      tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: proVideoController == null
          ? VideoInitializingWidget(player: _buildVideoPlayer())
          : ProImageEditor.video(
              proVideoController!,
              callbacks: ProImageEditorCallbacks(
                videoEditorCallbacks: VideoEditorCallbacks(
                  onPause: _player.pause,
                  onPlay: _player.play,
                  onMuteToggle: (isMuted) {
                    _player.setVolume(isMuted ? 0 : 100);
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_player.state.playing) {
                      proVideoController!.pause();
                    }
                  },
                  onTrimSpanEnd: _seekToPosition,
                ),
              ),
              configs: ProImageEditorConfigs(
                mainEditor: MainEditorConfigs(
                  widgets: MainEditorWidgets(
                    removeLayerArea: (removeAreaKey, editor, rebuildStream) =>
                        VideoEditorRemoveArea(
                      removeAreaKey: removeAreaKey,
                      editor: editor,
                      rebuildStream: rebuildStream,
                    ),
                  ),
                ),
                videoEditor: videoConfigs,
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return Video(
      key: const ValueKey('Video-Player'),
      controller: _controller,
      controls: null,
    );
  }
}
