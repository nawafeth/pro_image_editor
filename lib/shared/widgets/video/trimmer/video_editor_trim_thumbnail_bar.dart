import 'package:flutter/widgets.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

/// Displays a thumbnail preview of the video trim selection.
///
/// This widget shows a series of generated thumbnails representing
/// different frames of the trimmed video section.
class VideoEditorTrimThumbnailBar extends StatelessWidget {
  /// Creates a [VideoEditorTrimThumbnailBar] widget.
  const VideoEditorTrimThumbnailBar({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      height: player.style.trimBarHeight,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 51, 51, 51),
        borderRadius: BorderRadius.circular(player.style.trimBarHandlerRadius),
      ),
      child: Row(
        children: player.controller.thumbnails.map((item) {
          return Expanded(
            child: Image(
              image: item,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
  }
}
