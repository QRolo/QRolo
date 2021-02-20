import 'dart:async';
import 'dart:html' as html show DivElement, window, MediaDeviceInfo;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: avoid_classes_with_only_static_members
class QRolo extends StatefulWidget {
  @override
  _QRoloState createState() => _QRoloState();

  static const MethodChannel _channel = MethodChannel('qrolo');

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');

    return version;
  }

  /// Whether to show the camera button overlaid on scanner video stream view
  ///
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
  static html.DivElement videoDiv = html.DivElement();

  static Future<bool> isCameraAvailable() async {
    final List<html.MediaDeviceInfo> mediaDeviceInfos =
        await html.window.navigator.mediaDevices!.enumerateDevices()
            as List<html.MediaDeviceInfo>;

    debugPrint(
      'sources: ${mediaDeviceInfos.toString()}',
    );

    final bool isVideoInputFound = mediaDeviceInfos.any(
      (mediaDeviceInfo) => mediaDeviceInfo.kind == 'videoinput',
    );

    return isVideoInputFound;
  }
}

class _QRoloState extends State<QRolo> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
