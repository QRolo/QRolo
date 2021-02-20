import 'dart:async';
import 'dart:html' as html show DivElement, MediaStream, VideoElement;

// https://github.com/flutter/flutter/issues/41563
// Alternative use universal_ui wrapper
// ignore: unused_import
import 'dart:ui' as ui
    show
        // ignore: undefined_shown_name
        platformViewRegistry;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:qrolo/src/html/media/utilities/is_media_device_camera_available.dart'
    show isCameraAvailableInMediaDevices;
import 'package:qrolo/src/jsqr.dart';

const int DEFAULT_SCAN_INTERVAL_MILLISECONDS = 500;

/// The QRolo scanner widget
class QRolo extends StatefulWidget {
  @override
  _QRoloState createState() => _QRoloState();

  static const MethodChannel _channel = MethodChannel('qrolo');

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');

    return version;
  }

  /// Whether to show the camera button overlaid on scanner video stream view
  /// Maybe this should be split into two separate widgets for fulfilling
  /// Two distinct purposes
  ///
  /// clean code distinct paths
  ///
  /// Or root-level bool toggle with discrete discriminated widget builder fns
  final bool isClickToCaptureEnabled;

  const QRolo({
    Key? key,
    this.isClickToCaptureEnabled = false,
  }) : super(key: key);

  /// Utility to reference the html div to add a video element to
  /// the children of div element
  ///
  /// ?
  /// need a global for the registerViewFactory
  /// when initialising state initState
  /// ui.platformViewRegistry.registerViewFactory
  static final html.DivElement videoDiv = html.DivElement();

  static Future<bool> isCameraAvailable() async =>
      isCameraAvailableInMediaDevices();
}

class _QRoloState extends State<QRolo> {
  html.MediaStream? _cameraStream;
  String? _errorMessage;
  String viewFactoryDivViewID = 'qrolo-scanner-view';
  late html.VideoElement videoElement;
  // Make hook to exit on first scan found and stop loops.

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_cameraStream == null) {
      // Quick in-place loading message
      // Is it better design to expose hooks and let
      // the calling developer supply their own loading widgets?

      return const Text('Loading...');
    }

    return Column(
      children: [
        Expanded(
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(0),
                  decoration: const BoxDecoration(color: Colors.black54),
                  child: HtmlElementView(
                    viewType: viewFactoryDivViewID,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint('QRolo scanner init');

    // Create new VideoElement and add to view factory div
    videoElement = html.VideoElement();
    QRolo.videoDiv.children = [videoElement];

    // This is valid usage on build
    // Dev analyzer has not been updated to accept this yet.
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewFactoryDivViewID,
      (int id) => QRolo.videoDiv,
    );

    startContinuousScanningLoop();
  }

  /// Methods should not be exposed
  /// Maybe wrap this into the _web-only implementation as well
  void startContinuousScanningLoop({
    int scanIntervalMs = DEFAULT_SCAN_INTERVAL_MILLISECONDS,
  }) {
    /*
      1. Start camera media stream
        a. If null unable to capture then try again or error feedback dev/user
      2. Play (add to video element)
      3. Capture compare qr code (loop)
    */
    // - FIXME: Do not need to re-call once the reference is available
    // Parts of the nested code flow should only be called once then...

    Timer(
      Duration(
        milliseconds: scanIntervalMs,
      ),
      () {
        scanStream();
      },
    );
  }

  Future<void> scanStream() async {
    // 1. Start camera stream
    await callPlatformOpenMediaVideoStream();

    // 2. Capture frame from the currently running stream
    // Current stream reference should be available
    // Periodically obtain rather than making a call each time
    // Performance
    // FP

    // 3. Compare frame and get code back

    return;
  }

  /// Assume async platform call will not race against the scan interval
  /// Configure getUserMedia video stream
  /// add stream source to our video element with config
  ///  - playsinline
  ///  - 'true' non fullscreen
  ///
  /// Then finally trigger the HTMLVideoelement.play HTMLMediaElement play()
  /// Returns rejected promise if playback cannot be started
  Future<html.MediaStream?> callPlatformOpenMediaVideoStream() async {
    return null;
  }
}
