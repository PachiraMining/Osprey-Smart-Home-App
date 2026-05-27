import Flutter
import SwiftUI
import UIKit

#if canImport(FoundationModels)
import FoundationModels
#endif

#if canImport(Aurora)
import Aurora
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {
            registerFoundationModelsChannel(messenger: controller.binaryMessenger)
            if #available(iOS 17.0, *) {
                let factory = AuroraGlowPlatformViewFactory(messenger: controller.binaryMessenger)
                registrar(forPlugin: "AuroraGlowPlugin")?
                    .register(factory, withId: "io.dracaena.curtainai/aurora_glow")
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Foundation Models bridge (iOS 26+)
    //
    // Method channel: `io.dracaena.curtainai/foundation_models`
    // Methods:
    //   - `isAvailable() -> Bool` — runtime check; false on non-Apple-Intelligence-capable
    //     hardware so Flutter falls back to a deterministic rule-based response.
    //   - `complete(prompt: String) -> String` — single-shot on-device LLM completion.
    private func registerFoundationModelsChannel(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "io.dracaena.curtainai/foundation_models",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "isAvailable":
                result(self?.foundationModelsAvailable() ?? false)
            case "complete":
                guard let args = call.arguments as? [String: Any],
                      let prompt = args["prompt"] as? String else {
                    result(FlutterError(code: "BAD_ARGS",
                                        message: "Missing or invalid 'prompt' argument",
                                        details: nil))
                    return
                }
                self?.foundationModelsComplete(prompt: prompt, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func foundationModelsAvailable() -> Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        #endif
        return false
    }

    private func foundationModelsComplete(prompt: String, result: @escaping FlutterResult) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task {
                do {
                    let session = LanguageModelSession()
                    let response = try await session.respond(to: prompt)
                    await MainActor.run { result(response.content) }
                } catch {
                    await MainActor.run {
                        result(FlutterError(code: "FM_ERROR",
                                            message: "\(error)",
                                            details: nil))
                    }
                }
            }
            return
        }
        #endif
        result(FlutterError(code: "FM_UNAVAILABLE",
                            message: "Foundation Models requires iOS 26 on an Apple Intelligence-capable device",
                            details: nil))
    }
}

// MARK: - Aurora Glow platform view (iOS 17+)
//
// Hosts the `AuroraGlow` SwiftUI view (Apple-Intelligence-style Metal glow)
// as a Flutter platform view. Used by the Osprey Life voice / chat flows.
//
// To enable the real Aurora effect:
//   1. Open ios/Runner.xcworkspace in Xcode
//   2. File → Add Package Dependencies
//   3. Paste: https://github.com/tornikegomareli/Aurora
//   4. Choose version 0.3.0 or later, add to the Runner target
//
// Until the package is added, this falls back to a transparent UIView so
// the app builds cleanly. The Flutter side renders a gradient fallback in
// either case so the UI still feels alive.
@available(iOS 17.0, *)
final class AuroraGlowPlatformView: NSObject, FlutterPlatformView {
    private let container: UIView
    private var hosting: UIViewController?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let style = (args as? [String: Any])?["style"] as? String ?? "standard"
        self.container = UIView(frame: frame)
        self.container.backgroundColor = .clear
        self.container.isUserInteractionEnabled = false
        super.init()

        #if canImport(Aurora)
        let glow: AuroraGlow
        switch style {
        case "subtle":
            glow = AuroraGlow(.subtle)
        case "intense":
            glow = AuroraGlow(.intense)
        default:
            glow = AuroraGlow(.standard)
        }
        let host = UIHostingController(rootView: glow.ignoresSafeArea())
        host.view.backgroundColor = .clear
        host.view.isUserInteractionEnabled = false
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.hosting = host
        container.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        #endif
        _ = style
    }

    func view() -> UIView {
        return container
    }
}

@available(iOS 17.0, *)
final class AuroraGlowPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var messenger: FlutterBinaryMessenger?

    init(messenger: FlutterBinaryMessenger?) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AuroraGlowPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
