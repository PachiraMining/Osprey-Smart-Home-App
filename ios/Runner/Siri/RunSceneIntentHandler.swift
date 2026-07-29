import Foundation
import Intents

/// Xử lý `RunSceneIntent` khi Siri kích hoạt shortcut.
///
/// Chạy HOÀN TOÀN bằng Swift: hệ thống launch app ở chế độ nền (qua
/// `AppDelegate.application(_:handlerFor:)`) rồi gọi thẳng REST API. KHÔNG bao
/// giờ gọi ngược sang Dart ở đây — khi app bị launch nền, isolate Flutter có thể
/// chưa sống, scene sẽ không chạy.
@available(iOS 14.0, *)
final class RunSceneIntentHandler: NSObject, RunSceneIntentHandling {

    func handle(intent: RunSceneIntent) async -> RunSceneIntentResponse {
        let store = SiriSharedStore()
        let sceneId = intent.sceneId ?? ""

        guard !sceneId.isEmpty else {
            store.recordResult("no_scene_id")
            return Self.response(.failure, message: "Scene is no longer available.")
        }

        guard let token = store.jwt, !token.isEmpty else {
            store.recordResult("no_jwt — open the app and sign in once")
            return Self.response(.failure, message: "Please open Osprey and sign in.")
        }

        guard let url = URL(
            string: "\(store.baseUrl)/api/smarthome/scenes/\(sceneId)/execute")
        else {
            store.recordResult("bad_url \(store.baseUrl)")
            return Self.response(.failure, message: "Could not reach the server.")
        }

        var request = URLRequest(url: url, timeoutInterval: 8)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "X-Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            switch code {
            case 200...299:
                // Backend chạy scene bất đồng bộ; 2xx nghĩa là đã nhận lệnh.
                store.recordResult("ok")
                return Self.response(.success, message: intent.sceneName)
            case 401:
                store.recordResult("http_401 — token expired")
                return Self.response(.failure,
                                     message: "Please open Osprey and sign in again.")
            case 400:
                store.recordResult("http_400 — scene disabled")
                return Self.response(.failure, message: "This scene is turned off.")
            default:
                store.recordResult("http_\(code)")
                return Self.response(.failure,
                                     message: "The scene could not run right now.")
            }
        } catch {
            store.recordResult("network — \(error.localizedDescription)")
            return Self.response(.failure, message: "No connection to the server.")
        }
    }

    private static func response(_ code: RunSceneIntentResponseCode,
                                 message: String?) -> RunSceneIntentResponse {
        let response = RunSceneIntentResponse(code: code, userActivity: nil)
        response.message = message
        return response
    }
}
