import 'dart:html' show CanvasElement, VideoElement;

import 'package:qrolo/src/utilities/canvas/virtual_draw.dart'
    show createPredrawnContextualisedCanvasFrameFromVideoElement;

/// API utility for quick saving with the current video
/// Blob is faster than dataUrl though
///
/// imageDataUrlType
///   - 'image/jpeg'
///   - 'image/png'
///   - 'image/webp'
///
/// @returns DOMString
String getImageBase64DataUrlFromVideo({
  required VideoElement videoElement,
  String imageDataUrlType = 'image/jpeg',
  double qualityDecimalFraction = 0.90,
  int topLeftDestXLeft = 0,
  int topLeftDestYTop = 0,
}) {
  final CanvasElement frameCanvas =
      createPredrawnContextualisedCanvasFrameFromVideoElement(
    videoElement: videoElement,
  );

  return frameCanvas.toDataUrl(
    imageDataUrlType,
    qualityDecimalFraction,
  );
}

/// Single function call
/// minimal additional value other than sensible defaults
String getImageBase64DataUrlFromCanvas({
  required CanvasElement predrawnVideoFrameCanvas,
  String imageDataUrlType = 'image/jpeg',
  double qualityDecimalFraction = 0.90,
  int topLeftDestXLeft = 0,
  int topLeftDestYTop = 0,
}) {
  /// `canvas.toDataUrl("image/jpeg", 0.90);`
  return predrawnVideoFrameCanvas.toDataUrl(
    imageDataUrlType,
    qualityDecimalFraction,
  );
}
