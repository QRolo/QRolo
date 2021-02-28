import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrolo/qrolo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String? scannedQRCode;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await QRolo.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion ?? 'no-version-found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyHomePage(
      title: 'QRolo QR scanner app porject',
    ));
  }

  void testAlert(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Test"),
      content: Text("Done..!"),
    );

    showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  String? scannedQRCode;
  int _counter = 0;
  String? code;
  // Future<List<dynamic>> sourcesF;
  Future<bool> camAvailableF = QRolo.isCameraAvailable();
  // html.ImageElement img;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await QRolo.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    } on Exception catch (err) {
      platformVersion = err.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion ?? 'Unknown';
    });
  }

  void testAlert(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Test"),
      content: Text("Done..!"),
    );

    showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _openScan(BuildContext context) async {
    final code = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        // var height = MediaQuery.of(context).size.height;
        // var width = MediaQuery.of(context).size.width;
        return AlertDialog(
          insetPadding: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: const Text('Scan QR Code'),
          content: Container(
            width: 640,
            height: 480,
            child: QRolo(),
          ),
        );
      },
    );

    print("CODE: $code");
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      scannedQRCode = code;
    });
  }

  // void _openScan() async {
  //   var code = await showDialog<String?>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         // var height = MediaQuery.of(context).size.height;
  //         // var width = MediaQuery.of(context).size.width;
  //         return AlertDialog(
  //           insetPadding: EdgeInsets.all(5),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10.0))),
  //           title: const Text('Scan QR Code'),
  //           content: Container(
  //               // height: height - 20,
  //               width: 640,
  //               height: 480,
  //               child: QRolo()),
  //         );
  //       });
  //   print("CODE: $code");
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     this.code = code;
  //     _counter++;
  //   });
  // }

  void _captureImage() async {
    var dataUrl = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          // var height = MediaQuery.of(context).size.height;
          // var width = MediaQuery.of(context).size.width;
          return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: const Text('Scan QR Code'),
            content: Container(
                // height: height - 20,
                width: 640,
                height: 480,
                child: QRolo(
                  isCaptureOnTapEnabled: true,
                )),
          );
        });
    print("IMG URL: $dataUrl");
    // html.DivElement vidDiv =
    //     html.DivElement(); // need a global for the registerViewFactory

    // // ignore: UNDEFINED_PREFIXED_NAME
    // ui.platformViewRegistry.registerViewFactory("cap", (int id) => vidDiv);

    // img = new html.ImageElement();
    // img.src = dataUrl;
    // vidDiv.children = [img];
    // html.document.body.children.add(img);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // this.code = code;
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRolo QR code scanner plugin example app'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Running on: $_platformVersion\n'),
          ),
          SizedBox(height: 10),
          // ! FIXME: Need FutureBuilder for the popup to work
          ElevatedButton(
            child: Text("Scan QR Code"),
            onPressed: () {
              _openScan(context);
            },
          ),
          SizedBox(
            width: 640,
            height: 480,

            /// !IMPORTANT: This widget needs to be bound in a sized box or other container
            /// Other Flutter throws unbound render flex hit test errors
          ),
          RaisedButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              testAlert(context);
            },
            child: Text("PressMe"),
          ),
        ],
      ),
    );
  }
}

//
//

///
///
///
///

/* 
final Widget templateWidget = Scaffold(
  appBar: AppBar(
    title: Text(widget.title),
  ),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FutureBuilder<bool>(
          future: camAvailableF,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("ERROR: ${snapshot.error}");
            }
            if (snapshot.hasData) {
              if (snapshot.data) {
                return (Text("Camera is available"));
              }
              return (Text("No camera available"));
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          '$code',
          style: Theme.of(context).textTheme.headline4,
        ),
        // FutureBuilder<List<dynamic>>(
        //   future: sourcesF,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return Text("ERROR: ${snapshot.error}");
        //     }
        //     if (snapshot.hasData) {
        //       List<Widget> children = [];
        //       for (final e in snapshot.data) {
        //         children.add(Text(e.toString()));
        //       }
        //       return Center(child: Column(children: children));
        //     } else {
        //       // We can show the loading view until the data comes back.
        //       return CircularProgressIndicator();
        //     }
        //   },
        // )
        SizedBox(height: 10),
        RaisedButton(
          child: Text("Scan QR Code"),
          onPressed: _openScan,
        ),
        SizedBox(height: 10),
        RaisedButton(
          child: Text("Capture Image"),
          onPressed: _captureImage,
        ),
        SizedBox(height: 10),
        if (img != null)
          SizedBox(
            width: 640,
            height: 480,
            child: HtmlElementView(viewType: "cap"),
          ),
      ],
    ),
  ),
  // floatingActionButton: FloatingActionButton(
  //   onPressed: _openScan,
  //   tooltip: 'Scan',
  //   child: Icon(Icons.camera_alt),
  // ),
);
 */
