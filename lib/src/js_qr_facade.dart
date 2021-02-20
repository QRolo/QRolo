@JS()
library jsqr;

import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:qrolo/src/dart_facade/decoder/decode_data.dart' show Chunks;

@anonymous
@JS()
abstract class QRCode {
  external List<num> get binaryData;
  external set binaryData(List<num> v);
  external String get data;
  external set data(String v);
  external Chunks get chunks;
  external set chunks(Chunks v);
  external dynamic
      /*{
        topRightCorner: Point;
        topLeftCorner: Point;
        bottomRightCorner: Point;
        bottomLeftCorner: Point;
        topRightFinderPattern: Point;
        topLeftFinderPattern: Point;
        bottomLeftFinderPattern: Point;
        bottomRightAlignmentPattern?: Point;
    }*/
      get location;
  external set location(
      dynamic
          /*{
        topRightCorner: Point;
        topLeftCorner: Point;
        bottomRightCorner: Point;
        bottomLeftCorner: Point;
        topRightFinderPattern: Point;
        topLeftFinderPattern: Point;
        bottomLeftFinderPattern: Point;
        bottomRightAlignmentPattern?: Point;
    }*/
          v);
  external factory QRCode({
    List<num> binaryData,
    String data,
    Chunks chunks,
    dynamic
        /*{
        topRightCorner: Point;
        topLeftCorner: Point;
        bottomRightCorner: Point;
        bottomLeftCorner: Point;
        topRightFinderPattern: Point;
        topLeftFinderPattern: Point;
        bottomLeftFinderPattern: Point;
        bottomRightAlignmentPattern?: Point;
    }*/
        location,
  });
}

@anonymous
@JS()
abstract class Options {
  external String /*'dontInvert'|'onlyInvert'|'attemptBoth'|'invertFirst'*/ get inversionAttempts;
  external set inversionAttempts(
    String /*'dontInvert'|'onlyInvert'|'attemptBoth'|'invertFirst'*/ v,
  );
  external factory Options({
    String /*'dontInvert'|'onlyInvert'|'attemptBoth'|'invertFirst'*/ inversionAttempts,
  });
}

@JS()
external QRCode /*QRCode|Null*/ jsQR(
  Uint8ClampedList /* Uint8ClampedArray */ data,
  num width,
  num height, [
  Options providedOptions,
]); /* WARNING: export assignment not yet supported. */
