import 'dart:async';
import 'dart:html' as html
    show
        CanvasElement,
        CanvasRenderingContext2D,
        DivElement,
        DomException,
        ImageData,
        MediaDevices,
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

    return version;
  }

  // need a global for the registerViewFactory
  static html.DivElement viewDivElement = html.DivElement();

  /// Utility to help only allow the camera widget when available
  static Future<bool> isCameraAvailable() async {
    return isCameraAvailableInMediaDevices();
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
    ui.platformViewRegistry.registerViewFactory(
      viewID,
      (int id) => QRolo.viewDivElement,
    );
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
      try {
        final mediaDevices = html.window.navigator.mediaDevices;
      } catch (e) {
        debugPrint('BIG ERROR e.toString()');

        return;
      }
      final mediaDevices = html.window.navigator.mediaDevices;

      if (mediaDevices == null) {
        return;
      }
      try {
        final html.MediaStream deviceStream =
            await (mediaDevices.getUserMedia(constraintsMap)).onError(
          (html.DomException error, stackTrace) {
            // Paused on promise rejection
            // Error: Expected a value of type 'DomException', but got one of type 'TypeErrorImpl'
            /* 
            error: DOMException: Permission denied
            code: 0
            message: "Permission denied"
            name: "NotAllowedError"
            */
            // Poor practice to use errors to control logic flow. goto.
            // Use return if you want the error to be caught inside catchError()
            // Use throw if you want the error to be caught inside try/catch.

            // Uncaught (in promise) Error: Expected a value of type 'FutureOr<MediaStream$>',
            // but got one of type 'Null'

            // We really should not use errors for logic flow..
            // https://github.com/dart-lang/sdk/issues/44386

            // throw 'Throw crazy error!';
            // throw 'Help';
            throw error;
          },
        );

        _cameraMediaStream = deviceStream;
      } catch (err) {
        // Catch-all
        // NotAllowedError: Permission denied
        debugPrint('Unable to access camera stream: ${err.toString()}');
        return;
      }

      final html.MediaStream? mediaStream = _cameraMediaStream;
      if (mediaStream == null) {
        return;
      }

      // if (mediaStream is html.MediaStream) {}
      final html.MediaStream stream = mediaStream as html.MediaStream;
      // Retrieve stream even if permissions blocked and active: false

      if (stream == null) {
        return;
      }

      videoElMediaCanvasSource?.srcObject = _cameraMediaStream;
      // Explicit inline the video within widget.
      // iOS Safari would expand fullscreen automatically once playback begins.
      // Check iOS versions
      // https://webkit.org/blog/6784/new-video-policies-for-ios/
      videoElMediaCanvasSource?.setAttribute(
        'playsinline',
        'true',
      );

      if (videoElMediaCanvasSource == null) {
        return;
      }

      try {
        final dynamic? playTest =
            await videoElMediaCanvasSource!.play().catchError((dynamic err) {
          try {
            // Error: NotAllowedError: play() failed because the user didn't interact with the document first.
            debugPrint(err.toString());
          } catch (reject) {
            debugPrint(reject.toString());
          }
        });
      } catch (ex) {
        debugPrint(ex.toString());
      }
    } on Exception catch (e) {
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

  void castHandleMediaDomException(dynamic domExceptionDynamic) {
    // But can strangely assert type anyway, maybe some promise interop bug

    final html.DomException a = domExceptionDynamic as html.DomException;
    debugPrint('DOM Exception name: ${a.name}, message: ${a.message}');

    // Uncaught (in promise) Error: Expected a value of type '(Object) => dynamic', but got one of type '((Object) => dynamic) => Null'
    // Future<Null>
    /* 
      **This is not a html.DomException**
      code: 8
      message: "Requested device not found"
      name: "NotFoundError"
    
      DOMException.NOT_FOUND_ERR: 8
    */

    //  DOMException: Requested device not found
    // Error: NotFoundError: Requested device not found
    debugPrint('Error caught: $domExceptionDynamic');
    _updateErrorMessage(
      'Unable to access camera stream \n'
      'Please check camera devices/permissions \n'
      'DOM Exception ${domExceptionDynamic.toString()}',
    );
  }

  /// Reflect error message in widget state displayed text as well
  /// Widget conditionally builds depending on error or loading message
  void _updateErrorMessage(String message) {
    debugPrint(
      message,
    );
    setState(() {
      _errorMessage = message;
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

    html.ImageData? imgData = await Future.sync(() {
      return ctx.getImageData(0, 0, canvas.width!, canvas.height!);
    }).catchError((dynamic domExceptionSourceZero) {
      // DOMException: Failed to execute 'getImageData' on 'CanvasRenderingContext2D': The source width is 0.
      debugPrint(domExceptionSourceZero.toString());
      // Placeholder to avoid NullError ... ... badness
      // Even though it should accept null when using optional return

      // DOMException: Failed to construct 'ImageData': The source width is zero or not a number.
      return html.ImageData(1, 1);
    } as FutureOr<html.ImageData?> Function(dynamic err));

    if (imgData.height <= 1) {
      // This should be null but we had to use a placeholder on Dart beta.
      return;
    }
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

///
///
///
///

/// Example html on valid usage. <div> <video></video> </div>
/// <flt-glass-pane style="position: absolute; inset: 0px; cursor: default"
///   ><flt-semantics-placeholder
///     role="button"
///     aria-live="true"
///     tabindex="0"
///     aria-label="Enable accessibility"
///     style="position: absolute; left: -1px; top: -1px; width: 1px; height: 1px"
///   ></flt-semantics-placeholder
///   ><flt-scene-host aria-hidden="true" style="pointer-events: none"
///     ><flt-scene
///       ><flt-canvas-container
///         ><canvas
///           width="1680"
///           height="2196"
///           style="position: absolute; width: 840px; height: 1098px"
///         ></canvas
///       ></flt-canvas-container>
///       <div
///         style="
///           width: 640px;
///           height: 480px;
///           position: absolute;
///           pointer-events: auto;
///           transform-origin: 0px 0px 0px;
///           transform: matrix(1, 0, 0, 1, 100, 126);
///           opacity: 1;
///         "
///       >
///         <video playsinline="true"></video>
///       </div>
///       <flt-canvas-container
///         ><canvas
///           width="1680"
///           height="2196"
///           style="position: absolute; width: 840px; height: 1098px"
///         ></canvas></flt-canvas-container></flt-scene></flt-scene-host
/// ></flt-glass-pane>
