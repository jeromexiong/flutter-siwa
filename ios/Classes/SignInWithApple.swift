import AuthenticationServices
import KeychainAccess

@available(iOS 13.0, *)
public class SignInWithApple: NSObject {
    static let `default`: SignInWithApple = {
        return SignInWithApple()
    }()
    private var keychain: Keychain {
        return Keychain(service: Bundle.main.bundleIdentifier ?? "unresolved bundleIdentifier")
    }
    var onError: ((ASAuthorizationError.Code)->Void)?
    private override init() {
        super.init()
    }
    
    var channel: FlutterMethodChannel?
    func getAuthBtn(_ params: Dictionary<String, Any>, channel: FlutterMethodChannel)-> ASAuthorizationAppleIDButton {
        let auth = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        auth.cornerRadius = 20
        //            let auth = UIButton(type: .custom)
        //            auth.setTitle("苹果登录", for: .normal)
        //            auth.backgroundColor = .red
        auth.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.channel = channel
        return auth
    }
    @objc func handleAuthorizationAppleIDButtonPress() {
        //        if (keychain["userIdentifier"] != nil) {
        //            performExistingAccountSetupFlows()
        //            return;
        //        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        print("已经登录过了")
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.description ?? ""
            let email = appleIDCredential.email ?? ""
            
            let token = String(bytes: appleIDCredential.identityToken!, encoding: .utf8)!
            let authCode = String(bytes: appleIDCredential.authorizationCode!, encoding: .utf8)!
            
            keychain["userIdentifier"] = userIdentifier
            let msg = """
            userIdentifier: \(userIdentifier)\n fullName: \(fullName)\n email: \(email)\n
            token: \(token)\n authCode: \(authCode)
            """
            print(msg)
            if let channel = channel {
                channel.invokeMethod("auth", arguments: msg)
            }
            // For the purpose of this demo app, show the Apple ID credential information in the ResultViewController.
            //            if let viewController = self.presentingViewController as? ResultViewController {
            //                DispatchQueue.main.async {
            //                    viewController.userIdentifierLabel.text = userIdentifier
            //                    if let givenName = fullName?.givenName {
            //                        viewController.givenNameLabel.text = givenName
            //                    }
            //                    if let familyName = fullName?.familyName {
            //                        viewController.familyNameLabel.text = familyName
            //                    }
            //                    if let email = email {
            //                        viewController.emailLabel.text = email
            //                    }
            //                    self.dismiss(animated: true, completion: nil)
            //                }
            //            }
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
                let alertController = UIAlertController(title: "Keychain Credential Received",
                                                        message: message,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                guard let window = UIApplication.shared.windows.last, let rootVC = window.rootViewController else {
                    return
                }
                rootVC.present(alertController, animated: true, completion: nil)
            }
        }else {
            print("信息不符合")
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let code = ASAuthorizationError(_nsError: error as NSError).code
        switch code {
        case .canceled:
            print("用户取消了授权请求")
        case .failed:
            print("授权请求失败")
        case .invalidResponse:
            print("授权请求响应无效")
        case .notHandled:
            print("未能处理授权请求")
        case .unknown:
            print("授权请求失败未知原因")
        default:
            break
        }
        if let channel = channel {
            channel.invokeMethod("auth", arguments: "\(code.rawValue)")
        }
    }
}
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.last!
    }
}
