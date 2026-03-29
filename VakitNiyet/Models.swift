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

struct MonthDayRecord: Identifiable {
    let id = UUID()
    let date: Date
    var prayersDone: Int  // 0–5 or -1 for future
    
    // Manuel oluşturma
    init(date: Date, prayersDone: Int) {
        self.date = date
        self.prayersDone = prayersDone
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)         / 255
        self.init(red: r, green: g, blue: b)
    }
}
