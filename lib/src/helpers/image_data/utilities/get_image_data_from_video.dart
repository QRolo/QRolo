import 'dart:html' show CanvasElement, ImageData, VideoElement;

import 'package:qrolo/src/helpers/canvas/get_context_virtual_draw_context_from_video_element.dart'
    show createPredrawnContextualisedCanvasFrameFromVideoElement;
import 'package:qrolo/src/helpers/image_data/utilities/get_image_data_from_canvas.dart'
    show getImageDataFromCanvas;

/// Draw a virtual canvas to get the image data back..
/// videoElement `HTMLVideoElement` can be used as a `CanvasImageSource`
/// Use frames being presented by a <video> element
/// even if not visible
/// Surely there is a quicker technique rather than via virtual draw
///
/// Get the image data or matrix from our streaming video element
///
/// Important: width and heigth should match across video, image, jsqr data
///
/// ? Warning: Unsure if canvas video div element may have been potentially
/// mutated by devor dynamic user responsive UI
ImageData captureImageDataFrameFromStream(
  VideoElement videoElement,
) {
  // Creating a virtual canvas simply to capture imageData?
  final CanvasElement sizedDrawnCanvasContextualisedFrame =
      createPredrawnContextualisedCanvasFrameFromVideoElement(
    videoElement: videoElement,
  );

  final context = sizedDrawnCanvasContextualisedFrame.context2D;

  final ImageData imageData = getImageDataFromCanvas(
    context,
    videoElement.width,
    videoElement.height,
  );

  /* 
    IndexSizeError
    SecurityError
  */
  return imageData;
}
