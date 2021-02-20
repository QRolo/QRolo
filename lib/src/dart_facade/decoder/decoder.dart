@JS()
library decoder.decoder;

import 'package:js/js.dart';
import 'package:qrolo/src/dart_facade/decoder/decode_data.dart';
import 'package:qrolo/src/dart_facade/bit_matrix.dart' show BitMatrix;

@JS()
external DecodedQR decode(BitMatrix matrix);
