import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Shared constants

/// App Group chia sẻ với app Flutter (home_widget ghi UserDefaults vào đây).
let kAppGroupId = "group.io.dracaena.curtainai"
let kBaseUrl = "https://performentmarketing.ddnsgeek.com"

// MARK: - Device list (app Flutter ghi JSON vào `widget_devices`)

struct StoredDevice: Decodable {
    let id: String
    let name: String
    let online: Bool
}

func loadStoredDevices() -> [StoredDevice] {
    let defaults = UserDefaults(suiteName: kAppGroupId)
    guard let raw = defaults?.string(forKey: "widget_devices"),
          let data = raw.data(using: .utf8),
          let list = try? JSONDecoder().decode([StoredDevice].self, from: data)
    else {
        // Fallback: chưa có danh sách (app bản cũ) → dùng thiết bị mặc định.
        let id = defaults?.string(forKey: "widget_device_id") ?? ""
        guard !id.isEmpty else { return [] }
        return [StoredDevice(
            id: id,
            name: defaults?.string(forKey: "widget_device_name") ?? "Curtain",
            online: defaults?.bool(forKey: "widget_device_online") ?? false
        )]
    }
    return list
}

// MARK: - AppEntity cho menu Edit Widget

struct CurtainDevice: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Curtain"
    static var defaultQuery = CurtainDeviceQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CurtainDeviceQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CurtainDevice] {
        loadStoredDevices()
            .filter { identifiers.contains($0.id) }
            .map { CurtainDevice(id: $0.id, name: $0.name) }
    }

    func suggestedEntities() async throws -> [CurtainDevice] {
        loadStoredDevices().map { CurtainDevice(id: $0.id, name: $0.name) }
    }

    func defaultResult() async -> CurtainDevice? {
        loadStoredDevices().first.map { CurtainDevice(id: $0.id, name: $0.name) }
    }
}

/// Intent cấu hình: long-press widget → Edit Widget → chọn rèm.
struct SelectCurtainIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Choose Curtain"
    static var description = IntentDescription(
        "Choose which curtain this widget controls.")

    @Parameter(title: "Curtain")
    var device: CurtainDevice?
}

// MARK: - Timeline

struct CurtainEntry: TimelineEntry {
    let date: Date
    let deviceName: String
    let deviceId: String
    let isOnline: Bool
    let lastAction: String
    let error: String

    var hasDevice: Bool { !deviceId.isEmpty }
    var needsApp: Bool { error == "no_auth" || error == "auth_expired" }

    static func load(configuration: SelectCurtainIntent) -> CurtainEntry {
        let d = UserDefaults(suiteName: kAppGroupId)
        let jwt = d?.string(forKey: "widget_jwt") ?? ""
        var error = d?.string(forKey: "widget_error") ?? ""
        if jwt.isEmpty { error = "no_auth" }

        let devices = loadStoredDevices()
        // Thiết bị đã chọn trong Edit Widget; chưa chọn → thiết bị đầu tiên.
        let selected = configuration.device.flatMap { picked in
            devices.first { $0.id == picked.id }
        } ?? devices.first

        let deviceId = selected?.id ?? ""
        return CurtainEntry(
            date: Date(),
            deviceName: selected?.name ?? "Curtain",
            deviceId: deviceId,
            isOnline: selected?.online ?? false,
            lastAction: d?.string(forKey: "widget_last_action_\(deviceId)") ?? "",
            error: error
        )
    }

    static let placeholder = CurtainEntry(
        date: Date(),
        deviceName: "Living room curtain",
        deviceId: "demo",
        isOnline: true,
        lastAction: "open",
        error: ""
    )
}

struct CurtainProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CurtainEntry { .placeholder }

    func snapshot(
        for configuration: SelectCurtainIntent, in context: Context
    ) async -> CurtainEntry {
        context.isPreview ? .placeholder : .load(configuration: configuration)
    }

    func timeline(
        for configuration: SelectCurtainIntent, in context: Context
    ) async -> Timeline<CurtainEntry> {
        // App + AppIntent chủ động reload; không cần lịch tự refresh.
        Timeline(entries: [.load(configuration: configuration)], policy: .never)
    }
}

// MARK: - Intent (nút bấm gọi API trực tiếp, không mở app)

struct CurtainCommandIntent: AppIntent {
    static var title: LocalizedStringResource = "Control Curtain"
    static var isDiscoverable = false

    @Parameter(title: "Action")
    var action: String

    @Parameter(title: "Device ID")
    var deviceId: String

    init() {
        action = "stop"
        deviceId = ""
    }

    init(action: String, deviceId: String) {
        self.action = action
        self.deviceId = deviceId
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: kAppGroupId)
        let token = defaults?.string(forKey: "widget_jwt") ?? ""

        guard !token.isEmpty else {
            defaults?.set("no_auth", forKey: "widget_error")
            return .result()
        }
        guard !deviceId.isEmpty,
              let url = URL(string: "\(kBaseUrl)/api/smarthome/devices/\(deviceId)/commands")
        else {
            defaults?.set("no_device", forKey: "widget_error")
            return .result()
        }

        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "X-Authorization")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: ["dpId": 1, "value": action]
        )

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            switch code {
            case 200:
                defaults?.set(action, forKey: "widget_last_action_\(deviceId)")
                defaults?.set("", forKey: "widget_error")
            case 401:
                defaults?.set("auth_expired", forKey: "widget_error")
            default:
                defaults?.set("http_\(code)", forKey: "widget_error")
            }
        } catch {
            defaults?.set("network", forKey: "widget_error")
        }
        return .result()
    }
}

// MARK: - Views

struct CurtainWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CurtainEntry

    private let ocean = Color(red: 0.043, green: 0.373, blue: 0.659) // #0B5FA8
    private let ink = Color(red: 0.07, green: 0.13, blue: 0.21) // chữ tối, cố định
    private let inkSecondary = Color(red: 0.32, green: 0.39, blue: 0.47)

    var body: some View {
        content
            // Nền luôn sáng nên ép light scheme — tránh iOS dark mode
            // đổi .primary/.secondary thành chữ trắng trên nền trắng.
            .environment(\.colorScheme, .light)
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [Color(red: 0.94, green: 0.97, blue: 0.99), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        if entry.needsApp || !entry.hasDevice {
            VStack(spacing: 6) {
                Image(systemName: "curtains.closed")
                    .font(.title2)
                    .foregroundStyle(ocean)
                Text(entry.needsApp
                    ? "Open the app to sign in"
                    : "Open the app to set up")
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(inkSecondary)
            }
        } else if family == .systemSmall {
            smallView
        } else {
            mediumView
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(entry.isOnline ? Color.green : Color.gray)
                .frame(width: 7, height: 7)
            Text(entry.deviceName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            if !entry.error.isEmpty && !entry.needsApp {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var smallView: some View {
        VStack(spacing: 10) {
            header
            HStack(spacing: 8) {
                commandButton("open", icon: "chevron.left.2", label: "Open")
                commandButton("close", icon: "chevron.right.2", label: "Close")
            }
        }
    }

    private var mediumView: some View {
        VStack(spacing: 12) {
            header
            HStack(spacing: 10) {
                commandButton("open", icon: "chevron.left.2", label: "Open")
                commandButton("stop", icon: "stop.fill", label: "Stop")
                commandButton("close", icon: "chevron.right.2", label: "Close")
            }
        }
    }

    private func commandButton(_ action: String, icon: String, label: String) -> some View {
        Button(intent: CurtainCommandIntent(action: action, deviceId: entry.deviceId)) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                Text(label)
                    .font(.caption.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(entry.lastAction == action
                        ? ocean
                        : ocean.opacity(0.12))
            )
            .foregroundStyle(entry.lastAction == action ? .white : ocean)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Widget

struct OspreyCurtainWidget: Widget {
    let kind: String = "OspreyCurtainWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCurtainIntent.self,
            provider: CurtainProvider()
        ) { entry in
            CurtainWidgetView(entry: entry)
        }
        .configurationDisplayName("Osprey Curtain")
        .description("Open, stop, or close your curtain from the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
