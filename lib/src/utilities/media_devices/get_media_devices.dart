import 'dart:html' as html show window, MediaDeviceInfo, MediaDevices;

import 'package:flutter/material.dart';

/// Get list of video input devices (or empty list)
///
/// SHould hopefully not produce js errors outside 1st-party dart realm of control
Future<List<html.MediaDeviceInfo>> getVideoInputDevices() async {
  const List<html.MediaDeviceInfo> defaultNoCamerasEmptyList =
      <html.MediaDeviceInfo>[];
  final Future<List<html.MediaDeviceInfo>> defaultEmptyFuture =
      Future.sync(() => defaultNoCamerasEmptyList);

  try {
    final html.MediaDevices? mediaDevices = html.window.navigator.mediaDevices;

    if (mediaDevices == null) {
      return defaultEmptyFuture;
    }

    final Future<List<dynamic>> devices = mediaDevices.enumerateDevices();
    final Future<List<html.MediaDeviceInfo>> videoInputs = devices.then(
      (List<dynamic> value) => value
          .cast<html.MediaDeviceInfo>()
          .where(isVideoInputMediaDevice)
          .toList(),
    );

    return videoInputs;
  } on Exception catch (err) {
    // Catch-all
    debugPrint('Error querying media devices $err');
    return defaultEmptyFuture;
  }
}

bool isVideoInputMediaDevice(html.MediaDeviceInfo device) =>
    device.kind == 'videoinput';
