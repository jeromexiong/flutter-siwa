import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:siwa/siwa.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  SignInWithAppleController _controller;
  String authInfo;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _controller.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    try {
                      // final msg = await _controller.signInWithApple;
                      // print(msg);
                    } on PlatformException {
                      print("Failed to get platform version.");
                    }
                  },
                  child: Text('Running on: $_platformVersion\n'),
                ),
                SizedBox(
                    width: 240,
                    height: 50,
                    //调用自定义Button
                    child: SignInWithApple(
                      onCreated: (controller) {
                        _controller = controller;
                        _controller.click = (methodCall) {
                          print("main---$methodCall");
                          authInfo = methodCall.toString();
                          setState(() {});
                        };
                        initPlatformState();
                      },
                    )),
                authInfo != null ? Text('authInfo: $authInfo\n') : Container(),
              ],
            ),
          )),
    );
  }
}
