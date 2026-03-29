//
//  VakitNiyetWidgets.swift
//  VakitNiyetWidgets
//
//  Created by Metehan Mengen on 29.03.2026.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Shared Helpers

private let appGroup = "group.com.metehanmengen.vakitniyet"
private var sharedDefaults: UserDefaults { UserDefaults(suiteName: appGroup)! }

private func todayDateString() -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f.string(from: Date())
}

// MARK: - Color Extension

extension Color {
    init(widgetHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Zikirmatik AppIntent

struct IncrementZikirIntent: AppIntent {
    static var title: LocalizedStringResource = "Zikir Çek"
    static var description = IntentDescription("Zikir sayacını bir artırır.")
    static var isDiscoverable: Bool = false

    func perform() async throws -> some IntentResult {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return .result() }
        let today = todayDateString()
        let storedDate = defaults.string(forKey: "zikirDate") ?? ""
        let current = storedDate == today ? defaults.integer(forKey: "zikirCount") : 0
        defaults.set(current + 1, forKey: "zikirCount")
        defaults.set(today, forKey: "zikirDate")
        return .result()
    }
}

// ──────────────────────────────────────────────
// MARK: - Prayer Times Widget
// ──────────────────────────────────────────────

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nextPrayerName: String
    let nextPrayerTime: String
    let allPrayers: [(name: String, time: String)]
}

struct PrayerTimesProvider: TimelineProvider {

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: .now, nextPrayerName: "Akşam", nextPrayerTime: "18:42", allPrayers: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let entry = makeEntry()
        let nextRefresh: Date
        if let nextDate = nextPrayerDate(prayers: entry.allPrayers) {
            nextRefresh = nextDate
        } else {
            nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        }
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func makeEntry() -> PrayerEntry {
        let prayers = loadPrayers()
        let (name, time) = findNextPrayer(from: prayers)
        return PrayerEntry(date: .now, nextPrayerName: name, nextPrayerTime: time, allPrayers: prayers)
    }

    private func loadPrayers() -> [(name: String, time: String)] {
        guard let data = sharedDefaults.data(forKey: "widgetPrayerTimes"),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else { return [] }
        return raw.compactMap { dict in
            guard let name = dict["name"], let time = dict["time"] else { return nil }
            return (name: name, time: time)
        }
    }

    private func findNextPrayer(from prayers: [(name: String, time: String)]) -> (String, String) {
        let cal = Calendar.current
        let now = Date()
        let cur = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        for prayer in prayers {
            guard prayer.time != "--:--" else { continue }
            let parts = prayer.time.split(separator: ":")
            guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { continue }
            if h * 60 + m > cur { return (prayer.name, prayer.time) }
        }
        return prayers.first.map { ($0.name, $0.time) } ?? ("—", "--:--")
    }

    private func nextPrayerDate(prayers: [(name: String, time: String)]) -> Date? {
        let cal = Calendar.current
        let now = Date()
        let cur = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        for prayer in prayers {
            guard prayer.time != "--:--" else { continue }
            let parts = prayer.time.split(separator: ":")
            guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { continue }
            if h * 60 + m > cur { return cal.date(bySettingHour: h, minute: m, second: 0, of: now) }
        }
        return nil
    }
}

struct PrayerTimesSmallView: View {
    let entry: PrayerEntry
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(widgetHex: "0D1F16"), Color(widgetHex: "1B4332")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 4) {
                Text("Sıradaki Namaz")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text(entry.nextPrayerName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(widgetHex: "2D6A4F"))
                Text(entry.nextPrayerTime)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct PrayerTimesMediumView: View {
    let entry: PrayerEntry
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(widgetHex: "0D1F16"), Color(widgetHex: "1B4332")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sıradaki Namaz")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text(entry.nextPrayerName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(widgetHex: "2D6A4F"))
                    Text(entry.nextPrayerTime)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    ForEach(entry.allPrayers.prefix(5), id: \.name) { prayer in
                        HStack(spacing: 6) {
                            Text(prayer.name)
                                .font(.system(size: 11))
                            Text(prayer.time)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(prayer.name == entry.nextPrayerName
                            ? .white
                            : .white.opacity(0.4))
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PrayerTimesWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerEntry
    var body: some View {
        switch family {
        case .systemMedium: PrayerTimesMediumView(entry: entry)
        default:            PrayerTimesSmallView(entry: entry)
        }
    }
}

struct PrayerTimesWidget: Widget {
    let kind = "PrayerTimesWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimesProvider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(Color(widgetHex: "0D1F16"), for: .widget)
        }
        .configurationDisplayName("Sıradaki Namaz")
        .description("Bir sonraki namaz vaktini gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ──────────────────────────────────────────────
// MARK: - Zikirmatik Widget
// ──────────────────────────────────────────────

struct ZikirEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct ZikirProvider: TimelineProvider {
    func placeholder(in context: Context) -> ZikirEntry { ZikirEntry(date: .now, count: 33) }
    func getSnapshot(in context: Context, completion: @escaping (ZikirEntry) -> Void) { completion(makeEntry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ZikirEntry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        completion(Timeline(entries: [makeEntry()], policy: .after(midnight)))
    }
    private func makeEntry() -> ZikirEntry {
        let today = todayDateString()
        let stored = sharedDefaults.string(forKey: "zikirDate") ?? ""
        let count = stored == today ? sharedDefaults.integer(forKey: "zikirCount") : 0
        return ZikirEntry(date: .now, count: count)
    }
}

struct ZikirmatikWidgetView: View {
    let entry: ZikirEntry
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(widgetHex: "0D1F16"), Color(widgetHex: "152B1C")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 0) {
                Text("Zikirmatik")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("\(entry.count)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Bugün")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Button(intent: IncrementZikirIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Zikir")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(widgetHex: "1B4332"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color(widgetHex: "2D6A4F"), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
        }
    }
}

struct ZikirmatikWidget: Widget {
    let kind = "ZikirmatikWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ZikirProvider()) { entry in
            ZikirmatikWidgetView(entry: entry)
                .containerBackground(Color(widgetHex: "0D1F16"), for: .widget)
        }
        .configurationDisplayName("Zikirmatik")
        .description("Günlük zikir sayacı. Ana ekrandan zikir çekin.")
        .supportedFamilies([.systemSmall])
    }
}
