import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: PrayerStore

    @State private var stats: StatsResponse?
    @State private var monthDays: [DaySummary] = []
    @State private var isLoading = true

    private let api = PrayerAPIService.shared
    private let cal = Calendar.current

    // Son 7 gün (bugün dahil, geçmişten bugüne)
    private var weeklyData: [(label: String, count: Int)] {
        let today = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dayFmt = DateFormatter()
        dayFmt.locale = Locale(identifier: "tr_TR")
        dayFmt.dateFormat = "EEE"

        return (0..<7).reversed().map { offset -> (String, Int) in
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else {
                return ("-", 0)
            }
            let dateStr = fmt.string(from: date)
            let label = dayFmt.string(from: date).prefix(2).uppercased()
            let count = monthDays.first(where: { $0.date == dateStr })?.doneCount ?? 0
            return (String(label), count)
        }
    }

    // Bu ay her namaz için kaçırılma sayısı
    private var missedByPrayer: [(PrayerName, Int)] {
        let pastDays = monthDays.filter {
            guard let date = ISO8601DateFormatter().date(from: $0.date + "T00:00:00Z")
                    ?? DateFormatter.yyyyMMdd.date(from: $0.date)
            else { return false }
            return date <= Date()
        }
        guard !pastDays.isEmpty else { return [] }

        let allNames: [PrayerName] = [.fajr, .dhuhr, .asr, .maghrib, .isha]
        return allNames.map { prayerName in
            let apiName = prayerName.apiName
            let doneCount = pastDays.filter { day in
                (day.prayers ?? []).contains(where: { $0.prayerName.uppercased() == apiName })
            }.count
            let missed = pastDays.count - doneCount
            return (prayerName, missed)
        }.filter { $0.1 > 0 }
         .sorted { $0.1 > $1.1 }
    }

    private var maxMissed: Int { missedByPrayer.map(\.1).max() ?? 1 }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView().padding(.top, 60)
                } else {
                    VStack(spacing: 20) {

                        // Özet kartlar
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Bu ay",
                                value: "\(stats?.thisMonthTotal ?? 0)",
                                unit: "namaz"
                            )
                            StatCard(
                                title: "En uzun seri",
                                value: "\(stats?.streak.longestStreak ?? 0)",
                                unit: "gün"
                            )
                            StatCard(
                                title: "Tamamlama",
                                value: "\(stats?.completionRate ?? 0)",
                                unit: "%"
                            )
                        }
                        .padding(.horizontal)

                        // Haftalık bar chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son 7 gün")
                                .font(.system(size: 14, weight: .medium))

                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(weeklyData, id: \.label) { item in
                                    VStack(spacing: 4) {
                                        Text("\(item.count)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(item.count == 5
                                                             ? Color(hex: "3B6D11")
                                                             : .secondary)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(item.count == 5
                                                  ? Color(hex: "3B6D11")
                                                  : Color(hex: "C0DD97"))
                                            .frame(height: max(4, CGFloat(item.count) * 18))
                                        Text(item.label)
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 130, alignment: .bottom)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)

                        // Bu ay kaçırılan
                        if !missedByPrayer.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Bu ay kaçırılan")
                                    .font(.system(size: 14, weight: .medium))

                                ForEach(missedByPrayer, id: \.0) { name, count in
                                    HStack(spacing: 10) {
                                        Image(systemName: name.icon)
                                            .font(.system(size: 13))
                                            .foregroundColor(name.iconColor)
                                            .frame(width: 20)
                                        Text(name.rawValue)
                                            .font(.system(size: 14))
                                        Spacer()
                                        GeometryReader { geo in
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(hex: "EAF3DE"))
                                                .frame(width: geo.size.width)
                                                .overlay(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(hex: "3B6D11"))
                                                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(max(maxMissed, 1)))
                                                }
                                        }
                                        .frame(width: 100, height: 8)
                                        Text("\(count)x")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, alignment: .trailing)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("İstatistik")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await load()
            }
            .refreshable {
                await load()
            }
        }
    }

    private func load() async {
        isLoading = true
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        async let statsResult = api.getStats()
        async let monthResult = api.getMonth(year: year, month: month)
        stats = try? await statsResult
        monthDays = (try? await monthResult)?.days ?? []
        isLoading = false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "27500A"))
            Text(unit)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
#Preview {
    StatsView()
        .environmentObject(PrayerStore())
}

