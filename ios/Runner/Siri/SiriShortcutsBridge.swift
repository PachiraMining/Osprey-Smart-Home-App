import Flutter
import Intents
import IntentsUI
import UIKit

/// Cầu nối Flutter ⇄ Siri Shortcuts (SiriKit/IntentsUI).
///
/// Dùng API "legacy support" của Apple — CHƯA bị deprecate (metadata docs
/// `deprecated: false`, Apple chỉ ghi là legacy) — vì đây là cách DUY NHẤT cho
/// phép user tự đặt câu lệnh riêng cho từng scene, giống app Tuya.
@available(iOS 12.0, *)
final class SiriShortcutsBridge: NSObject {

    static let channelName = "osprey/siri"

    private var pendingResult: FlutterResult?
    private weak var controller: UIViewController?

    static func register(with controller: UIViewController, messenger: FlutterBinaryMessenger) {
        let instance = SiriShortcutsBridge(controller: controller)
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { [instance] call, result in
            instance.handle(call, result: result)
        }
        // Giữ tham chiếu mạnh qua closure của channel để bridge không bị giải phóng.
        objc_setAssociatedObject(controller, &Self.assocKey, instance, .OBJC_ASSOCIATION_RETAIN)
    }

    private static var assocKey: UInt8 = 0

    private init(controller: UIViewController) {
        self.controller = controller
        super.init()
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            result(true)
        case "listShortcuts":
            listShortcuts(result: result)
        case "presentAddToSiri":
            guard let args = call.arguments as? [String: Any],
                  let sceneId = args["sceneId"] as? String,
                  let sceneName = args["sceneName"] as? String
            else {
                result(FlutterError(code: "bad_args", message: "sceneId/sceneName required",
                                    details: nil))
                return
            }
            present(sceneId: sceneId, sceneName: sceneName, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Danh sách shortcut đã tạo

    /// Trả `{sceneId: phrase}` để Flutter vẽ dấu "+" hay câu lệnh đã gán.
    private func listShortcuts(result: @escaping FlutterResult) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { shortcuts, _ in
            var map: [String: String] = [:]
            for voice in shortcuts ?? [] {
                guard case let .intent(intent) = voice.shortcut,
                      let runScene = intent as? RunSceneIntent,
                      let sceneId = runScene.sceneId
                else { continue }
                map[sceneId] = voice.invocationPhrase
            }
            DispatchQueue.main.async { result(map) }
        }
    }

    // MARK: - Sheet thêm / sửa

    private func present(sceneId: String, sceneName: String,
                         result: @escaping FlutterResult) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [weak self] shortcuts, _ in
            let existing = (shortcuts ?? []).first { voice in
                guard case let .intent(intent) = voice.shortcut,
                      let runScene = intent as? RunSceneIntent
                else { return false }
                return runScene.sceneId == sceneId
            }

            DispatchQueue.main.async {
                guard let self, let host = self.topViewController() else {
                    result(nil)
                    return
                }
                self.pendingResult = result

                if let existing {
                    // Đã có → sheet "Change Voice Phrase / Remove Shortcut".
                    let editor = INUIEditVoiceShortcutViewController(voiceShortcut: existing)
                    editor.delegate = self
                    host.present(editor, animated: true)
                } else {
                    let intent = self.makeIntent(sceneId: sceneId, sceneName: sceneName)
                    guard let shortcut = INShortcut(intent: intent) else {
                        self.finish(nil)
                        return
                    }
                    let adder = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                    adder.delegate = self
                    host.present(adder, animated: true)
                }
            }
        }
    }

    private func makeIntent(sceneId: String, sceneName: String) -> RunSceneIntent {
        let intent = RunSceneIntent()
        intent.sceneId = sceneId
        intent.sceneName = sceneName
        // Câu gợi ý sẵn trong ô nhập của sheet = tên scene, giống Tuya.
        intent.suggestedInvocationPhrase = sceneName
        return intent
    }

    /// Sheet phải present từ VC trên cùng, nếu không sẽ bị nuốt khi Flutter
    /// đang hiện dialog/bottom-sheet.
    private func topViewController() -> UIViewController? {
        var top = controller ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    /// Trả kết quả về Flutter đúng MỘT lần.
    private func finish(_ phrase: String?) {
        pendingResult?(phrase)
        pendingResult = nil
    }
}

// MARK: - Add delegate

@available(iOS 12.0, *)
extension SiriShortcutsBridge: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(
        _ controller: INUIAddVoiceShortcutViewController,
        didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?
    ) {
        controller.dismiss(animated: true) { [weak self] in
            self?.finish(voiceShortcut?.invocationPhrase)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(
        _ controller: INUIAddVoiceShortcutViewController
    ) {
        controller.dismiss(animated: true) { [weak self] in self?.finish(nil) }
    }
}

// MARK: - Edit delegate

@available(iOS 12.0, *)
extension SiriShortcutsBridge: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(
        _ controller: INUIEditVoiceShortcutViewController,
        didUpdate voiceShortcut: INVoiceShortcut?, error: Error?
    ) {
        controller.dismiss(animated: true) { [weak self] in
            self?.finish(voiceShortcut?.invocationPhrase)
        }
    }

    func editVoiceShortcutViewController(
        _ controller: INUIEditVoiceShortcutViewController,
        didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID
    ) {
        controller.dismiss(animated: true) { [weak self] in self?.finish(nil) }
    }

    func editVoiceShortcutViewControllerDidCancel(
        _ controller: INUIEditVoiceShortcutViewController
    ) {
        controller.dismiss(animated: true) { [weak self] in self?.finish(nil) }
    }
}
