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
<<<<<<< HEAD
            QRolo()
=======
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
            SizedBox(height: 640, width: 480)
>>>>>>> 3658869 (feat(example,-qrolo.dart): add sized box back to fix error render flex unbound hit test flutter)
          ],
        ),
      ),
    );
  }
}
