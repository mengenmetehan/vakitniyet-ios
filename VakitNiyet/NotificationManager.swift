import Foundation
import Combine
import UserNotifications
import UIKit


@MainActor
class NotificationManager: NSObject, ObservableObject {

    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var deviceToken: String?
    
    private let authService = AuthService.shared
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Request Permission
    
    func requestPermission() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        // Check the new status
        checkAuthorizationStatus()

        // Register for remote notifications
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Check Status
    
    private func checkAuthorizationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Handle Device Token
    
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        
        print("📱 Device Token: \(tokenString)")
        
        // Backend'e gönder
        Task {
            await authService.updateDeviceToken(tokenString)
        }
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Test Notification

    func scheduleTestNotification(type: String = "KARMA") async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            try await requestPermission()
            let newSettings = await center.notificationSettings()
            guard newSettings.authorizationStatus == .authorized else {
                throw NotificationError.permissionDenied
            }
        } else if settings.authorizationStatus != .authorized {
            throw NotificationError.permissionDenied
        }

        guard let url = URL(string: "\(AppConfig.baseURL)/notification/test-send?type=\(type)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Test notification token: YES")
        } else {
            print("🔑 Test notification token: NO (not logged in?)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let raw = String(data: data, encoding: .utf8) { print("❌ Test notification failed: \(raw)") }
            throw URLError(.badServerResponse)
        }

        // Backend içeriği hesaplar, push'u biz göndeririz
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        let title = json["title"] as? String ?? json["kaynak"] as? String ?? "VakitNiyet"
        let body  = json["body"]  as? String ?? json["metin"]  as? String ?? ""

        // Namaz bildirimi formatı varsa uygula, yoksa backend body'yi kullan
        let finalBody = NotificationManager.formatPrayerBody(userInfo: json) ?? body

        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = finalBody
        content.sound = .default
        content.badge = 1
        content.userInfo = json

        if let attachment = appIconAttachment() {
            content.attachments = [attachment]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        try await center.add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        )
        print("✅ Test notification scheduled — title: \(title)")
    }
    
    // MARK: - App Icon Attachment

    private func appIconAttachment() -> UNNotificationAttachment? {
        guard
            let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let files = primary["CFBundleIconFiles"] as? [String],
            let iconName = files.last
        else { return nil }

        // Asset catalog'dan derlenen PNG'leri bundle'da ara (@3x, @2x, plain)
        let candidates = ["\(iconName)@3x", "\(iconName)@2x", iconName]
        guard let iconURL = candidates.lazy
            .compactMap({ Bundle.main.url(forResource: $0, withExtension: "png") })
            .first
        else { return nil }

        return try? UNNotificationAttachment(identifier: "appIcon", url: iconURL, options: nil)
    }

    // MARK: - Prayer Notification Body Formatting

    static func formatPrayerBody(userInfo: [AnyHashable: Any]) -> String? {
        // Backend'den gelen namaz adı: "prayerName" veya "prayer_name"
        let rawName = userInfo["prayerName"] as? String
            ?? userInfo["prayer_name"] as? String

        guard let rawName else { return nil }

        let displayName: String
        switch rawName.uppercased() {
        case "FAJR",    "SABAH", "IMSAK": displayName = "Sabah"
        case "DHUHR",   "OGLE",  "ÖĞLE":  displayName = "Öğle"
        case "ASR",     "IKINDI","İKİNDİ":displayName = "İkindi"
        case "MAGHRIB", "AKSAM", "AKŞAM": displayName = "Akşam"
        case "ISHA",    "YATSI", "YATSI": displayName = "Yatsı"
        default: displayName = rawName.capitalized
        }

        // Offset: önce payload'dan bak, sonra UserDefaults'taki kullanıcı ayarı
        let offset: Int
        if let payloadOffset = userInfo["offsetMinutes"] as? Int ?? (userInfo["offsetMinutes"] as? String).flatMap(Int.init) {
            offset = payloadOffset
        } else {
            offset = UserDefaults.standard.integer(forKey: "notificationOffset").nonZero ?? 10
        }

        return "\(displayName) namazına \(offset) dk kaldı"
    }

    // MARK: - Handle Notification Response

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification tapped: \(userInfo)")
    }
    
}

// MARK: - Notification Error

enum NotificationError: LocalizedError {
    case permissionDenied
    case failedToSchedule
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Bildirim izni verilmemiş. Lütfen Ayarlar > VakitNiyet > Bildirimler'den izin verin."
        case .failedToSchedule:
            return "Bildirim planlanamadı"
        }
    }
}

// MARK: - App Delegate için extension

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Uygulama açıkken notification gelirse
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .list, .sound, .badge]
    }
    
    // Notification'a tıklandığında
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        handleNotificationResponse(response)
    }
}
// MARK: - Int Helper

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}

