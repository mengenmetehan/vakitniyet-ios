import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: PrayerStore
    @State private var showLocationPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Header
                    HeaderView()
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    
                    // MARK: Error Message
                    if let error = store.errorMessage {
                        ErrorBanner(message: error)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }

                    // MARK: Konum Uyarısı
                    if store.selectedIlceId == nil && !store.isLoading {
                        Button { showLocationPicker = true } label: {
                            LocationBanner()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }

                    // MARK: Sonraki namaz
                    NextPrayerCard()
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    // MARK: Bugünkü namazlar
                    SectionLabel("Bugün")
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    if store.isLoading && store.prayers.isEmpty {
                        ProgressView()
                            .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(store.prayers) { prayer in
                                PrayerRow(prayer: prayer)
                                    .onTapGesture { store.toggle(prayer) }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }

                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 16)

                    // MARK: Aylık takvim
                    MonthCalendarView()
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
            }
            .refreshable {
                await store.refresh()
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView()
            }
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Location Banner

struct LocationBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "location.slash.fill")
                .foregroundColor(Color(hex: "3B6D11"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Namaz vakitleri için konum gerekli")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("Ayarlar'dan ilçenizi seçin")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(hex: "3B6D11").opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "3B6D11").opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var store: PrayerStore

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Vakit Niyet")
                    .font(.system(size: 26, weight: .semibold))
                Text(store.todayDateString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Streak pill
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                    Text("\(store.streak) günlük seri")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "854F0B"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "FAEEDA"))
                .clipShape(Capsule())
                .padding(.top, 6)
            }
            Spacer()
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(store.donePrayerCount) / 5.0)
                    .stroke(Color(hex: "3B6D11"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(store.donePrayerCount)/5")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "3B6D11"))
            }
            .frame(width: 52, height: 52)
        }
    }
}

// MARK: - Next Prayer Card

struct NextPrayerCard: View {
    @EnvironmentObject var store: PrayerStore

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sıradaki namaz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let next = store.nextPrayer {
                    Text(next.name.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                } else {
                    Text("Tamamlandı")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "3B6D11"))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let next = store.nextPrayer {
                    Text(next.time)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                    Text("Bugün kalan: \(5 - store.donePrayerCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "3B6D11"))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Prayer Row

struct PrayerRow: View {
    let prayer: Prayer

    var body: some View {
        HStack(spacing: 12) {
            // İkon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(prayer.isDone
                          ? Color(hex: "EAF3DE")
                          : Color(.secondarySystemBackground))
                    .frame(width: 36, height: 36)
                Image(systemName: prayer.name.icon)
                    .font(.system(size: 15))
                    .foregroundColor(prayer.isDone
                                     ? Color(hex: "3B6D11")
                                     : prayer.name.iconColor)
            }

            // İsim & saat
            VStack(alignment: .leading, spacing: 1) {
                Text(prayer.name.rawValue)
                    .font(.system(size: 15, weight: .medium))
                Text(prayer.time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Checkmark
            ZStack {
                Circle()
                    .stroke(prayer.isDone
                            ? Color(hex: "3B6D11")
                            : Color(.systemGray4),
                            lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                if prayer.isDone {
                    Circle()
                        .fill(Color(hex: "3B6D11"))
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: prayer.isDone)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(prayer.isDone
                    ? Color(.secondarySystemBackground)
                    : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .animation(.easeInOut(duration: 0.15), value: prayer.isDone)
    }
}

// MARK: - Month Calendar

struct MonthCalendarView: View {
    @EnvironmentObject var store: PrayerStore
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pa"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(store.monthYearString)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }

            // Gün başlıkları
            HStack(spacing: 4) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Günler grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Ayın ilk günü Pazartesi'den başlatmak için offset
                let offset = monthStartOffset()
                ForEach(0..<offset, id: \.self) { _ in
                    Color.clear.frame(height: 38)
                }
                ForEach(store.monthRecords) { record in
                    DayCell(record: record)
                }
            }
        }
    }

    private func monthStartOffset() -> Int {
        let cal = Calendar.current
        guard let first = store.monthRecords.first else { return 0 }
        // weekday: 1=Sun, 2=Mon... → convert to Mon=0
        let wd = cal.component(.weekday, from: first.date)
        return (wd + 5) % 7
    }
}

struct DayCell: View {
    let record: MonthDayRecord

    private var isToday: Bool {
        Calendar.current.isDateInToday(record.date)
    }
    private var isFuture: Bool { record.prayersDone < 0 }
    private var dayNumber: String {
        String(Calendar.current.component(.day, from: record.date))
    }

    var body: some View {
        VStack(spacing: 3) {
            Text(dayNumber)
                .font(.system(size: 11, weight: isToday ? .semibold : .regular))
                .foregroundStyle(isFuture ? .tertiary : .primary)

            if !isFuture {
                // 5 nokta
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(i < record.prayersDone
                                  ? Color(hex: "3B6D11")
                                  : Color(.systemGray5))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isToday ? Color(hex: "3B6D11") : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
                .kerning(0.5)
            Spacer()
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(PrayerStore())
}

