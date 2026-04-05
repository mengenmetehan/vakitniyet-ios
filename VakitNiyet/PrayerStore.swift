import Foundation
import SwiftUI
import Combine
import WidgetKit

class PrayerStore: ObservableObject {

    // MARK: - Published state

    @Published var prayers: [Prayer] = []
    @Published var monthRecords: [MonthDayRecord] = []
    @Published var streak: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var notificationsEnabled: Bool = false
    @Published var notificationOffset: Int = 10        // dakika
    @Published var notificationContent: String = "karma" // "hadis" | "ayet" | "karma"
    @Published var enabledPrayers: [PrayerName: Bool] = Dictionary(
        uniqueKeysWithValues: PrayerName.allCases.map { ($0, true) }
    )
    
    // MARK: - Location (for prayer times)
    @Published var selectedIlceId: String?

    // MARK: - Dependencies
    
    private let api = PrayerAPIService.shared
    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    private let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    // MARK: - Init

    init() {
        loadSelectedLocation()
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Initial Load
    
    @MainActor
    private func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        
        print("📋 Loading initial data...")
        
        do {
            // Paralel olarak bugünün namazları ve streak bilgisini al
            async let todayResponse = api.getToday()
            async let streakResponse = api.getStreak()
            
            let (today, streakData) = try await (todayResponse, streakResponse)
            
            print("✅ Today response: \(today.prayers.count) prayers")
            
            // Today's prayers
            prayers = today.prayers.map { prayerLog in
                Prayer(
                    id: prayerLog.prayerName,
                    name: mapPrayerName(prayerLog.prayerName),
                    time: extractTime(from: prayerLog.date),
                    isDone: prayerLog.isDone
                )
            }
            
            print("📍 Prayer times before Diyanet: \(prayers.map { "\($0.name.rawValue): \($0.time)" })")
            
            // Eğer prayer times endpoint'i varsa, zamanları oradan al
            if let ilceId = selectedIlceId {
                print("🌍 Fetching prayer times for ilceId: \(ilceId)")
                try await loadPrayerTimes(ilceId: ilceId)
                print("📍 Prayer times after Diyanet: \(prayers.map { "\($0.name.rawValue): \($0.time)" })")
            } else {
                print("⚠️ No ilceId selected - using backend times only")
            }
            
            // Streak
            streak = streakData.currentStreak
            print("🔥 Streak: \(streak)")
            
            // Bildirim ayarlarını API'den çek
            await syncNotificationSettings()

            // Month records
            await loadMonthRecords()

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load error: \(error)")
            // Fallback to mock data if needed during development
            loadMockData()
        }
        
        isLoading = false
    }
    
    // MARK: - Load Prayer Times (from Diyanet)
    
    @MainActor
    private func loadPrayerTimes(ilceId: String) async throws {
        print("🕌 Fetching Diyanet times for ilceId: \(ilceId)")
        
        let times = try await api.getTodayTimes(ilceId: ilceId)
        
        print("✅ Diyanet response:")
        print("   Imsak: \(times.imsak)")
        print("   Öğle: \(times.ogle)")
        print("   İkindi: \(times.ikindi)")
        print("   Akşam: \(times.aksam)")
        print("   Yatsı: \(times.yatsi)")
        
        // Backend'den gelen Diyanet vakitleri ile local Prayer modellerini güncelle
        updatePrayerTime(for: .fajr, time: times.imsak)
        updatePrayerTime(for: .dhuhr, time: times.ogle)
        updatePrayerTime(for: .asr, time: times.ikindi)
        updatePrayerTime(for: .maghrib, time: times.aksam)
        updatePrayerTime(for: .isha, time: times.yatsi)
        
        print("✅ Prayer times updated from Diyanet")
        saveToWidget(prayers)
    }

    private func saveToWidget(_ prayers: [Prayer]) {
        guard let defaults = UserDefaults(suiteName: "group.com.metehanmengen.vakitniyet") else { return }
        let data = prayers.map { ["name": $0.name.rawValue, "time": $0.time] }
        if let encoded = try? JSONSerialization.data(withJSONObject: data) {
            defaults.set(encoded, forKey: "widgetPrayerTimes")
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "PrayerTimesWidget")
    }
    
    private func updatePrayerTime(for name: PrayerName, time: String) {
        if let idx = prayers.firstIndex(where: { $0.name == name }) {
            prayers[idx] = Prayer(
                id: prayers[idx].id,
                name: prayers[idx].name,
                time: time,
                isDone: prayers[idx].isDone
            )
        }
    }

    // MARK: - Load Month Records

    @MainActor
    func loadMonthRecords(year: Int? = nil, month: Int? = nil) async {
        let cal = Calendar.current
        let today = Date()
        let y = year ?? cal.component(.year, from: today)
        let m = month ?? cal.component(.month, from: today)

        do {
            let response = try await api.getMonth(year: y, month: m)
            monthRecords = response.days.compactMap { day -> MonthDayRecord? in
                guard let date = dateFmt.date(from: day.date) else { return nil }
                return MonthDayRecord(date: date, prayersDone: day.doneCount)
            }
        } catch {
            print("❌ Month load error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Actions

    func toggle(_ prayer: Prayer) {
        print("🔄 Toggle called for: \(prayer.name.rawValue)")
        
        Task {
            // Optimistic update
            if let idx = prayers.firstIndex(where: { $0.id == prayer.id }) {
                prayers[idx].isDone.toggle()
                
                // Backend'e gönder
                do {
                    let response = try await api.togglePrayer(
                        name: mapPrayerNameToAPI(prayer.name),
                        date: nil // nil = bugün
                    )
                    
                    print("✅ Toggle response: \(response.isDone)")
                    
                    // Backend'den gelen sonucu uygula
                    prayers[idx].isDone = response.isDone
                    
                    // Streak ve month'u güncelle
                    await updateStreakAndMonth()
                } catch {
                    print("❌ Toggle error: \(error)")
                    errorMessage = error.localizedDescription
                    
                    // Revert optimistic update
                    prayers[idx].isDone.toggle()
                }
            } else {
                print("❌ Prayer not found: \(prayer.id)")
            }
        }
    }
    
    @MainActor
    private func updateLocalStats() async {
        // Test mode için local stats güncelleme
        let done = prayers.filter { $0.isDone }.count
        let cal = Calendar.current
        if let idx = monthRecords.firstIndex(where: { cal.isDateInToday($0.date) }) {
            monthRecords[idx] = MonthDayRecord(date: monthRecords[idx].date, prayersDone: done)
        }
        
        // Basit streak hesaplama
        if done == 5 {
            streak += 1
        }
    }

    @MainActor
    private func updateStreakAndMonth() async {
        // Reload today's count
        let done = prayers.filter { $0.isDone }.count
        let cal = Calendar.current
        if let idx = monthRecords.firstIndex(where: { cal.isDateInToday($0.date) }) {
            monthRecords[idx] = MonthDayRecord(date: monthRecords[idx].date, prayersDone: done)
        }
        
        // Reload streak from backend
        do {
            let streakData = try await api.getStreak()
            streak = streakData.currentStreak
        } catch {
            print("❌ Streak update error: \(error)")
        }
    }

    // MARK: - Refresh
    
    func refresh() async {
        await loadInitialData()
    }
    
    // MARK: - Notification Settings Sync
    
    @MainActor
    func syncNotificationSettings() async {
        do {
            let settings = try await api.getNotificationSettings()
            notificationsEnabled = settings.enabled && settings.ilceId != nil
            notificationOffset = settings.offsetMinutes
            notificationContent = settings.contentType
            UserDefaults(suiteName: "group.com.metehanmengen.vakitniyet")?
                .set(settings.offsetMinutes, forKey: "notificationOffset")
            selectedIlceId = settings.ilceId
            
            enabledPrayers[.fajr] = settings.fajrEnabled
            enabledPrayers[.dhuhr] = settings.dhuhrEnabled
            enabledPrayers[.asr] = settings.asrEnabled
            enabledPrayers[.maghrib] = settings.maghribEnabled
            enabledPrayers[.isha] = settings.ishaEnabled
            
        } catch {
            print("❌ Notification settings sync error: \(error)")
        }
    }
    
    @MainActor
    func updateNotificationSettings() async {
        // Backend'e gönder
        do {
            let _ = try await api.updateNotificationSettings(
                enabled: notificationsEnabled,
                ilceId: selectedIlceId,
                offsetMinutes: notificationOffset,
                contentType: notificationContent,
                fajrEnabled: enabledPrayers[.fajr],
                dhuhrEnabled: enabledPrayers[.dhuhr],
                asrEnabled: enabledPrayers[.asr],
                maghribEnabled: enabledPrayers[.maghrib],
                ishaEnabled: enabledPrayers[.isha]
            )
            print("✅ Notification settings updated")
        } catch {
            print("❌ Notification settings update error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Properties

    var donePrayerCount: Int { prayers.filter { $0.isDone }.count }

    var nextPrayer: Prayer? { prayers.first { !$0.isDone } }

    var allDone: Bool { prayers.allSatisfy { $0.isDone } }

    var todayDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f.string(from: Date()).capitalized
    }

    var monthYearString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date()).capitalized
    }
    
    // MARK: - Location Persistence
    
    private func loadSelectedLocation() {
        selectedIlceId = UserDefaults.standard.string(forKey: "selectedIlceId")
    }
    
    func saveSelectedLocation(_ ilceId: String) {
        selectedIlceId = ilceId
        UserDefaults.standard.set(ilceId, forKey: "selectedIlceId")
        
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Helpers
    
    private func mapPrayerName(_ apiName: String) -> PrayerName {
        // Backend "Sabah", "Öğle" gibi Türkçe isimler kullanıyor
        // veya "fajr", "dhuhr" gibi İngilizce isimler kullanabilir
        // API response'a göre ayarlayın
        switch apiName.lowercased() {
        case "sabah", "fajr", "imsak":
            return .fajr
        case "öğle", "ogle", "dhuhr":
            return .dhuhr
        case "ikindi", "asr":
            return .asr
        case "akşam", "aksam", "maghrib":
            return .maghrib
        case "yatsı", "yatsi", "isha":
            return .isha
        default:
            return .fajr
        }
    }
    
    private func mapPrayerNameToAPI(_ name: PrayerName) -> String {
        // Backend'in beklediği formata göre (İngilizce UPPERCASE)
        switch name {
        case .fajr:    return "FAJR"
        case .dhuhr:   return "DHUHR"
        case .asr:     return "ASR"
        case .maghrib: return "MAGHRIB"
        case .isha:    return "ISHA"
        }
    }
    
    private func extractTime(from dateString: String) -> String {
        print("🕐 Extracting time from: '\(dateString)'")
        
        // Eğer zaten sadece saat formatındaysa direkt döndür (HH:mm)
        if dateString.range(of: "^\\d{2}:\\d{2}$", options: .regularExpression) != nil {
            print("   ✅ Already in HH:mm format: \(dateString)")
            return dateString
        }
        
        // ISO8601 date parse et (2026-03-28T06:12:00)
        let iso8601 = ISO8601DateFormatter()
        if let date = iso8601.date(from: dateString) {
            let result = timeFmt.string(from: date)
            print("   ✅ Parsed ISO8601 → \(result)")
            return result
        }
        
        // "T" ile ayır ve son kısmı al (saat kısmı)
        if let timePart = dateString.components(separatedBy: "T").last,
           timePart != dateString, // "T" yoksa skip et
           timePart.count >= 5 {
            let timeOnly = String(timePart.prefix(5))
            print("   ✅ Extracted from T separator → \(timeOnly)")
            return timeOnly
        }
        
        // Sadece tarih varsa (2026-03-28), placeholder saat döndür
        if dateString.range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil {
            print("   ⚠️ Date only, no time - returning placeholder")
            return "--:--"
        }
        
        print("   ⚠️ Failed to parse, returning 00:00")
        return "00:00"
    }
    
    // MARK: - Mock Fallback (development)
    
    private func loadMockData() {
        prayers = [
            Prayer(id: "1", name: .fajr,    time: "06:12", isDone: false),
            Prayer(id: "2", name: .dhuhr,   time: "13:15", isDone: false),
            Prayer(id: "3", name: .asr,     time: "15:42", isDone: false),
            Prayer(id: "4", name: .maghrib, time: "18:52", isDone: false),
            Prayer(id: "5", name: .isha,    time: "20:18", isDone: false),
        ]
        
        let cal = Calendar.current
        let today = Date()
        guard let range = cal.range(of: .day, in: .month, for: today),
              let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: today))
        else { return }

        monthRecords = range.compactMap { day -> MonthDayRecord? in
            guard let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) else { return nil }
            let isPast = date <= today
            let count: Int
            if cal.isDateInToday(date) {
                count = prayers.filter { $0.isDone }.count
            } else if isPast {
                count = [5, 5, 4, 5, 3, 5, 5, 2, 4, 5][day % 10]
            } else {
                count = 0
            }
            return MonthDayRecord(date: date, prayersDone: isPast ? count : -1)
        }
        
        streak = 0
    }
}
