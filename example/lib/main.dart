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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QRolo QR code scanner plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text("Scan QR Code"),
              onPressed: () {
                _openScan(context);
              },
            ),
            Container(
              width: 640,
              height: 480,

              /// !IMPORTANT: This widget needs to be bound in a sized box or other container
              /// Other Flutter throws unbound render flex hit test errors
              child: QRolo(),
            ),
          ],
        ),
      ),
    );
  }

  void _openScan(BuildContext context) async {
    final code = await showDialog(
      context: navigatorKey.currentState!.overlay!.context,
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
      this.scannedQRCode = code;
    });
  }
}
