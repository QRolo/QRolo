@JS()
library decoder.version;

import 'dart:js';

import 'package:js/js.dart';

@anonymous
@JS()
abstract class Version {
  external num get infoBits;
  external set infoBits(num v);
  external num get versionNumber;
  external set versionNumber(num v);
  external List<num> get alignmentPatternCenters;
  external set alignmentPatternCenters(List<num> v);
  external JsArray<
      dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
      > get errorCorrectionLevels;
  external set errorCorrectionLevels(
    JsArray<
            dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
            >
        v,
  );
  external factory Version({
    num infoBits,
    num versionNumber,
    List<num> alignmentPatternCenters,
    JsArray<
            dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
            >
        errorCorrectionLevels,
  });
}

@JS()
// ignore: non_constant_identifier_names
external List<Version> get VERSIONS;
