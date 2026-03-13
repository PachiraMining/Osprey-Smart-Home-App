import Flutter
import UIKit
import LoginWithAmazon

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AlexaLwaPlugin") else { return }
        let messenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: "com.osprey/alexa_lwa", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "signIn":
                self?.handleSignIn(call: call, result: result)
            case "signOut":
                self?.handleSignOut(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - LWA Sign In

    private func handleSignIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scopes = args["scopes"] as? [String] else {
            result(["status": "error", "error": "Invalid arguments"])
            return
        }

        pendingResult = result

        var scopeObjects: [AMZNScope] = []
        for scope in scopes {
            switch scope {
            case "profile":
                scopeObjects.append(AMZNProfileScope.profile())
            case "postal_code":
                scopeObjects.append(AMZNProfileScope.postalCode())
            default:
                // Custom scope (e.g., alexa::skills:account_linking)
                scopeObjects.append(AMZNScopeFactory.scope(withName: scope))
            }
        }

        let request = AMZNAuthorizeRequest()
        request.scopes = scopeObjects
        request.interactiveStrategy = .always

        AMZNAuthorizationManager.shared().authorize(request) { [weak self] (authResult, userDidCancel, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.pendingResult?([
                        "status": "error",
                        "error": error.localizedDescription,
                        "errorType": String(describing: type(of: error))
                    ])
                } else if userDidCancel {
                    self.pendingResult?([
                        "status": "cancelled",
                        "description": "User cancelled"
                    ])
                } else if let authResult = authResult {
                    self.pendingResult?([
                        "status": "success",
                        "accessToken": authResult.token ?? ""
                    ])
                } else {
                    self.pendingResult?(["status": "error", "error": "Unknown error"])
                }
                self.pendingResult = nil
            }
        }
    }

    // MARK: - LWA Sign Out

    private func handleSignOut(result: @escaping FlutterResult) {
        AMZNAuthorizationManager.shared().signOut { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    result(["status": "error", "error": error.localizedDescription])
                } else {
                    result(["status": "success"])
                }
            }
        }
    }

    // MARK: - URL Handling for LWA callback

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if AMZNAuthorizationManager.handleOpen(url, sourceApplication: options[.sourceApplication] as? String) {
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
