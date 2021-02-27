import 'dart:html' show CanvasElement, VideoElement;

import 'package:qrolo/src/helpers/canvas/get_context_virtual_draw_context_from_video_element.dart'
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
