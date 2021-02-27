import 'dart:async';
import 'dart:html' as html
    show window, MediaDeviceInfo, MediaDevices, Navigator;

import 'package:flutter/material.dart';

const List<html.MediaDeviceInfo> _defaultNoCamerasEmptyList =
    <html.MediaDeviceInfo>[];
final Future<List<html.MediaDeviceInfo>> _defaultEmptyFuture =
    Future.sync(() => _defaultNoCamerasEmptyList);

/// Sanitise empty list
/// InputDeviceInfo or MediaDeviceInfo list.
Future<List<dynamic>> getMediaDeviceInfosOrInputDeviceInfos() {
  try {
    final html.Navigator navigator = html.window.navigator;
    final html.MediaDevices? mediaDevices = navigator.mediaDevices;

    if (mediaDevices == null) {
      return _defaultEmptyFuture;
    }

    final Future<List<dynamic>> devices = mediaDevices.enumerateDevices();

    return devices;
  } on Exception catch (err) {
    debugPrint('Error querying media devices $err');

    return _defaultEmptyFuture;
  }
}

/// Get list of video input devices (or empty list)
///
/// SHould hopefully not produce js errors outside 1st-party dart realm of control
Future<List<html.MediaDeviceInfo>> getVideoInputDevices() async {
  try {
    // InputDeviceInfo or MediaDeviceInfo list.
    final Future<List<dynamic>> devices =
        getMediaDeviceInfosOrInputDeviceInfos();

    // Warning not sure the error context when mixing up .then
    final Future<List<html.MediaDeviceInfo>> videoInputs = devices
        .then(
          (List<dynamic> value) => value
              .cast<html.MediaDeviceInfo>()
              .where(isVideoInputMediaDevice)
              .toList(),
        )
        .onError(
          _handleAsyncVideoInputQueryError,
        );

    return videoInputs;
  } on Exception catch (err) {
    // Catch-all
    debugPrint('Error querying media devices $err');
    return _defaultEmptyFuture;
  }
}

FutureOr<List<html.MediaDeviceInfo>> _handleAsyncVideoInputQueryError(
  Object? err,
  StackTrace _stackTrace,
) {
  debugPrint('Async error querying media devices $err');

  err == null ? throw 'Media query error' : throw err;
}

bool isVideoInputMediaDevice(html.MediaDeviceInfo device) =>
    device.kind == 'videoinput';
