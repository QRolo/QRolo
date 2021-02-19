@JS()
library binarizer;

import 'package:js/js.dart';

@JS()
external dynamic
    /*{
    binarized: BitMatrix;
    inverted: BitMatrix;
}|{
    binarized: BitMatrix;
    inverted?: undefined;
}*/
    binarize(
        Uint8ClampedArray data, num width, num height, bool returnInverted);
