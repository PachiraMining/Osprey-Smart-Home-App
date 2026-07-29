import Foundation

/// Đọc dữ liệu app Flutter ghi vào App Group (cùng chỗ widget đang dùng).
///
/// Intent handler chạy trong tiến trình app được launch nền, không có Dart, nên
/// mọi thứ nó cần (JWT, base URL) phải nằm sẵn ở đây.
struct SiriSharedStore {
    static let appGroupId = "group.io.dracaena.curtainai"

    /// Server mặc định khi app chưa kịp ghi — khớp với bản phát hành
    /// (`--dart-define=API_ENV=publish`).
    static let fallbackBaseUrl = "https://iot.osprey.life"

    private let defaults = UserDefaults(suiteName: SiriSharedStore.appGroupId)

    var jwt: String? { defaults?.string(forKey: "widget_jwt") }

    /// App ghi `api_base_url` mỗi lần khởi động; hardcode chỉ là lưới an toàn.
    var baseUrl: String {
        let stored = defaults?.string(forKey: "api_base_url") ?? ""
        return stored.isEmpty ? SiriSharedStore.fallbackBaseUrl : stored
    }

    /// Ghi kết quả lượt chạy gần nhất để app đọc lại — Shortcuts chỉ hiện
    /// "An unknown error occurred", không cho biết hỏng ở đâu.
    func recordResult(_ value: String) {
        defaults?.set(value, forKey: "siri_last_result")
    }
}
