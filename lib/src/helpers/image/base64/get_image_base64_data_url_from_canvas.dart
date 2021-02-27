import 'dart:html' show CanvasElement, VideoElement;

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
