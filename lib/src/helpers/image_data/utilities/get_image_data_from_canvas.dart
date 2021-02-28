import 'dart:html';

/// Get canvas context and size
/// Defaults
///
ImageData getImageDataFromCanvas(
  CanvasRenderingContext2D canvasContext,
  int width,
  int height,
) {
  const int startX = 0;
  const int startY = 0;

  return canvasContext.getImageData(startX, startY, width, height);
}
