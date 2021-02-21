import 'dart:async';
import 'dart:html' as html
    show
        CanvasElement,
        CanvasRenderingContext2D,
        DivElement,
        DomException,
        ImageData,
        MediaStream,
        VideoElement,
        window;
import 'dart:js' as js show context;
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
import 'package:qrolo/src/jsqr.dart' show Options, QRCode, jsQR;

const int defaultScanIntervalMilliseconds = 500;

const int _HAVE_ENOUGH_DATA = 4;

/// The QRolo scanner widget
/// !IMPORTANT: This widget needs to be bound in a sized box or other container
/// Other Flutter throws unbound render flex hit test errors
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
  static final html.DivElement divVideo = html.DivElement();

  static Future<bool> isCameraAvailable() async =>
      isCameraAvailableInMediaDevices();
}

class _QRoloState extends State<QRolo> {
  html.MediaStream? _cameraStream;

  // ///
  // /// @example
  // /// "NotFoundError: Requested device not found"
  // /// Indicates error on getUserMedia()
  // String? _errorMessage;
  // String viewFactoryDivViewID = 'qrolo-scanner-view';
  // late html.VideoElement videoElement;

  // final Key _uniqueHtmlWebViewElementKey = UniqueKey();
  // late html.VideoElement _videoElement;
  // late HtmlElementView _videoHtmlElementViewWidget;
  // bool isLoaded = false;
  // html.MediaStream? _videoStream;
  // late html.CanvasElement _canvasElement = html.CanvasElement();
  // late html.CanvasRenderingContext2D _canvasContext;

  html.MediaStream? _cameraVideoStream;
  // html.CanvasElement canvas;
  // html.CanvasRenderingContext2D ctx;
  bool _inCalling = false;
  bool _isTorchOn = false;
  Timer? timer;
  String? code;
  String? _errorMessage;
  var front = false;
  html.VideoElement? videoElement;
  String viewID = "your-view-id";
  // Make hook to exit on first scan found and stop loops.

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (videoElement == null) {
      // Quick in-place loading message
      // Is it better design to expose hooks and let
      // the calling developer supply their own loading widgets?

      return Text('Loading...');
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
                  child: HtmlElementView(viewType: viewID),
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
    print("MY SCANNER initState");
    super.initState();
    html.VideoElement video = html.VideoElement();
    // canvas = new html.CanvasElement(width: );
    // ctx = canvas.context2D;
    QRolo.divVideo.children = [video];
    // ignore: UNDEFINED_PREFIXED_NAME
    ui.platformViewRegistry
        .registerViewFactory(viewID, (int id) => QRolo.divVideo);
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

    // instead of periodic, which seems to have some timing issues, going to call timer AFTER the capture.
    Timer(Duration(milliseconds: 200), () {
      _captureFrame2();
    });
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
    print("Scanner.dispose");
    cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    if (_cameraVideoStream != null) {
      // Already loaded
      return;
    }
    if (videoElement == null) {
      return;
    }

    try {
      // dart style, not working properly:
      // var stream =
      //     await html.window.navigator.mediaDevices.getUserMedia(constraints);
      // straight JS:
      const Map<String, Map<String, String>> constraintsMap = {
        'video': {
          'facingMode': 'environment',
        },
      };
      final html.MediaStream stream =
          await html.window.navigator.mediaDevices!.getUserMedia(
        constraintsMap,
      );

      _cameraVideoStream = stream;
      videoElement!.srcObject = _cameraVideoStream;
      videoElement!.setAttribute('playsinline',
          'true'); // required to tell iOS safari we don't want fullscreen
      final dynamic playTest = await videoElement!.play();

      print('play $playTest');
    } catch (e) {
      print("error on getUserMedia: ${e.toString()}");

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
      _cameraVideoStream!.getTracks().forEach((track) {
        if (track.readyState == 'live') {
          track.stop();
        }
      });
      // video.stop();
      videoElement?.srcObject = null;
      _cameraVideoStream = null;
      // _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _toggleCamera() async {
    final videoTrack = _cameraVideoStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    // await videoTrack.switchCamera();
    videoTrack.stop();
    await _makeCall();
  }

  Future<dynamic> _captureFrame2() async {
    if (_cameraVideoStream == null) {
      print("localstream is null, can't capture frame");
      return null;
    }
    if (videoElement == null) {
      print('video element null');
    }
    html.CanvasElement canvas = new html.CanvasElement(
        width: videoElement!.videoWidth, height: videoElement!.videoHeight);
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    // canvas.width = video.videoWidth;
    // canvas.height = video.videoHeight;
    ctx.drawImage(videoElement!, 0, 0);
    html.ImageData imgData =
        ctx.getImageData(0, 0, canvas.width!, canvas.height!);
    // print(imgData);
    var code = jsQR(imgData.data, canvas.width ?? 0, canvas.height ?? 0);
    // print("CODE: $code");
    if (code != null) {
      print(code.data);
      this.code = code.data;
      Navigator.pop(context, this.code);
      return this.code;
    } else {
      Timer(Duration(milliseconds: 500), () {
        _captureFrame2();
      });
    }
  }

  Future<String?> _captureImage() async {
    if (_cameraVideoStream == null) {
      print("localstream is null, can't capture frame");
      return null;
    }
    if (videoElement == null) {
      return null;
    }
    html.CanvasElement canvas = new html.CanvasElement(
        width: videoElement!.videoWidth, height: videoElement!.videoHeight);
    html.CanvasRenderingContext2D ctx = canvas.context2D;
    // canvas.width = video.videoWidth;
    // canvas.height = video.videoHeight;
    ctx.drawImage(videoElement!, 0, 0);
    var dataUrl = canvas.toDataUrl("image/jpeg", 0.9);
    return dataUrl;
  }

  ////
  ///
  ///
  ///
  ///
//   ///
//   ///
//   ///
//   ///
//   ///
//   ///
//   ///

//   void startStreamVideo() async {
//     const Map<String, Map<String, String>> constraintsMap = {
//       'video': {
//         'facingMode': 'environment',
//       },
//     };
//     final html.MediaStream stream =
//         await html.window.navigator.mediaDevices!.getUserMedia(
//       constraintsMap,
//     );

//     _videoStream = stream;
//     _videoElement.srcObject = _videoStream;
//     _videoElement.setAttribute('playsinline', 'true');
//     /* await */ _videoElement.play();

//     _canvasContext = _canvasElement.context2D;

//     Future.delayed(Duration(milliseconds: 6000), () {
//       tick();
//       setState(() {
//         isLoaded = true;
//       });
//     });
//   }

//   bool _disposed = false;
//   void tick() {
//     print('tick');
//     if (_disposed) {
//       return;
//     }

//     if (_videoElement.readyState == _HAVE_ENOUGH_DATA) {
//       print('test');
//       _canvasElement.width = _videoElement.videoWidth;
//       _canvasElement.height = _videoElement.videoHeight;
//       _canvasContext.drawImage(_videoElement, 0, 0);
//       var imageData = _canvasContext.getImageData(
//         0,
//         0,
//         _canvasElement.width ?? 0,
//         _canvasElement.height ?? 0,
//       );
//       Options opts = Options(inversionAttempts: 'dontInvert');
//       QRCode code = jsQR(
//         imageData.data,
//         imageData.width,
//         imageData.height,
//         opts,
//       );
//       if (code != null) {
//         String value = code.data;
//         // this.widget.qrCodeCallback(value);
//       }
//     }
//     Future.delayed(Duration(milliseconds: 10), () => tick());
//   }

//   /// Methods should not be exposed
//   /// Maybe wrap this into the _web-only implementation as well
//   void startContinuousScanningLoop({
//     int scanIntervalMs = defaultScanIntervalMilliseconds,
//   }) {
//     /*
//       1. Start camera media stream
//         a. If null unable to capture then try again or error feedback dev/user
//       2. Play (add to video element)
//       3. Capture compare qr code (loop)
//     */
//     // - FIXME: Do not need to re-call once the reference is available
//     // Parts of the nested code flow should only be called once then...

//     Timer(
//       Duration(
//         milliseconds: scanIntervalMs,
//       ),
//       () {
//         scanStream();
//       },
//     );
//   }

//   Future<String?> scanStream() async {
//     // 1. Start camera stream and get back
//     final videoStream = await callPlatformOpenMediaVideoStream();

//     if (videoStream == null) {
//       //
//       debugPrint('Error accessing camera stream getUserMedia()');

//       return null;
//     }
//     // Not assigned directly to allow local context null discrimination check
//     // Otherwise technically the _cameraStream could be nulled right before use
//     _cameraStream = videoStream;

//     // 1. a. Present the stream
//     final dynamic? playResult = await startPlayingStream(
//       videoStream,
//       videoElement,
//     );
//     debugPrint(playResult?.toString());

//     // 2. Capture frame from the currently running stream
//     // Current stream reference should be available
//     // Periodically obtain rather than making a call each time
//     // Performance
//     // FP
//     // Assuming width and height data are flutter virtual int pixel size
//     // Otherwise it will mess up qr code data matrix

//     // Use the same video height and width
//     // on virtual canvas and the matrix jsQR check
//     // ASssuming videoElement set up well. No edge null cases
//     final int width = videoElement.videoWidth;
//     final int height = videoElement.videoHeight;

//     final html.ImageData imageData = captureFrameFromStream(videoElement);

//     /*
//     if (imageData == null) {
//       return;
//     }
//     */

//     // 3. Compare frame (calculate QR algo) and get code back
//     final String? qrCode = getQRCodeFromImageDataFrame(
//       imageData,
//       width,
//       height,
//     );

//     if (qrCode == null) {
//       // No QR code from this specific frame

//     }

//     return qrCode;

//     // Catch DOMException
//     // drawImage()
//     //  INDEX_SIZE
//     //  INVALID_STATE
//     //  TYPE_MISMATCH
//     //  NAMESPACE ?? NS_ERROR_NOT_AVAILABLE image not loaded.. .complete .onload
//     //
//     // imageData
//     // INDEX_SIZE
//     // SECURITY
//   }

//   /// Try to get the stream
//   ///
//   /// Assume async platform call will not race against the scan interval
//   /// Configure getUserMedia video stream
//   /// add stream source to our video element with config
//   ///  - playsinline
//   ///  - 'true' non fullscreen
//   ///
//   /// Then finally trigger the HTMLVideoelement.play HTMLMediaElement play()
//   /// Returns rejected promise if playback cannot be started
//   Future<html.MediaStream?> callPlatformOpenMediaVideoStream() async {
//     try {
//       /*
//       final Map<String, Object> exampleVideoConstraintsOptions = {
//         'mandatory': {'minAspectRatio': 1.333, 'maxAspectRatio': 1.334},
//         'optional': [
//           {'minFrameRate': 60},
//           {'maxWidth': 640}
//         ]
//       };
//       */

//       // const Map<String, Map<String, String>> constraintsMap = {
//       //   'video': {
//       //     'facingMode': 'environment',
//       //   },
//       // };
//       // /**
//       //  * ! Warning
//       //  * @deprecated html.window.navigator.getUserMedia() callback vs
//       //  * @see new promise html.window.navigator.mediaDevices?.getUserMedia();
//       //  *
//       //  * TypeError: Failed to execute 'getUserMedia' on
//       //  * 'MediaDevices': At least one of audio and video must be
//       //  */
//       // final mediaDevices = html.window.navigator.mediaDevices;
//       // final mediaStream = await mediaDevices?.getUserMedia(constraintsMap);
//       // final stream = mediaStream;

//       const Map<String, Object> videoConstraints = {
//         'facingMode': 'environment',
//       };

//       final html.MediaStream? mediaStream =
//           // ignore: unnecessary_cast
//           await html.window.navigator.getUserMedia(
//         video: videoConstraints,
//       ) as html.MediaStream?;

//       if (mediaStream == null) {
//         // This should not occur
//         // Should catch DomException rather than return null

//         // // e.g. Error: NotFoundError: Requested device not found
//         // We do not receive the extra error info here
//         // Need to use custom JS interop to expose more error info.
//         // "NotFoundError: Requested device not found"
//         // Indicates error on getUserMedia()
//         const String message = 'No camera access found: '
//             'Please check camera device/permission';

//         _updateErrorMessage(message);

//         return null;
//       }

//       return mediaStream;
//     } on html.DomException catch (domException, stackTrace) {
//       // Code actually breaks out exception rather than returning null

//       _updateErrorMessage(
//         'Unable to access camera stream \n'
//         'Please check camera devices/permissions \n'
//         'DOM Exception ${domException.toString()} ${stackTrace.toString()}',
//       );

//       return null;
//     } on Exception catch (e, stackTrace) {
//       _updateErrorMessage(
//         'Unable to access camera stream getUserMedia(): '
//         'Exception: ${e.toString()} ${stackTrace.toString()}',
//       );

//       return null;
//       // ignore: avoid_catches_without_on_clauses
//     } catch (e, stackTrace) {
//       // This should not occur
//       _updateErrorMessage(
//         'Unable to access camera stream errors: '
//         '${e.toString()} ${stackTrace.toString()}',
//       );

//       return null;
//     }
//   }

//   ///
//   /// Show the captured stream to the user on the page video element src
//   /// Test using https://media-play-promise.glitch.me/
//   /// https://webrtc.github.io/samples/src/video/chrome.mp4
//   /// videoElementToUpdateDirectly.setAttribute(
//   ///   'src',
//   ///   'https://webrtc.github.io/samples/src/video/chrome.mp4',
//   /// );
//   ///
//   /// Error: NotAllowedError: play() failed because the user didn't interact with the document first.
//   /// https://goo.gl/xX8pDD
//   Future<dynamic?> startPlayingStream(
//     html.MediaStream videoStream,
//     html.VideoElement videoElementToUpdateDirectly,
//   ) async {
//     // Mutate
//     // Present the media stream on the HTMLVideoElement
//     videoElementToUpdateDirectly.srcObject = videoStream;

//     // Explicit inline the video within widget.
//     // iOS Safari would expand fullscreen automatically once playback begins.
//     // Check iOS versions
//     // https://webkit.org/blog/6784/new-video-policies-for-ios/
//     videoElementToUpdateDirectly.setAttribute('playsinline', 'true');

//     // Possible returns
//     // NotAllowedError (user agent, OS)
//     // NotSupportedError (an unsupported MediaStream source blob file format)
//     // Automatic vs user press.
//     //
//     // Could be JS undefined?
//     // Example
//     // Error: NotAllowedError: play() failed because the user didn't interact with the document first.
//     // https://goo.gl/xX8pDD
//     final dynamic? playResult = await videoElementToUpdateDirectly.play();

//     return playResult;
//   }

//   /// Draw a virtual canvas to get the image data back..
//   /// videoElement `HTMLVideoElement` can be used as a `CanvasImageSource`
//   /// Use frames being presented by a <video> element
//   /// even if not visible

//   /// Surely there is a quicker version?
//   ///
//   /// Get the image data or matrix from our streaming video element
//   ///
//   /// Important: width and heigth should match across video, image, jsqr data
//   ///
//   /// ? Warning: Unsure if canvas video div element may have been potentially
//   /// mutated by devor dynamic user responsive UI
//   html.ImageData captureFrameFromStream(
//     html.VideoElement videoElement,
//   ) {
//     // Creating a virtual canvas simply to capture imageData?
//     final html.CanvasElement sizedDrawnCanvasContextualisedFrame =
//         createPredrawnCanvasFrameContextFromVideoElement(
//             videoElement: videoElement);

//     // Seems superfluous to do this just to get imageData
//     // Though lots of canvas utility
//     const int topLeftDestXLeft = 0;
//     const int topLeftDestYTop = 0;

//     final html.ImageData imageData =
//         sizedDrawnCanvasContextualisedFrame.context2D.getImageData(
//       topLeftDestXLeft,
//       topLeftDestYTop,
//       videoElement.width,
//       videoElement.height,
//     );

//     /*
//       IndexSizeError
//       SecurityError
//      */
//     return imageData;
//   }

//   /// Utility function
//   /// To reuse for both capture frame image data
//   /// and convert canvas (with context drawn) ito dataURI dataUrl
//   html.CanvasElement createPredrawnCanvasFrameContextFromVideoElement({
//     required html.VideoElement videoElement,
//     int topLeftDestXLeft = 0,
//     int topLeftDestYTop = 0,
//   }) {
//     // Creating a virtual canvas simply to draw + capture imageData?
//     final html.CanvasElement sizedVideoCanvas = html.CanvasElement(
//       width: videoElement.width,
//       height: videoElement.height,
//     );
//     final html.CanvasRenderingContext2D context = sizedVideoCanvas.context2D;

//     // `HTMLVideoElement` can be used as a `CanvasImageSource`
//     // Use frames being presented by a <video> element
//     // even if not visible
//     context.drawImage(
//       videoElement,
//       topLeftDestXLeft,
//       topLeftDestYTop,
//     );

//     return sizedVideoCanvas;
//   }

//   /// API utility for quick saving with the current video
//   /// Blob is faster than dataUrl though
//   ///
//   /// imageDataUrlType
//   ///   - 'image/jpeg'
//   ///   - 'image/png'
//   ///   - 'image/webp'
//   ///
//   /// @returns DOMString
//   String getImageBase64DataUrlFromVideo({
//     required html.VideoElement videoElement,
//     String imageDataUrlType = 'image/jpeg',
//     double qualityDecimalFraction = 0.90,
//     int topLeftDestXLeft = 0,
//     int topLeftDestYTop = 0,
//   }) {
//     final html.CanvasElement frameCanvas =
//         createPredrawnCanvasFrameContextFromVideoElement(
//       videoElement: videoElement,
//     );

//     return frameCanvas.toDataUrl(
//       imageDataUrlType,
//       qualityDecimalFraction,
//     );
//   }

//   /// Single function call
//   /// minimal additional value other than sensible defaults
//   String getImageBase64DataUrlFromCanvas({
//     required html.CanvasElement predrawnVideoFrameCanvas,
//     String imageDataUrlType = 'image/jpeg',
//     double qualityDecimalFraction = 0.90,
//     int topLeftDestXLeft = 0,
//     int topLeftDestYTop = 0,
//   }) {
//     /// `canvas.toDataUrl("image/jpeg", 0.90);`
//     return predrawnVideoFrameCanvas.toDataUrl(
//       imageDataUrlType,
//       qualityDecimalFraction,
//     );
//   }

//   ///
//   /// Assumedly straight 0-255 1D array that is transformed into
//   /// calculation matrix based on width and height
//   ///
//   /// Could ostensibly be used for QR code check of any image data,
//   /// given the right transformation params
//   String? getQRCodeFromData(
//     Uint8ClampedList data,
//     int width,
//     int height,
//   ) {
//     // Use jsQR
//     jsQR(
//       data,
//       width,
//       height,
//     );

//     return null;
//   }

//   /// Helper wrapper
//   /// for compatibility with MediaStream ImageData
//   String? getQRCodeFromImageDataFrame(
//     html.ImageData image,
//     int width,
//     int height,
//   ) {
//     return getQRCodeFromData(
//       image.data,
//       width,
//       height,
//     );
//   }

//   /// Reflect error message in widget state displayed text as well
//   /// Widget conditionally builds depending on error or loading message
//   void _updateErrorMessage(String message) {
//     debugPrint(
//       message,
//     );
//     setState(() {
//       _errorMessage = message;
//     });
//   }
// }

}
