@JS()
library decoder.reedsolomon;

import 'package:js/js.dart';

@JS()
external Uint8ClampedArray decode(List<num> bytes, num twoS);
