@JS()
library decoder.decode_data.bit_stream;

import 'dart:typed_data' show Uint8ClampedList;

import 'package:js/js.dart' show JS;

@JS()
class BitStream {
  external factory BitStream(
    Uint8ClampedList bytes,
  );
  // @Ignore
  BitStream.fakeConstructor$();

  external int get bytes;
  external set bytes(int v);

  /// Wow these were private fields with an any type
  /// Guess they did not think it was important for private fields
  /// Even though the js source seems to learly use this as int
  /// e.g. 0 offset or 8 bit offset balance between byte offset
  external int get byteOffset;
  external set byteOffset(int v);
  external int get bitOffset;
  external set bitOffset(int v);
  external int readBits(int numBits);
  external int available();
}
