@JS()
library BitMatrix;

import 'package:js/js.dart';

@JS()
class BitMatrix {
  // @Ignore
  BitMatrix.fakeConstructor$();
  external static BitMatrix createEmpty(num width, num height);
  external num get width;
  external set width(num v);
  external num get height;
  external set height(num v);
  external get data;
  external set data(v);
  external factory BitMatrix(Uint8ClampedArray data, num width);
  external bool get(num x, num y);
  external void set(num x, num y, bool v);
  external void setRegion(num left, num top, num width, num height, bool v);
}
