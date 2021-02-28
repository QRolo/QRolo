import 'dart:html' show CanvasElement, VideoElement;

import 'package:qrolo/src/helpers/canvas/get_predrawn_contextualised_canvas_frame_created_from_video_element.dart'
    show getPredrawnContextualisedCanvasFrameCreatedFromVideoElement;

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
      getPredrawnContextualisedCanvasFrameCreatedFromVideoElement(
    videoElement: videoElement,
  );

  return frameCanvas.toDataUrl(
    imageDataUrlType,
    qualityDecimalFraction,
  );
}
