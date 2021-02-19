@JS()
library BitMatrix;

import 'dart:typed_data' show Uint8ClampedList;

import 'package:js/js.dart' show JS;

@JS()
class BitMatrix {
  // @Ignore
  BitMatrix.fakeConstructor$();
  external static BitMatrix createEmpty(num width, num height);
  external num get width;
  external set width(num v);
  external num get height;
  external set height(num v);
  external dynamic get data;
  external set data(v);
  external factory BitMatrix(Uint8ClampedList data, num width);
  external bool get(num x, num y);
  external void set(num x, num y, bool v);
  external void setRegion(num left, num top, num width, num height, bool v);
}
