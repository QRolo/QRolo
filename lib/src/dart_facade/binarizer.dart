@JS()
library binarizer;

/// For Uint8ClampedArray Uint8ClampedList
import 'dart:typed_data' show Uint8ClampedList;

import 'package:js/js.dart' show JS;

@JS()
external dynamic
    /*{
    binarized: BitMatrix;
    inverted: BitMatrix;
}|{
    binarized: BitMatrix;
    inverted?: undefined;
}*/
    binarize(Uint8ClampedList data, num width, num height, bool returnInverted);
