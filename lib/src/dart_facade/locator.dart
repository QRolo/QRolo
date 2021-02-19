@JS()
library locator;

import 'package:js/js.dart';
import './BitMatrix.dart' show BitMatrix;

@anonymous
@JS()
abstract class Point {
  external num get x;
  external set x(num v);
  external num get y;
  external set y(num v);
  external factory Point({num x, num y});
}

@anonymous
@JS()
abstract class QRLocation {
  external Point get topRight;
  external set topRight(Point v);
  external Point get bottomLeft;
  external set bottomLeft(Point v);
  external Point get topLeft;
  external set topLeft(Point v);
  external Point get alignmentPattern;
  external set alignmentPattern(Point v);
  external num get dimension;
  external set dimension(num v);
  external factory QRLocation(
      {Point topRight,
      Point bottomLeft,
      Point topLeft,
      Point alignmentPattern,
      num dimension});
}

@JS()
external List<QRLocation> locate(BitMatrix matrix);
