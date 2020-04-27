import AuthenticationServices
import KeychainAccess

enum AuthorizationError: String {
    case canceled = "用户取消了授权请求"
    case failed = "授权请求失败"
    case invalidResponse = "授权请求响应无效"
    case notHandled = "未能处理授权请求"
    case unknown = "授权请求失败未知原因"
}
enum AuthStatus {
    case authorized, revoked, notFound
}
/// 也可以使用自定义 [custom apple login](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/)
@available(iOS 13.0, *)
public class SignInWithApple: NSObject {
    static let `default`: SignInWithApple = {
        return SignInWithApple()
    }()
    private override init() {
        super.init()
    }
    
    private var keychain: Keychain {
        return Keychain(service: Bundle.main.bundleIdentifier ?? "unresolved bundleIdentifier")
    }
    var onCompleted: ((_ success: [String: String]?, _ error: AuthorizationError?)->Void)?
    
    func getAuthBtn(_ style: ASAuthorizationAppleIDButton.Style = .white)-> ASAuthorizationAppleIDButton {
        let auth = ASAuthorizationAppleIDButton(type: .signIn, style: style)
        auth.addTarget(self, action: #selector(authClick), for: .touchUpInside)
        return auth
    }
    
    @objc func authClick() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        var requests: [ASAuthorizationRequest] = [request]
        if (keychain["userIdentifier"] != nil) {
            let pwd = ASAuthorizationPasswordProvider().createRequest()
            requests.append(pwd)
        }
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func getAuthStatus(_ status: @escaping ((AuthStatus)->Void)) {
        guard let userID = keychain["userIdentifier"] else {
            status(.notFound)
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { (state, error) in
            switch state {
            case .authorized:
                status(.authorized)
            case .revoked:
                status(.revoked)
            case .notFound, .transferred:
                status(.notFound)
            default: status(.notFound)
            }
        }
    }
}
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.description ?? ""
            let email = appleIDCredential.email ?? ""
            
            let identityToken = String(bytes: appleIDCredential.identityToken!, encoding: .utf8)!
            let authCode = String(bytes: appleIDCredential.authorizationCode!, encoding: .utf8)!
            
            keychain["userIdentifier"] = userIdentifier
            let msg = ["userIdentifier": userIdentifier, "fullName": fullName, "email": email, "identityToken": identityToken, "authCode": authCode]
            onCompleted?(msg, nil)
            print(msg)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            let msg = ["username": username, "password": password]
            onCompleted?(msg, nil)
            let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
            print(message)
        } else {
            print("信息不符合")
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let code = ASAuthorizationError(_nsError: error as NSError).code
        switch code {
        case .canceled:
            onCompleted?(nil, .canceled)
        case .failed:
            onCompleted?(nil, .failed)
        case .invalidResponse:
            onCompleted?(nil, .invalidResponse)
        case .notHandled:
            onCompleted?(nil, .notHandled)
        case .unknown:
            onCompleted?(nil, .unknown)
        default:
            break
        }
    }
}
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.last!
    }
}
