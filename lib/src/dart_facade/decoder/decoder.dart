@JS()
library decoder.decoder;

import 'package:js/js.dart';
import '../BitMatrix.dart' show BitMatrix;

@JS()
external DecodedQR decode(BitMatrix matrix);
