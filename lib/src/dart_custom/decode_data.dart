
@JS()
library node_modules.jsqr.dist.decoder.decodeData;

import 'package:js/js.dart';





enum Mode { numeric, alphanumeric, byte, kanji, eci }

class {
  static const String Numeric = 'numeric';
}
extension ParseToString on Mode {
  String toShortString() {
    return toString().split('.').last;
  }
}


@anonymous
@JS()
abstract class Chunk {
  external Mode get type;
  external set type(Mode v);
  external String get text;
  external set text(String v);
  external factory Chunk({Mode type, String text});
}

@anonymous
@JS()
abstract class ByteChunk {
  external dynamic /*Mode.Byte|Mode.Kanji*/ get type;
  external set type(dynamic /*Mode.Byte|Mode.Kanji*/ v);
  external List<num> get bytes;
  external set bytes(List<num> v);
  external factory ByteChunk(
      {dynamic /*Mode.Byte|Mode.Kanji*/ type, List<num> bytes});
}

@anonymous
@JS()
abstract class ECIChunk {
  external Mode.ECI get type;
  external set type(Mode.ECI v);
  external num get assignmentNumber;
  external set assignmentNumber(num v);
  external factory ECIChunk({Mode.ECI type, num assignmentNumber});
}

/*export declare type Chunks = Array<Chunk | ByteChunk | ECIChunk>;*/
@anonymous
@JS()
abstract class DecodedQR {
  external String get text;
  external set text(String v);
  external List<num> get bytes;
  external set bytes(List<num> v);
  external Array<dynamic /*Chunk|ByteChunk|ECIChunk*/ > get chunks;
  external set chunks(Array<dynamic /*Chunk|ByteChunk|ECIChunk*/ > v);
  external factory DecodedQR(
      {String text,
      List<num> bytes,
      Array<dynamic /*Chunk|ByteChunk|ECIChunk*/ > chunks});
}

