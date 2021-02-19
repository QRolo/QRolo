@JS()
library decoder.reedsolomon.GenericGF;

import 'package:js/js.dart';
import 'GenericGFPoly.dart' show GenericGFPoly;

@JS()
external num addOrSubtractGF(num a, num b);

@JS()
class GenericGF {
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
  external get expTable;
  external set expTable(v);
  external get logTable;
  external set logTable(v);
  external factory GenericGF(num primitive, num size, num genBase);
  external num multiply(num a, num b);
  external num inverse(num a);
  external GenericGFPoly buildMonomial(num degree, num coefficient);
  external num log(num a);
  external num exp(num a);
}
