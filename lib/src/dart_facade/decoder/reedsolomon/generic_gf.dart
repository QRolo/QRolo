@JS()
library decoder.reedsolomon.generic_gf;

import 'dart:js';

import 'package:js/js.dart';
import 'generic_gf_poly.dart' show GenericGFPoly;

@JS()
external num addOrSubtractGF(num a, num b);

@JS()
class GenericGF {
  external factory GenericGF(
    num primitive,
    num size,
    num genBase,
  );

  // @Ignore
  GenericGF.fakeConstructor$();
  external num get primitive;
  external set primitive(num v);
  external num get size;
  external set size(num v);
  external num get generatorBase;
  external set generatorBase(num v);
  external GenericGFPoly get zero;
  external set zero(GenericGFPoly v);
  external GenericGFPoly get one;
  external set one(GenericGFPoly v);

  /// An array of size `this.size`
  external JsArray<double> get expTable;
  external set expTable(JsArray<double> v);

  /// An array of size `this.size`
  external JsArray<double> get logTable;
  external set logTable(JsArray<double> v);

  external num multiply(num a, num b);
  external num inverse(num a);
  external GenericGFPoly buildMonomial(num degree, num coefficient);
  external num log(num a);
  external num exp(num a);
}
