@JS()
library decoder_decode_data;

import 'dart:js';

import 'package:js/js.dart';

// enum Mode { numeric, alphanumeric, byte, kanji, eci }

// extension ParseToString on Mode {
//   String toShortString() {
//     return toString().split('.').last;
//   }
// }

class Mode {
  // ignore: constant_identifier_names
  static const String Numeric = 'numeric';
  // ignore: constant_identifier_names
  static const String Alphanumeric = 'alphanumeric';
  // ignore: constant_identifier_names
  static const String Byte = 'byte';
  // ignore: constant_identifier_names
  static const String Kanji = 'kanji';
  // ignore: constant_identifier_names
  static const String ECI = 'eci';
}

@anonymous
@JS()
abstract class Chunk extends BaseChunk {
  @override
  external String /* Mode */ get type;
  @override
  external set type(String v);
  external String get text;
  external set text(String v);
  external factory Chunk({
    Mode type,
    String text,
  });
}

///
/// "byte" or "kanji" mode
@anonymous
@JS()
abstract class ByteChunk extends BaseChunk {
  @override
  external String /*Mode.Byte|Mode.Kanji*/ get type;
  @override
  external set type(dynamic /*Mode.Byte|Mode.Kanji*/ v);
  external List<num> get bytes;
  external set bytes(List<num> v);
  external factory ByteChunk({
    dynamic /*Mode.Byte|Mode.Kanji*/ type,
    List<num> bytes,
  });
}

@anonymous
@JS()
abstract class ECIChunk extends BaseChunk {
  @override
  external String get type;
  @override
  external set type(String /* "eci" */ v);
  external num get assignmentNumber;
  external set assignmentNumber(num v);
  external factory ECIChunk({
    String /* Mode.ECI */ type,
    num assignmentNumber,
  });
}

/*export declare type Chunks = Array<Chunk | ByteChunk | ECIChunk>;*/
/// Custom
@anonymous
@JS()
abstract class BaseChunk {
  external String /* Mode */ get type;
  external set type(String /* Mode */ v);
}

/// type alias type def workaround
// ignore: avoid_implementing_value_types
abstract class Chunks implements JsArray<BaseChunk> {}

@anonymous
@JS()
abstract class DecodedQR {
  external String get text;
  external set text(String v);
  external List<num> get bytes;
  external set bytes(List<num> v);
  external JsArray<dynamic /*Chunk|ByteChunk|ECIChunk*/ > get chunks;
  external set chunks(JsArray<dynamic /*Chunk|ByteChunk|ECIChunk*/ > v);
  external factory DecodedQR({
    String text,
    List<num> bytes,
    JsArray<dynamic /*Chunk|ByteChunk|ECIChunk*/ > chunks,
  });
}
