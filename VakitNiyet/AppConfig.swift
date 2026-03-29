import Foundation

enum AppConfig {
    // MARK: - Environment Variables
    
    /// .env dosyasından yüklenen değişkenler
    private static let env: [String: String] = {
        #if DEBUG
        return EnvironmentLoader.loadEnv(filename: ".env.development")
        #else
        return EnvironmentLoader.loadEnv(filename: ".env.production")
        #endif
    }()
    
    // MARK: - API Configuration
    
    /// Backend API base URL
    /// .env.development veya .env.production dosyasından runtime'da okunur
    /// Dosyayı düzenleyip uygulamayı yeniden başlatın
    static let baseURL: String = {
        // .env dosyasından oku
        if let url = env["BASE_URL"], !url.isEmpty {
            print("✅ BASE_URL loaded from .env: \(url)")
            return url
        }
        
        // Fallback: .env dosyası yoksa varsayılan değerler
        #if DEBUG
        let fallbackURL = "http://localhost:3000/v1/api"
        print("⚠️ .env dosyasında BASE_URL bulunamadı! Fallback kullanılıyor: \(fallbackURL)")
        return fallbackURL
        #else
        let fallbackURL = "https://api.vakitniyet.com/v1/api"
        print("⚠️ .env dosyasında BASE_URL bulunamadı! Fallback kullanılıyor: \(fallbackURL)")
        return fallbackURL
        #endif
    }()
    
    // MARK: - App Information
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Feature Flags
    
    static let enableNotifications = true
    static let enableAppleSignIn = true
    static let enableLocationServices = true
    
    // MARK: - Debug Settings
    
    #if DEBUG
    static let isDebugMode = true
    static let enableVerboseLogging = true
    #else
    static let isDebugMode = false
    static let enableVerboseLogging = false
    #endif
}
