@JS()
library decoder.reedsolomon;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
external Uint8ClampedList /* Uint8ClampedArray */ decode(
  List<num> bytes,
  num twoS,
);
