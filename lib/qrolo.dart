import 'dart:async';

import 'package:flutter/services.dart';

class Qrolo {
  static const MethodChannel _channel = const MethodChannel('qrolo');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
