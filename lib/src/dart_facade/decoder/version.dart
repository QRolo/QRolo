@JS()
library decoder.version;

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
  external Array<
      dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
      > get errorCorrectionLevels;
  external set errorCorrectionLevels(
      Array<
              dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
              >
          v);
  external factory Version(
      {num infoBits,
      num versionNumber,
      List<num> alignmentPatternCenters,
      Array<
              dynamic /*{
        ecCodewordsPerBlock: number;
        ecBlocks: Array<{
            numBlocks: number;
            dataCodewordsPerBlock: number;
        }>;
    }*/
              >
          errorCorrectionLevels});
}

@JS()
external List<Version> get VERSIONS;
