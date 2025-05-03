import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '/core/models/editor_configs/image_generation_configs/image_generation_configs.dart';
import '/core/models/editor_image.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';

/// A utility singleton class that handles conversion of image formats
/// using custom generation configurations and a recording system.
class ImageConverter {
  ImageConverter._();

  /// The singleton instance of [ImageConverter].
  static final ImageConverter instance = ImageConverter._();

  /// Builds a [ContentRecorderController] with minimum processor mode
  /// for lightweight image processing.
  ///
  /// The [configs] parameter allows customization of the output format,
  /// dimensions, and quality settings.
  ContentRecorderController _buildRecorder(ImageGenerationConfigs configs) =>
      ContentRecorderController(
        isVideoEditor: false,
        configs: configs.copyWith(
          processorConfigs: configs.processorConfigs.copyWith(
            processorMode: ProcessorMode.minimum,
          ),
        ),
      );

  /// Converts a byte array to a [ui.Image] instance.
  ///
  /// This is useful for rendering raw bytes using the Canvas API.
  Future<ui.Image> _bytesToImage(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  /// Converts an [EditorImage] into a different [OutputFormat] using
  /// the given [generationConfigs].
  ///
  /// The [context] is required to safely access widget lifecycle.
  ///
  /// Returns the converted image bytes, or `null` if the widget is no
  /// longer mounted during processing.
  ///
  /// Throws [ArgumentError] if conversion fails.
  Future<Uint8List?> convertFormat({
    required EditorImage image,
    required OutputFormat format,
    ImageGenerationConfigs generationConfigs = const ImageGenerationConfigs(),
  }) async {
    /// Get original image bytes
    var originalBytes = await image.safeByteArray();

    /// Decode bytes into a ui.Image
    var convertedImage = await _bytesToImage(originalBytes);

    /// Apply desired output format
    var configs = generationConfigs.copyWith(outputFormat: format);

    /// Build recorder and perform conversion
    var recorder = _buildRecorder(configs);
    var resultBytes = await recorder.convertRawImageData(
      image: convertedImage,
    );

    /// Clean up
    await recorder.destroy();

    return resultBytes;
  }
}
