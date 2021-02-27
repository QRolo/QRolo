import 'dart:html' show ImageData;
import 'dart:typed_data' show Uint8ClampedList;

import 'package:qrolo/src/jsqr.dart' show jsQR;

///
/// Assumedly straight 0-255 1D array that is transformed into
/// calculation matrix based on width and height
///
/// Could ostensibly be used for QR code check of any image data,
/// given the right transformation params
String? getQRCodeFromData(
  Uint8ClampedList data,
  int width,
  int height,
) {
  // Use jsQR
  jsQR(
    data,
    width,
    height,
  );

  return null;
}

/// Helper wrapper
/// for compatibility with MediaStream ImageData
String? getQRCodeFromImageDataFrame(
  ImageData image,
  int width,
  int height,
) {
  return getQRCodeFromData(
    image.data,
    width,
    height,
  );
}
