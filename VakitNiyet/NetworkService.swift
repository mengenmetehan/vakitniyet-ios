import Foundation

// MARK: - Network Service

actor NetworkService {
    
    static let shared = NetworkService()
    
    private var accessToken: String?
    private var refreshToken: String?
    
    private let baseURL = AppConfig.baseURL

    private init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
    }
    
    // MARK: - Token Management
    
    nonisolated var isLoggedIn: Bool {
        UserDefaults.standard.string(forKey: "accessToken") != nil
    }
    
    func saveTokens(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
        UserDefaults.standard.set(access, forKey: "accessToken")
        UserDefaults.standard.set(refresh, forKey: "refreshToken")
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
    
    // MARK: - Generic Request
    
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let fullURL = baseURL + path
        print("🌐 Request: \(method) \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("❌ Invalid URL: \(fullURL)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        if requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Has Token: YES")
        } else {
            print("🔑 Has Token: NO")
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response")
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 401, requiresAuth {
            try await refreshAccessToken()
            return try await self.request(path: path, method: method, body: body, requiresAuth: requiresAuth)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // DEBUG: Response data log
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 API Response (\(path)):")
            print(jsonString)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let result = try decoder.decode(T.self, from: data)
        
        print("✅ Decoded successfully: \(T.self)")
        
        return result
    }
    
    private func refreshAccessToken() async throws {
        guard let refreshToken = refreshToken else {
            throw NetworkError.unauthorized
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await request(
            path: "/auth/refresh",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        
        saveTokens(access: response.accessToken, refresh: response.refreshToken)
    }
}

// MARK: - API Response Models

struct DayResponse: Codable {
    let date: String
    let prayers: [PrayerLogResponse]
    let doneCount: Int
}

struct PrayerLogResponse: Codable {
    let prayerName: String
    let date: String
    let isDone: Bool
    let prayedAt: String?
}

struct MonthResponse: Codable {
    let year: Int?
    let month: Int?
    let days: [DaySummary]
    let prevYear: Int?
    let prevMonth: Int?
    let nextYear: Int?
    let nextMonth: Int?
}

struct DaySummary: Codable {
    let date: String
    let doneCount: Int
    let prayers: [DonePrayer]?
}

struct DonePrayer: Codable {
    let prayerName: String
    let prayedAt: String?
}

struct StreakResponse: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let lastFullDay: String?
}

struct StatsResponse: Codable {
    let streak: StreakResponse
    let thisMonthTotal: Int
    let thisMonthDays: Int
    let completionRate: Int
    let mostMissed: String?
}

struct PrayerTimesResponse: Codable {
    let date: String
    let ilceId: String
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String
}

struct SubscriptionInfo: Codable {
    let plan: String
    let status: String
    let isActive: Bool
    let trialDaysLeft: Int?
    let currentPeriodEnd: String?
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: String
    let name: String?
    let subscription: SubscriptionInfo
}

struct TokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
}

struct NotificationSettingsResponse: Codable {
    let enabled: Bool
    let ilceId: String?
    let offsetMinutes: Int
    let contentType: String
    let fajrEnabled: Bool
    let dhuhrEnabled: Bool
    let asrEnabled: Bool
    let maghribEnabled: Bool
    let ishaEnabled: Bool
}

struct SubscriptionStatusResponse: Codable {
    let plan: String
    let status: String
    let isActive: Bool
    let trialDaysLeft: Int?
    let currentPeriodEnd: String?
}

// Location Models
struct DiyanetUlke: Codable, Equatable, Hashable {
    let UlkeID: String
    let UlkeAdi: String
}

struct DiyanetSehir: Codable, Equatable, Hashable {
    let SehirID: String
    let SehirAdi: String
}

struct DiyanetIlce: Codable, Equatable, Hashable {
    let IlceID: String
    let IlceAdi: String
}

// MARK: - API Request Models

struct TogglePrayerRequest: Codable {
    let prayerName: String
    let date: String?
}

struct AppleSignInRequest: Codable {
    let identityToken: String
    let authorizationCode: String
    let name: String?
    let deviceToken: String?
}

struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
}

struct UpdateDeviceTokenRequest: Codable {
    let deviceToken: String
}

struct UpdateNotificationSettingsRequest: Codable {
    let enabled: Bool?
    let ilceId: String?
    let offsetMinutes: Int?
    let contentType: String?
    let fajrEnabled: Bool?
    let dhuhrEnabled: Bool?
    let asrEnabled: Bool?
    let maghribEnabled: Bool?
    let ishaEnabled: Bool?
}

struct VerifyReceiptRequest: Codable {
    let receiptData: String
    let productId: String
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .invalidResponse:
            return "Geçersiz sunucu yanıtı"
        case .httpError(let code):
            return "Sunucu hatası: \(code)"
        case .decodingError(let error):
            return "Veri işleme hatası: \(error.localizedDescription)"
        case .unauthorized:
            return "Oturum süresi doldu"
        case .unknown:
            return "Bilinmeyen hata"
        }
    }
}
