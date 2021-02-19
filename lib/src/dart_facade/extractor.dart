@JS()
library extractor;

import 'package:js/js.dart';
import 'package:qrolo/src/dart_facade/locator.dart';
import './BitMatrix.dart' show BitMatrix;

@JS()
external dynamic
    /*{
    matrix: BitMatrix;
    mappingFunction: (x: number, y: number) => {
        x: number;
        y: number;
    };
}*/
    extract(BitMatrix image, QRLocation location);
