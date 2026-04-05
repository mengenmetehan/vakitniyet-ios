import Foundation
import SwiftUI

// MARK: - Prayer

enum PrayerName: String, CaseIterable, Identifiable {
    case fajr    = "Sabah"
    case dhuhr   = "Öğle"
    case asr     = "İkindi"
    case maghrib = "Akşam"
    case isha    = "Yatsı"

    var id: String { rawValue }

    var apiName: String {
        switch self {
        case .fajr:    return "FAJR"
        case .dhuhr:   return "DHUHR"
        case .asr:     return "ASR"
        case .maghrib: return "MAGHRIB"
        case .isha:    return "ISHA"
        }
    }

    var icon: String {
        switch self {
        case .fajr:    return "moon.stars.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .fajr:    return Color(hex: "534AB7")
        case .dhuhr:   return Color(hex: "BA7517")
        case .asr:     return Color(hex: "854F0B")
        case .maghrib: return Color(hex: "993C1D")
        case .isha:    return Color(hex: "27500A")
        }
    }
}

struct Prayer: Identifiable {
    let id: String
    let name: PrayerName
    let time: String
    var isDone: Bool = false
    
    // Manuel oluşturma (mock data için)
    init(id: String = UUID().uuidString, name: PrayerName, time: String, isDone: Bool = false) {
        self.id = id
        self.name = name
        self.time = time
        self.isDone = isDone
    }
}

// MARK: - DayRecord (UI Model)

struct MonthDayRecord: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    var prayersDone: Int  // 0–5 or -1 for future
    
    // Manuel oluşturma
    init(date: Date, prayersDone: Int) {
        self.date = date
        self.prayersDone = prayersDone
    }
}

// MARK: - DateFormatter helpers

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

// MARK: - Color hex helper

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hexString: Hex color string (e.g., "1B4332", "#2D6A4F")
    static func hex(_ hexString: String) -> Color {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
