import 'dart:html' as html show window, MediaDeviceInfo;

import 'package:flutter/material.dart';
import 'package:qrolo/src/html/media/media_devices/get_media_devices.dart';

/// Check media devices within current window / iframe
///
/// Camera and microphone is actually `InputDeviceInfo`
Future<bool> isCameraAvailableInMediaDevices() async {
  final mediaDevicesGenerated = await getMediaDeviceInfosOrInputDeviceInfos();

  // InputDeviceInfo or MediaDeviceInfo
  final List<html.MediaDeviceInfo> mediaDeviceInfos =
      mediaDevicesGenerated.cast<html.MediaDeviceInfo>();
  // Camera and microphone is actually `InputDeviceInfo`
  final List<html.MediaDeviceInfo> cameras = await getVideoInputDevices();

  debugPrint(
    'media sources: ${mediaDeviceInfos.toString()}',
  );
  debugPrint('video sources: $cameras');

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
