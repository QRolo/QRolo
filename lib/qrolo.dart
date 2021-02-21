import 'dart:async';
import 'dart:html' as html
    show
        CanvasElement,
        CanvasRenderingContext2D,
        DivElement,
        DomException,
        ImageData,
        MediaRecorder,
        MediaStream,
        VideoElement,
        window;
import 'dart:js_util';
import 'dart:typed_data';
// dart:ui is valid use import platformViewRegistry
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
import 'package:qrolo/src/jsqr.dart' show jsQR;

import 'package:js/js.dart' show JS, anonymous;

const int defaultScanIntervalMilliseconds = 500;

/// The QRolo scanner widget
/// !IMPORTANT: This widget needs to be bound in a sized box or other container
/// Other Flutter throws unbound render flex hit test errors
class QRolo extends StatefulWidget {
  /// clickToCapture to show a button to capture a Data URL for the image
  final bool isCaptureOnTapEnabled;

  const QRolo({this.isCaptureOnTapEnabled = false, Key? key}) : super(key: key);

  @override
  _QRoloState createState() => _QRoloState();

  static const MethodChannel _channel = MethodChannel('qrolo');

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
  }

  static html.DivElement viewDivElement =
      html.DivElement(); // need a global for the registerViewFactory

  static Future<bool> cameraAvailable() async {
    List<dynamic> sources =
        await html.window.navigator.mediaDevices!.enumerateDevices();
    debugPrint('sources:');
    // List<String> vidIds = [];
    bool hasCam = false;
    for (final e in sources) {
      debugPrint(e.toString());
      if (e.kind == 'videoinput') {
        // vidIds.add(e['deviceId']);
        hasCam = true;
      }
    }
    return hasCam;
  }
}

class _QRoloState extends State<QRolo> {
  html.MediaStream? _cameraMediaStream;
  // html.CanvasElement canvas;
  // html.CanvasRenderingContext2D ctx;
  bool _inCalling = false;
  Timer? timer;
  String? _scannedQRCode;
  String? _errorMessage;
  html.VideoElement? videoElMediaCanvasSource;
  String viewID = 'qrolo-view-id';

  @override
  void initState() {
    debugPrint('QRolo init');
    super.initState();
    videoElMediaCanvasSource = html.VideoElement();
    // canvas = new html.CanvasElement(width: );
    // ctx = canvas.context2D;
    QRolo.viewDivElement.children = [videoElMediaCanvasSource!];
    // ignore: UNDEFINED_PREFIXED_NAME
    ui.platformViewRegistry
        .registerViewFactory(viewID, (int id) => QRolo.viewDivElement);
    // initRenderers();
    Timer(Duration(milliseconds: 500), () {
      start();
    });
  }

  void start() async {
    await _makeCall();
    // if (timer == null || !timer.isActive) {
    //   timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    //     if (code != null) {
    //       timer.cancel();
    //       Navigator.pop(context, code);
    //       return;
    //     }
    //     _captureFrame2();
    //     if (code != null) {
    //       timer.cancel();
    //       Navigator.pop(context, code);
    //     }
    //   });
    // }
    if (!widget.isCaptureOnTapEnabled) {
      // instead of periodic, which seems to have some timing issues, going to call timer AFTER the capture.
      Timer(Duration(milliseconds: 200), () {
        _captureFrame2();
      });
    }
  }

  void cancel() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    if (_inCalling) {
      _stopStream();
    }
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    if (_cameraMediaStream != null) {
      return;
    }

    try {
      const Map<String, Map<String, String>> constraintsMap = {
        'video': {
          'facingMode': 'environment',
        },
      };
      /** 
       * ! Warning
       * @deprecated html.window.navigator.getUserMedia() callback vs
       * @see new promise html.window.navigator.mediaDevices?.getUserMedia();
       * 
       * TypeError: Failed to execute 'getUserMedia' on 
       * 'MediaDevices': At least one of audio and video must be
       */
      final mediaDevices = html.window.navigator.mediaDevices;
      final mediaStream = await mediaDevices?.getUserMedia(constraintsMap);
      final stream = mediaStream;

      _cameraMediaStream = stream;
      videoElMediaCanvasSource?.srcObject = _cameraMediaStream;
      videoElMediaCanvasSource?.setAttribute(
        'playsinline',
        'true',
      ); // required to tell iOS safari we don't want fullscreen
      final dynamic? playTest = await videoElMediaCanvasSource?.play();
    } catch (e) {
      debugPrint('error on getUserMedia: ${e.toString()}');
      cancel();
      setState(() {
        _errorMessage = e.toString();
      });
      return;
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    await _stopStream();
    setState(() {
      _inCalling = false;
    });
  }

  Future<void> _stopStream() async {
    try {
      // await _localStream.dispose();
      _cameraMediaStream!.getTracks().forEach((track) {
        if (track.readyState == 'live') {
          track.stop();
        }
      });
      // video.stop();
      videoElMediaCanvasSource?.srcObject = null;
      _cameraMediaStream = null;
      // _localRenderer.srcObject = null;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _toggleCamera() async {
    final videoTrack = _cameraMediaStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    // await videoTrack.switchCamera();
    videoTrack.stop();
    await _makeCall();
  }

  Future<dynamic> _captureFrame2() async {
    if (_cameraMediaStream == null) {
      debugPrint("localstream is null, can't capture frame");
      return null;
    }
    html.CanvasElement canvas = new html.CanvasElement(
        width: videoElMediaCanvasSource?.videoWidth,
        height: videoElMediaCanvasSource?.videoHeight);
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    // canvas.width = video.videoWidth;
    // canvas.height = video.videoHeight;
    ctx.drawImage(videoElMediaCanvasSource!, 0, 0);
    html.ImageData imgData =
        ctx.getImageData(0, 0, canvas.width!, canvas.height!);
    // debugPrint(imgData);
    var code = jsQR(imgData.data, canvas.width!, canvas.height!);
    // debugPrint('CODE: $code');
    if (code != null) {
      debugPrint(code.data);
      this._scannedQRCode = code.data;

      // ! @return for use with showDialog
      // This provides the return value
      popReturnValueForShowDialog(context, code.data);

      return this._scannedQRCode;
    } else {
      Timer(Duration(milliseconds: 500), () {
        _captureFrame2();
      });
    }
  }

  /// Self-descriptive code
  void popReturnValueForShowDialog(BuildContext context, String qrCodeResult) {
    Navigator.pop<String>(context, qrCodeResult);
  }

  Future<String?> _captureImage() async {
    if (_cameraMediaStream == null) {
      debugPrint("localstream is null, can't capture frame");
      return null;
    }
    html.CanvasElement canvas = new html.CanvasElement(
        width: videoElMediaCanvasSource!.videoWidth,
        height: videoElMediaCanvasSource!.videoHeight);
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    // canvas.width = video.videoWidth;
    // canvas.height = video.videoHeight;
    ctx.drawImage(videoElMediaCanvasSource!, 0, 0);
    var dataUrl = canvas.toDataUrl('image/jpeg', 0.9);
    return dataUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_cameraMediaStream == null) {
      return Text('Loading...');
    }
    return Column(children: [
      Expanded(
        child: Container(
            // constraints: BoxConstraints(
            //   maxWidth: 600,
            //   maxHeight: 1000,
            // ),
            child: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                child: HtmlElementView(viewType: viewID),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            );
          },
        )),
      ),
      // IconButton(
      //   icon: Icon(Icons.switch_video),
      //   onPressed: _toggleCamera,
      // ),
      if (widget.isCaptureOnTapEnabled)
        IconButton(
          icon: Icon(Icons.camera),
          onPressed: () async {
            var imgUrl = await _captureImage();
            debugPrint('Image URL: $imgUrl');
            Navigator.pop(context, imgUrl);
          },
        ),
    ]);
  }
}
