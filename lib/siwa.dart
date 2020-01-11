import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// class Siwa {
//   static Siwa _instance;
//   static get instance => getInstance();
//   static getInstance() {
//     if (_instance == null) {
//       _instance = new Siwa._();
//     }
//     return _instance;
//   }

//   static MethodChannel _channel;
//   Siwa._() {
//     _channel = const MethodChannel('cc.dync/siwa')
//       ..setMethodCallHandler(_handler);
//   }

//   Future<dynamic> _handler(MethodCall methodCall) {
//     print(methodCall);
//     return Future.value(true);
//   }

//   Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }

//   Future<String> get signInWithApple async {
//     final siwa = await _channel.invokeMethod('SignInWithApple');
//     print(siwa);
//     return siwa;
//   }
// }

const String viewType = "plugins/siwa";
class SignInWithApple extends StatefulWidget {
  SignInWithApple({Key key, this.onCreated}) : super(key: key);
  final SignInWithAppleOnCreated onCreated;

  @override
  _SignInWithAppleState createState() => _SignInWithAppleState();
}

class _SignInWithAppleState extends State<SignInWithApple> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return GestureDetector(onTap: (){
        print("asdfad");
      },child:
      UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "hidesWhenStopped": true,
        },
        creationParamsCodec: new StandardMessageCodec(),
      ),);
    }
    return Text('苹果登录插件尚不支持$defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onCreated == null) {
      return;
    }
    widget.onCreated(new SignInWithAppleController._(id));
  }
}

typedef void SignInWithAppleOnCreated(SignInWithAppleController controller);
typedef void SignInWithAppleOnClick(MethodCall methodCall);

class SignInWithAppleController {
  SignInWithAppleController._(int id) {
    _channel = MethodChannel('${viewType}_$id')..setMethodCallHandler(_handler);
  }

  static MethodChannel _channel;
  SignInWithAppleOnClick click;
  Future<dynamic> _handler(MethodCall methodCall) {
    print(methodCall);
    switch (methodCall.method) {
      case "auth":
        click(methodCall);
        break;
      default: break;
    }
    return Future.value(true);
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
