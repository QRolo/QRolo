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
  }
}
