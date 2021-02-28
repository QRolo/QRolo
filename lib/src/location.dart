import 'package:qrolo/src/dart_facade/locator.dart';

/// Location within the QR code fields ?
/// See inversion patterns locator
abstract class Location {
  Point topRightCorner;
  Point topLeftCorner;
  Point bottomRightCorner;
  Point bottomLeftCorner;
  Point topRightFinderPattern;
  Point topLeftFinderPattern;
  Point bottomLeftFinderPattern;
  Point? bottomRightAlignmentPattern;

  Location(
    this.topRightCorner,
    this.topLeftCorner,
    this.bottomRightCorner,
    this.bottomLeftCorner,
    this.topRightFinderPattern,
    this.topLeftFinderPattern,
    this.bottomLeftFinderPattern,
    this.bottomRightAlignmentPattern,
  );
}
