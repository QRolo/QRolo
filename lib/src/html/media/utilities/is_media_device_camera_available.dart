import 'dart:html' as html show window, MediaDeviceInfo;

import 'package:flutter/material.dart';

/// Check media devices within current window / iframe
Future<bool> isCameraAvailableInMediaDevices() async {
  final List<html.MediaDeviceInfo> mediaDeviceInfos =
      await html.window.navigator.mediaDevices!.enumerateDevices()
          as List<html.MediaDeviceInfo>;

  debugPrint(
    'sources: ${mediaDeviceInfos.toString()}',
  );

  final bool isCameraFound = isVideoInputWithin(mediaDeviceInfos);

  return isCameraFound;
}

/// Is a camera (videoinput) media device found within the given media device
/// information list
///
bool isVideoInputWithin(List<html.MediaDeviceInfo> mediaDeviceInfos) {
  final bool isVideoInputFound = mediaDeviceInfos.any(
    (mediaDeviceInfo) => mediaDeviceInfo.kind == 'videoinput',
  );

  return isVideoInputFound;
}