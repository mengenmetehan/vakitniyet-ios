import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: PrayerStore
    @EnvironmentObject var appState: AppState
    @ObservedObject private var notificationManager = NotificationManager.shared

    private let offsets = [0, 5, 10, 15, 20, 30]

    @State private var showLocationPicker = false
    @State private var showLocationRequiredAlert = false

    private var hasLocation: Bool { store.selectedIlceId != nil }

    var body: some View {
        NavigationStack {
            List {

                // MARK: Konum
                Section {
                    Button {
                        showLocationPicker = true
                    } label: {
                        HStack {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Konum")
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                    if let ilceId = store.selectedIlceId {
                                        Text(ilceId)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Seçilmedi")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } icon: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Namaz Vakitleri")
                } footer: {
                    Text("Diyanet İşleri'nden doğru namaz vakitleri için konum seçin")
                }

                // MARK: Genel
                Section {
                    if !notificationManager.isAuthorized {
                        Button {
                            if !hasLocation {
                                showLocationRequiredAlert = true
                                return
                            }
                            Task { try? await notificationManager.requestPermission() }
                        } label: {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Bildirimleri Aç")
                                            .font(.system(size: 15))
                                            .foregroundColor(hasLocation ? .primary : .secondary)
                                        Text(hasLocation ? "Namaz vakti hatırlatmaları" : "Önce konum seçmelisiniz")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(Color.orange.opacity(hasLocation ? 0.2 : 0.1))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "bell.badge.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(hasLocation ? .orange : .secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: hasLocation ? "arrow.right" : "lock.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    } else {
                        Toggle(isOn: Binding(
                            get: { store.notificationsEnabled },
                            set: { newValue in
                                if newValue && !hasLocation {
                                    showLocationRequiredAlert = true
                                    return
                                }
                                store.notificationsEnabled = newValue
                                Task { await store.updateNotificationSettings() }
                            }
                        )) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Namaz bildirimleri")
                                        .font(.system(size: 15))
                                    Text(hasLocation ? "Tüm vakitler için aktif" : "Önce konum seçmelisiniz")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(hasLocation ? Color(hex: "3B6D11") : Color(.systemGray4))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .tint(Color(hex: "3B6D11"))
                        .disabled(!hasLocation && !store.notificationsEnabled)
                    }
                } header: {
                    Text("Genel")
                }

                // MARK: Hatırlatma süresi
                if store.notificationsEnabled {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Namazdan kaç dakika önce bildirilsin?")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(offsets, id: \.self) { offset in
                                    let label = offset == 0 ? "Tam vakitte" : "\(offset) dk önce"
                                    let isSelected = store.notificationOffset == offset
                                    
                                    Button {
                                        // Önce UI'ı güncelle
                                        withAnimation {
                                            store.notificationOffset = offset
                                        }
                                        // Sonra backend'e gönder
                                        Task {
                                            await store.updateNotificationSettings()
                                        }
                                    } label: {
                                        Text(label)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(isSelected
                                                             ? Color(hex: "27500A")
                                                             : .primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(isSelected
                                                         ? Color(hex: "EAF3DE")
                                                         : Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(isSelected
                                                            ? Color(hex: "3B6D11")
                                                            : Color.clear,
                                                            lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain) // Tıklama alanını genişlet
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Hatırlatma süresi")
                    }

                    // MARK: Vakit başına
                    Section {
                        ForEach(PrayerName.allCases) { name in
                            Toggle(isOn: Binding(
                                get: { store.enabledPrayers[name] ?? true },
                                set: { 
                                    store.enabledPrayers[name] = $0
                                    Task {
                                        await store.updateNotificationSettings()
                                    }
                                }
                            )) {
                                Label {
                                    Text(name.rawValue)
                                        .font(.system(size: 15))
                                } icon: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(name.iconColor.opacity(0.15))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: name.icon)
                                            .font(.system(size: 13))
                                            .foregroundColor(name.iconColor)
                                    }
                                }
                            }
                            .tint(Color(hex: "3B6D11"))
                        }
                    } header: {
                        Text("Vakit başına")
                    }

                    // MARK: Bildirim içeriği
                    Section {
                        ContentOptionRow(
                            title: "Sahih Hadis",
                            subtitle: "Buhari, Müslim, Tirmizi",
                            value: "hadis",
                            selected: $store.notificationContent
                        )
                        ContentOptionRow(
                            title: "Kuran Ayeti",
                            subtitle: "Türkçe mealiyle birlikte",
                            value: "ayet",
                            selected: $store.notificationContent
                        )
                        ContentOptionRow(
                            title: "Karışık",
                            subtitle: "Her bildirimde rastgele",
                            value: "karma",
                            selected: $store.notificationContent
                        )
                    } header: {
                        Text("Bildirim içeriği")
                    }

                    // MARK: Önizleme
                    Section {
                        NotificationPreviewCard()
                    } header: {
                        Text("Önizleme")
                    }
                    
                    // MARK: Test Bildirimi
                    Section {
                        Button {
                            Task {
                                do {
                                    try await notificationManager.scheduleTestNotification()
                                } catch {
                                    print("❌ Test notification error: \(error)")
                                }
                            }
                        } label: {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Test Bildirimi Gönder")
                                            .font(.system(size: 15))
                                            .foregroundColor(.primary)
                                        Text("5 saniye sonra bildirim gelecek")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(Color.purple.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "bell.badge.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(.purple)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    } header: {
                        Text("Geliştirici")
                    } footer: {
                        if let token = notificationManager.deviceToken {
                            Text("Device Token: \(token.prefix(20))...")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                // MARK: Uygulama
                Section {
                    LabeledContent("Sürüm", value: "1.0.0")
                    Link(destination: URL(string: "https://vakitniyet.app/gizlilik")!) {
                        Text("Gizlilik Politikası")
                    }
                } header: {
                    Text("Uygulama")
                }
                
                // MARK: Hesap
                Section {
                    if let userName = appState.userName {
                        LabeledContent("Hesap", value: userName)
                    }
                    
                    Button(role: .destructive) {
                        appState.signOut()
                    } label: {
                        Text("Çıkış Yap")
                    }
                } header: {
                    Text("Hesap")
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView()
            }
            .alert("Konum Gerekli", isPresented: $showLocationRequiredAlert) {
                Button("Konum Seç") { showLocationPicker = true }
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Namaz vakti bildirimleri alabilmek için önce konum seçmelisiniz.")
            }
        }
    }
}

// MARK: - Content Option Row

struct ContentOptionRow: View {
    let title: String
    let subtitle: String
    let value: String
    @Binding var selected: String
    @EnvironmentObject var store: PrayerStore

    var body: some View {
        Button {
            selected = value
            Task {
                await store.updateNotificationSettings()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(selected == value
                                ? Color(hex: "3B6D11")
                                : Color(.systemGray4),
                                lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if selected == value {
                        Circle()
                            .fill(Color(hex: "3B6D11"))
                            .frame(width: 11, height: 11)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: selected)
            }
        }
    }
}

// MARK: - Notification Preview Card

struct NotificationPreviewCard: View {
    @EnvironmentObject var store: PrayerStore

    private var offsetLabel: String {
        store.notificationOffset == 0
            ? "tam vaktinde"
            : "\(store.notificationOffset) dakika kaldı"
    }

    private var sampleText: String {
        switch store.notificationContent {
        case "ayet":
            return "\"Şüphesiz namaz, müminler üzerine vakitleri belirlenmiş bir farz olarak yazılmıştır.\""
        default:
            return "\"Amellerin en hayırlısı, az da olsa devamlı olanıdır.\""
        }
    }

    private var sampleSource: String {
        store.notificationContent == "ayet" ? "— Nisa, 103" : "— Buhari, 6465"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "27500A"))
                        .frame(width: 24, height: 24)
                    Text("V")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Vakit Niyet")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            Text("İkindi namazına \(offsetLabel)")
                .font(.system(size: 14, weight: .semibold))

            Text(sampleText)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            Text(sampleSource)
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .italic()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var timeString: String {
        let h = 15
        let m = 42 - store.notificationOffset
        let adjustedH = m < 0 ? h - 1 : h
        let adjustedM = m < 0 ? 60 + m : m
        return String(format: "%d:%02d", adjustedH, adjustedM)
    }
}
#Preview {
    SettingsView()
        .environmentObject(PrayerStore())
        .environmentObject(AppState())
}

