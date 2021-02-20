@JS()
library jsqr;

import 'dart:typed_data';

import 'package:js/js.dart' show JS, anonymous;
import 'package:qrolo/src/dart_facade/decoder/decode_data.dart' show Chunks;
import 'package:qrolo/src/location.dart';

@anonymous
@JS()
abstract class QRCode {
  external List<num> get binaryData;
  external set binaryData(List<num> v);
  external String get data;
  external set data(String v);
  external Chunks get chunks;
  external set chunks(Chunks v);
  external Location get location;
  external set location(
    Location v,
  );
  external factory QRCode({
    List<num> binaryData,
    String data,
    Chunks chunks,
    Location location,
  });
}

/// Default for JS?
const inversionAttemptBoth = 'attemptBoth';

/// Note 50% performance hit apparently to compare again with invert black/white
/// Default for Dart?
const inversionAttemptDontInvert = 'dontInvert';

/// Only invert.
const inversionAttemptOnlyInvert = 'onlyInvert';

/// Invert first??
const inversionAttemptInvertFirst = 'invertFirst';

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
