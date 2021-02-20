@JS()
library decoder.reedsolomon.generic_gf_poly;

import 'dart:js';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'GenericGF.dart' show GenericGF;

@JS()
class GenericGFPoly {
  external factory GenericGFPoly(
    GenericGF field,
    Uint8ClampedList coefficients,
  );
  // @Ignore
  GenericGFPoly.fakeConstructor$();
  external dynamic get field;
  external set field(dynamic v);

  // external JsArray<dynamic> get coefficients; UInt8ClampedArray for zero one
  external JsArray<double> get coefficients;
  external set coefficients(JsArray<double> v);

  external double degree();
  external bool isZero();
  external double getCoefficient(double degree);
  external GenericGFPoly addOrSubtract(GenericGFPoly other);
  external GenericGFPoly multiply(double scalar);
  external GenericGFPoly multiplyPoly(GenericGFPoly other);
  external GenericGFPoly multiplyByMonomial(double degree, double coefficient);
  external double evaluateAt(double a);
}
