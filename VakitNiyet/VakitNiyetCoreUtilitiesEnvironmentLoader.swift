//
//  EnvironmentLoader.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import Foundation

// Bundle.main is @MainActor in Swift 6, so we use Bundle(for:) to avoid propagating
// the @MainActor isolation to AppConfig.baseURL and callers like NetworkService.
private final class _EnvLoaderAnchor {}

/// .env dosyasından environment variable'ları yükler
enum EnvironmentLoader {
    
    /// .env dosyasını yükle ve parse et
    /// - Parameter filename: .env dosyasının adı (default: ".env")
    /// - Returns: Key-value dictionary
    static func loadEnv(filename: String = ".env") -> [String: String] {
        var envVars: [String: String] = [:]
        
        // .env dosyasının yolunu bul
        guard let envPath = findEnvFile(filename: filename) else {
            print("⚠️ \(filename) dosyası bulunamadı")
            return envVars
        }
        
        print("📄 Loading environment from: \(envPath)")
        
        // Dosyayı oku
        guard let contents = try? String(contentsOfFile: envPath, encoding: .utf8) else {
            print("❌ \(filename) dosyası okunamadı")
            return envVars
        }
        
        // Satır satır parse et
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Boş satır veya yorum satırı ise atla
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            // KEY=VALUE formatını parse et
            let parts = trimmed.components(separatedBy: "=")
            guard parts.count >= 2 else { continue }
            
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
            
            // Tırnak işaretlerini temizle (varsa)
            let cleanValue = value
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            envVars[key] = cleanValue
        }
        
        print("✅ Loaded \(envVars.count) environment variables")
        return envVars
    }
    
    /// .env dosyasını bul (önce proje root, sonra bundle)
    private static func findEnvFile(filename: String) -> String? {
        let bundle = Bundle(for: _EnvLoaderAnchor.self)

        // 1. Bundle içinde ara (Xcode'da Add Files yapıldıysa)
        if let bundlePath = bundle.path(forResource: filename.replacingOccurrences(of: ".env", with: ""), ofType: "env") {
            return bundlePath
        }

        // 2. Bundle içinde direkt .env dosyası ara
        if let bundlePath = bundle.path(forResource: filename, ofType: nil) {
            return bundlePath
        }

        // 3. Proje root dizininde ara (development için)
        #if DEBUG
        let fileManager = FileManager.default
        if let projectPath = bundle.resourcePath?.replacingOccurrences(of: "Build/Products/Debug-iphonesimulator/VakitNiyet.app", with: "") {
            let envPath = projectPath + filename
            if fileManager.fileExists(atPath: envPath) {
                return envPath
            }
            
            // Bir üst dizini de dene
            let parentPath = (projectPath as NSString).deletingLastPathComponent + "/" + filename
            if fileManager.fileExists(atPath: parentPath) {
                return parentPath
            }
        }
        #endif
        
        // 4. Documents dizininde ara (runtime'da eklendiyse)
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let envPath = documentsPath.appendingPathComponent(filename).path
            if FileManager.default.fileExists(atPath: envPath) {
                return envPath
            }
        }
        
        return nil
    }
    
    /// Belirli bir key'i al
    static func get(_ key: String, from env: [String: String]) -> String? {
        return env[key]
    }
}
