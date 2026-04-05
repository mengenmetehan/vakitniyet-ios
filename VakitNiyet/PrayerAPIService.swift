import Foundation

class PrayerAPIService {

    static let shared = PrayerAPIService()
    private init() {}

    private let network = NetworkService.shared
    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Prayer Endpoints
    
    /// GET /api/prayer/today - Bugünün namaz durumu
    func getToday() async throws -> DayResponse {
        return try await network.request(path: "/prayer/today")
    }
    
    /// GET /api/prayer/day/{date} - Belirli bir günün namaz durumu
    func getDay(date: Date) async throws -> DayResponse {
        let dateStr = dateFmt.string(from: date)
        return try await network.request(path: "/prayer/day/\(dateStr)")
    }
    
    /// GET /api/prayer/month - Aylık takvim
    func getMonth(year: Int, month: Int) async throws -> MonthResponse {
        return try await network.request(
            path: "/prayer/month?year=\(year)&month=\(month)"
        )
    }
    
    /// POST /api/prayer/toggle - Namaz durumunu değiştir
    func togglePrayer(name: String, date: Date? = nil) async throws -> PrayerLogResponse {
        let dateStr = date.map { dateFmt.string(from: $0) }
        let body = TogglePrayerRequest(prayerName: name, date: dateStr)
        return try await network.request(
            path: "/prayer/toggle",
            method: "POST",
            body: body
        )
    }
    
    /// GET /api/prayer/times/today - Diyanet'ten namaz vakitleri
    func getTodayTimes(ilceId: String) async throws -> PrayerTimesResponse {
        return try await network.request(
            path: "/prayer/times/today?ilceId=\(ilceId)"
        )
    }
    
    /// GET /api/prayer/streak - Streak bilgisi
    func getStreak() async throws -> StreakResponse {
        return try await network.request(path: "/prayer/streak")
    }
    
    /// GET /api/prayer/stats - İstatistikler
    func getStats() async throws -> StatsResponse {
        return try await network.request(path: "/prayer/stats")
    }
    
    // MARK: - Auth Endpoints
    
    /// POST /api/auth/apple - Apple Sign In
    func signInWithApple(
        identityToken: String,
        authorizationCode: String,
        name: String? = nil,
        deviceToken: String? = nil
    ) async throws -> AuthResponse {
        let body = AppleSignInRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            name: name,
            deviceToken: deviceToken
        )
        return try await network.request(
            path: "/auth/apple",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    /// POST /api/auth/refresh - Token yenile
    func refreshToken(refreshToken: String) async throws -> TokenResponse {
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        return try await network.request(
            path: "/auth/refresh",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    /// PUT /api/auth/device-token - Device token güncelle
    func updateDeviceToken(_ token: String) async throws {
        let body = UpdateDeviceTokenRequest(deviceToken: token)
        let _: EmptyResponse = try await network.request(
            path: "/auth/device-token",
            method: "PUT",
            body: body
        )
    }
    
    // MARK: - Notification Settings
    
    /// GET /api/notification/settings - Bildirim ayarları
    func getNotificationSettings() async throws -> NotificationSettingsResponse {
        return try await network.request(path: "/notification/settings")
    }
    
    /// PUT /api/notification/settings - Bildirim ayarlarını güncelle
    func updateNotificationSettings(
        enabled: Bool? = nil,
        ilceId: String? = nil,
        offsetMinutes: Int? = nil,
        contentType: String? = nil,
        fajrEnabled: Bool? = nil,
        dhuhrEnabled: Bool? = nil,
        asrEnabled: Bool? = nil,
        maghribEnabled: Bool? = nil,
        ishaEnabled: Bool? = nil
    ) async throws -> NotificationSettingsResponse {
        let body = UpdateNotificationSettingsRequest(
            enabled: enabled,
            ilceId: ilceId,
            offsetMinutes: offsetMinutes,
            contentType: contentType,
            fajrEnabled: fajrEnabled,
            dhuhrEnabled: dhuhrEnabled,
            asrEnabled: asrEnabled,
            maghribEnabled: maghribEnabled,
            ishaEnabled: ishaEnabled
        )
        return try await network.request(
            path: "/notification/settings",
            method: "PUT",
            body: body
        )
    }
    
    // MARK: - Location Endpoints (Public)
    
    /// GET /api/public/location/countries
    func getCountries() async throws -> [DiyanetUlke] {
        return try await network.request(
            path: "/public/location/countries",
            requiresAuth: false
        )
    }
    
    /// GET /api/public/location/cities
    func getCities(ulkeId: String) async throws -> [DiyanetSehir] {
        print("🌆 getCities called with ulkeId: \(ulkeId)")
        let result: [DiyanetSehir] = try await network.request(
            path: "/public/location/cities?ulkeId=\(ulkeId)",
            requiresAuth: false
        )
        print("🌆 getCities returned \(result.count) cities, sample: \(result.prefix(3).map { "\($0.SehirAdi)(\($0.SehirID))" })")
        return result
    }
    
    /// GET /api/public/location/districts
    func getDistricts(ilId: String) async throws -> [DiyanetIlce] {
        print("🏙️ getDistricts called with ilId: \(ilId)")
        let result: [DiyanetIlce] = try await network.request(
            path: "/public/location/districts?ilId=\(ilId)",
            requiresAuth: false
        )
        print("🏙️ getDistricts returned \(result.count) districts, first: \(result.first?.IlceAdi ?? "-")")
        return result
    }
    
    // MARK: - Subscription
    
    /// GET /api/subscription/status
    func getSubscriptionStatus() async throws -> SubscriptionStatusResponse {
        return try await network.request(path: "/subscription/status")
    }
    
    /// POST /api/subscription/verify
    func verifyReceipt(
        receiptData: String,
        productId: String
    ) async throws -> SubscriptionStatusResponse {
        let body = VerifyReceiptRequest(
            receiptData: receiptData,
            productId: productId
        )
        return try await network.request(
            path: "/subscription/verify",
            method: "POST",
            body: body
        )
    }
}
// MARK: - Helper

struct EmptyResponse: Codable {}

