import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: PrayerStore

    // Mock istatistik verileri
    private let weeklyData: [(String, Int)] = [
        ("Pt", 5), ("Sa", 4), ("Ça", 5), ("Pe", 3), ("Cu", 5), ("Ct", 5), ("Pa", 2)
    ]
    private let prayerMissed: [(PrayerName, Int)] = [
        (.fajr, 8), (.dhuhr, 2), (.asr, 3), (.maghrib, 1), (.isha, 4)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Özet kartlar
                    HStack(spacing: 12) {
                        StatCard(title: "Bu ay", value: "87", unit: "namaz")
                        StatCard(title: "En uzun seri", value: "18", unit: "gün")
                        StatCard(title: "Tamamlama", value: "91", unit: "%")
                    }
                    .padding(.horizontal)

                    // Haftalık bar chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bu hafta")
                            .font(.system(size: 14, weight: .medium))

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(weeklyData, id: \.0) { day, count in
                                VStack(spacing: 4) {
                                    Text("\(count)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(count == 5
                                                         ? Color(hex: "3B6D11")
                                                         : .secondary)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(count == 5
                                              ? Color(hex: "3B6D11")
                                              : Color(hex: "C0DD97"))
                                        .frame(height: CGFloat(count) * 18)
                                    Text(day)
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

                    // En çok kaçırılan namaz
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bu ay kaçırılan")
                            .font(.system(size: 14, weight: .medium))

                        ForEach(prayerMissed, id: \.0) { name, count in
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
                                                .frame(width: geo.size.width * CGFloat(count) / 10)
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
                    .padding(.bottom, 32)
                }
                .padding(.top, 8)
            }
            .navigationTitle("İstatistik")
            .navigationBarTitleDisplayMode(.large)
        }
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

