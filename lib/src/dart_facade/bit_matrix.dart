@JS()
library bit_matrix;

import 'dart:typed_data' show Uint8ClampedList;

import 'package:js/js.dart' show JS;

@JS()
class BitMatrix {
  external factory BitMatrix(Uint8ClampedList data, num width);

  // @Ignore
  external BitMatrix.fakeConstructor$();

  external static BitMatrix createEmpty(
    num width,
    num height,
  );
  external num get width;
  external set width(num v);
  external num get height;
  external set height(num v);
  external Uint8ClampedList get data;
  external set data(Uint8ClampedList v);
  external bool get(num x, num y);
  // If this was a first-party lib we would be able to decide named bool.
  external void set(
    num x,
    num y,
    // ignore: avoid_positional_boolean_parameters
    bool v,
  );
  external void setRegion(
    num left,
    num top,
    num width,
    num height,
    // ignore: avoid_positional_boolean_parameters
    bool v,
  );
}
