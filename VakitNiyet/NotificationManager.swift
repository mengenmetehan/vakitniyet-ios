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
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            
            if granted {
                // Register for remote notifications
                await UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("❌ Notification permission error: \(error)")
            throw error
        }
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
    
    // MARK: - Local Notification Scheduling (Test için)
    
    func scheduleTestNotification(type: String = "KARMA") async throws {
        // Önce bildirim iznini kontrol et
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        print("🔔 Notification Authorization Status: \(settings.authorizationStatus.rawValue)")
        print("   - Authorized: \(settings.authorizationStatus == .authorized)")
        print("   - Alert Setting: \(settings.alertSetting.rawValue)")
        print("   - Sound Setting: \(settings.soundSetting.rawValue)")
        print("   - Badge Setting: \(settings.badgeSetting.rawValue)")
        
        // İzin verilmemişse veya belirtilmemişse, izin iste
        if settings.authorizationStatus == .notDetermined {
            print("⚠️ Permission not determined, requesting...")
            try await requestPermission()
            // İzin istendikten sonra tekrar kontrol et
            let newSettings = await center.notificationSettings()
            guard newSettings.authorizationStatus == .authorized else {
                print("❌ User denied notification permission")
                throw NotificationError.permissionDenied
            }
        } else if settings.authorizationStatus != .authorized {
            print("❌ Notification permission denied!")
            print("💡 Please enable notifications in Settings > VakitNiyet > Notifications")
            throw NotificationError.permissionDenied
        }
        
        print("✅ Notification permission is granted, proceeding...")
        
        // Backend'den test notification gönder
        guard let url = URL(string: "\(AppConfig.baseURL)/notification/test-send?type=\(type)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Auth token ekle (UserDefaults'tan al)
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token for test notification")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Backend'den gelen raw data'yı logla
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Backend Response Data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📊 HTTP Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Test notification request failed with status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            throw URLError(.badServerResponse)
        }
        
        // Response'u parse et
        let decoder = JSONDecoder()
        let notificationResponse = try decoder.decode(TestNotificationResponse.self, from: data)
        
        print("📦 Parsed Response:")
        print("   - Title: \(notificationResponse.title ?? "nil")")
        print("   - Body: \(notificationResponse.body ?? "nil")")
        print("   - Metin: \(notificationResponse.metin ?? "nil")")
        print("   - Kaynak: \(notificationResponse.kaynak ?? "nil")")
        print("   - Success: \(notificationResponse.success ?? false)")
        print("   - Message: \(notificationResponse.message ?? "nil")")
        print("   - Data: \(notificationResponse.data ?? [:])")
        
        // Local notification olarak schedule et
        let content = UNMutableNotificationContent()
        content.title = notificationResponse.notificationTitle
        content.body = notificationResponse.notificationBody
        content.sound = .default
        
        // App icon'unu badge olarak göster
        content.badge = 1
        
        // Bildirime resim ekle (opsiyonel - istemiyorsanız yorum satırı yapın)
        // if let imageUrl = addNotificationAttachment(to: content) {
        //     print("🖼️ Notification image attached")
        // }
        
        print("🔔 Creating notification content:")
        print("   - Title: '\(content.title)'")
        print("   - Body: '\(content.body)'")
        print("   - Sound: \(content.sound != nil ? "Yes" : "No")")
        print("   - Badge: \(content.badge ?? 0)")
        
        // Backend'den gelen ekstra verileri userInfo'ya ekle
        if let additionalData = notificationResponse.data {
            content.userInfo = additionalData
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let notificationRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(notificationRequest)
        print("✅ Test notification scheduled from backend - Type: \(type)")
        print("📬 Title: \(content.title)")
        print("📬 Body: \(content.body)")
    }
    
    // MARK: - Handle Notification Response
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification tapped: \(userInfo)")
        
        // Notification'dan gelen verilere göre aksiyon al
        // Örn: belirli bir namaz sayfasına yönlendir
    }
    
    // MARK: - Notification Attachment Helper
    
    private func addNotificationAttachment(to content: UNMutableNotificationContent) -> URL? {
        // Asset catalog'dan bir resim kullan
        // Assets.xcassets'e "NotificationImage" adında bir resim ekleyin
        
        guard let image = UIImage(named: "NotificationImage") ?? UIImage(named: "AppIcon"),
              let imageData = image.pngData() else {
            print("⚠️ Notification image not found")
            return nil
        }
        
        // Geçici dizine kaydet
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".png")
        
        do {
            try imageData.write(to: tempFileURL)
            let attachment = try UNNotificationAttachment(identifier: "image", url: tempFileURL, options: nil)
            content.attachments = [attachment]
            return tempFileURL
        } catch {
            print("❌ Error creating notification attachment: \(error)")
            return nil
        }
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
        return [.banner, .sound, .badge]
    }
    
    // Notification'a tıklandığında
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        handleNotificationResponse(response)
    }
}
// MARK: - Response Models

struct TestNotificationResponse: Codable {
    let title: String?
    let body: String?
    let metin: String?      // Backend'den gelen "metin" field'ı
    let kaynak: String?     // Backend'den gelen "kaynak" field'ı
    let data: [String: Any]?
    let success: Bool?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case title, body, metin, kaynak, data, success, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        metin = try container.decodeIfPresent(String.self, forKey: .metin)
        kaynak = try container.decodeIfPresent(String.self, forKey: .kaynak)
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // data dictionary'yi decode et
        if let dataDict = try container.decodeIfPresent([String: AnyCodable].self, forKey: .data) {
            data = dataDict.mapValues { $0.value }
        } else {
            data = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(metin, forKey: .metin)
        try container.encodeIfPresent(kaynak, forKey: .kaynak)
        try container.encodeIfPresent(success, forKey: .success)
        try container.encodeIfPresent(message, forKey: .message)
        
        // data'yı encode et
        if let data = data {
            let encodableDict = data.mapValues { AnyCodable($0) }
            try container.encodeIfPresent(encodableDict, forKey: .data)
        }
    }
    
    // Helper computed properties
    var notificationTitle: String {
        return title ?? kaynak ?? "Ayet Bildirimi"
    }
    
    var notificationBody: String {
        return body ?? metin ?? "Bildirim içeriği"
    }
}

// Helper struct for decoding Any type
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        default:
            try container.encodeNil()
        }
    }
}

