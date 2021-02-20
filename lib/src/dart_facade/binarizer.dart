@JS()
library binarizer;

/// For Uint8ClampedArray Uint8ClampedList
import 'dart:typed_data' show Uint8ClampedList;

import 'package:js/js.dart' show JS;
import 'package:qrolo/src/dart_facade/bit_matrix.dart';

class BinarizedResult {
  final BitMatrix binarized;
  final BitMatrix? inverted;

  const BinarizedResult(this.binarized, this.inverted);
}

@JS()
external dynamic
    /*{
    binarized: BitMatrix;
    inverted: BitMatrix;
}|{
    binarized: BitMatrix;
    inverted?: undefined;
}*/
    // ignore: avoid_positional_boolean_parameters
    binarize(Uint8ClampedList data, num width, num height, bool returnInverted);
