import 'dart:html' show CanvasElement, CanvasRenderingContext2D, VideoElement;

/// Utility function
/// To reuse for both capture frame image data
/// and convert canvas (with context drawn) ito dataURI dataUrl
CanvasElement getPredrawnContextualisedCanvasFrameCreatedFromVideoElement({
  required VideoElement videoElement,
  int topLeftDestXLeft = 0,
  int topLeftDestYTop = 0,
}) {
  // Creating a virtual canvas simply to draw + capture imageData?
  final CanvasElement sizedVideoCanvas = CanvasElement(
    width: videoElement.videoWidth,
    height: videoElement.videoHeight,
  );
  final CanvasRenderingContext2D context = sizedVideoCanvas.context2D;

  // `HTMLVideoElement` can be used as a `CanvasImageSource`
  // Use frames being presented by a <video> element
  // even if not visible
  context.drawImage(
    videoElement,
    topLeftDestXLeft,
    topLeftDestYTop,
  );

  return sizedVideoCanvas;
}
