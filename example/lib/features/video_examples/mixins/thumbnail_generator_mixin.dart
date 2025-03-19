import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A mixin for handling thumbnail generation and video editing states.
///
/// This mixin stores video thumbnails and manages playback and trim states.
mixin ThumbnailGeneratorMixin {
  /// Video editor configuration settings.
  final VideoEditorConfigs videoConfigs = const VideoEditorConfigs(
    initialMuted: true,
    initialPlay: false,
    minTrimDuration: Duration(seconds: 7),
  );

  /// Indicates whether a seek operation is in progress.
  bool isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? proVideoController;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  ///
  /// TODO: Generate thumbnails dynamically.
  final List<ImageProvider> thumbnails = [];
}
