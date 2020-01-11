import Flutter
import UIKit

// public class SwiftSiwaPlugin: NSObject, FlutterPlugin {
//     private static let instance: SwiftSiwaPlugin = {
//         return SwiftSiwaPlugin()
//     }()
//     private static var channel: FlutterMethodChannel!
//     public static func register(with registrar: FlutterPluginRegistrar) {
//         channel = FlutterMethodChannel(name: "plugins/siwa", binaryMessenger: registrar.messenger())
//          registrar.addMethodCallDelegate(instance, channel: channel)
//     }

//     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//         switch call.method {
//         case "getPlatformVersion":
//             result("iOS " + UIDevice.current.systemVersion)
//         default:
//             result(FlutterMethodNotImplemented)
//             break;
//         }
//     }
// }

public class SignInWithAppleFactory: NSObject, FlutterPlatformViewFactory {
    var messenger: FlutterBinaryMessenger!
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return SignInWithAppleController(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }
    
    @objc public init(messenger: (NSObject & FlutterBinaryMessenger)?) {
        super.init()
        self.messenger = messenger
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class SignInWithAppleController: NSObject, FlutterPlatformView {
    fileprivate var viewId: Int64!;
    fileprivate var _auth: UIView!
    fileprivate var channel: FlutterMethodChannel!
    
    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        super.init()
        
        self.viewId = viewId
        self.channel = FlutterMethodChannel(name: "plugins/siwa_\(viewId)", binaryMessenger: binaryMessenger)
        
        self.channel.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if let this = self {
                this.onMethodCall(call: call, result: result)
            }
        })
        
        let params = args as! Dictionary<String, Any>
        
        if #available(iOS 13.0, *) {
            _auth = SignInWithApple.default.getAuthBtn(params, channel: channel)
        } else {
            let auth = UIButton(type: .custom)
            auth.setTitle("苹果登录", for: .normal)
            auth.backgroundColor = .red
            auth.addTarget(self, action: #selector(click), for: .touchUpInside)
            _auth = auth
        }
    }
    
    public func view() -> UIView {
        return self._auth
    }
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
            break;
        }
    }
    @objc func click(){
        channel.invokeMethod("auth", arguments: "siwa is avaliable since iOS 13.0")
    }
}
