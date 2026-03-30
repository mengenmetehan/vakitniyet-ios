//
//  ContentView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 27.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = PrayerStore()
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Label("Bugün", systemImage: "circle")
                }
                .tag(0)

            // 🧭 Kıble Bulucu
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
                .tag(1)

            // 📿 Zikirmatik
            ZikirmatikView()
                .tabItem {
                    Label("Zikirmatik", systemImage: "circle.dotted")
                }
                .tag(2)

            // 🕌 En Yakın Camiler
            NavigationStack {
                NearestMosquesView()
            }
            .tabItem {
                Label("Camiler", systemImage: "building.columns.fill")
            }
            .tag(3)

            StatsView()
                .tabItem {
                    Label("İstatistik", systemImage: "chart.bar.fill")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .tint(Color(hex: "3B6D11"))
        .environmentObject(store)
        .environmentObject(appState)
    }
}
#Preview {
    ContentView()
        .environmentObject(AppState())
}

