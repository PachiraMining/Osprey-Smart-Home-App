import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

    /// Nơi DUY NHẤT đăng ký được method channel: với UIScene lifecycle,
    /// `AppDelegate.window` còn nil trong `didFinishLaunching`, root view
    /// controller chỉ tồn tại sau khi scene connect.
    override func scene(_ scene: UIScene,
                        willConnectTo session: UISceneSession,
                        options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        registerFlutterChannels(for: scene)
    }

    private func registerFlutterChannels(for scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let controller = windowScene.windows
                  .compactMap({ $0.rootViewController as? FlutterViewController })
                  .first
        else { return }

        appDelegate.registerChannels(controller: controller)
    }
}
