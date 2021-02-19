@JS()
library decoder.decodeData.BitStream;

import 'package:js/js.dart';

@JS()
class BitStream {
  // @Ignore
  BitStream.fakeConstructor$();
  external get bytes;
  external set bytes(v);
  external get byteOffset;
  external set byteOffset(v);
  external get bitOffset;
  external set bitOffset(v);
  external factory BitStream(Uint8ClampedArray bytes);
  external num readBits(num numBits);
  external num available();
}
