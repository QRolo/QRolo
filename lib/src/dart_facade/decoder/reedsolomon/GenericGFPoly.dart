@JS()
library decoder.reedsolomon.GenericGFPoly;

import 'package:js/js.dart';
import 'GenericGF.dart' show GenericGF;

@JS()
class GenericGFPoly {
  // @Ignore
  GenericGFPoly.fakeConstructor$();
  external get field;
  external set field(v);
  external get coefficients;
  external set coefficients(v);
  external factory GenericGFPoly(
      GenericGF field, Uint8ClampedArray coefficients);
  external num degree();
  external bool isZero();
  external num getCoefficient(num degree);
  external GenericGFPoly addOrSubtract(GenericGFPoly other);
  external GenericGFPoly multiply(num scalar);
  external GenericGFPoly multiplyPoly(GenericGFPoly other);
  external GenericGFPoly multiplyByMonomial(num degree, num coefficient);
  external num evaluateAt(num a);
}
