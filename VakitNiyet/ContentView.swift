//
//  ContentView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 27.03.2026.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = PrayerStore()
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    // Pre-rendered mosque silhouette for tab bar (minaret + dome)
    private static let mosqueTabUIImage: UIImage = {
        let size = CGSize(width: 30, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { _ in
            let w = size.width, h = size.height
            let path = UIBezierPath()
            // Minaret tip
            path.move(to: CGPoint(x: w * 0.02, y: h * 0.22))
            path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.04))
            path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.22))
            path.close()
            // Minaret shaft
            path.append(UIBezierPath(rect: CGRect(x: w * 0.04, y: h * 0.22, width: w * 0.12, height: h * 0.78)))
            // Main body
            path.append(UIBezierPath(rect: CGRect(x: w * 0.22, y: h * 0.55, width: w * 0.76, height: h * 0.45)))
            // Dome (Bézier semicircle)
            let cx = w * 0.60, cy = h * 0.55, r = w * 0.24, k: CGFloat = 0.5523
            let dome = UIBezierPath()
            dome.move(to: CGPoint(x: cx - r, y: cy))
            dome.addCurve(to: CGPoint(x: cx, y: cy - r),
                          controlPoint1: CGPoint(x: cx - r, y: cy - r * k),
                          controlPoint2: CGPoint(x: cx - r * k, y: cy - r))
            dome.addCurve(to: CGPoint(x: cx + r, y: cy),
                          controlPoint1: CGPoint(x: cx + r * k, y: cy - r),
                          controlPoint2: CGPoint(x: cx + r, y: cy - r * k))
            dome.close()
            path.append(dome)
            UIColor.black.setFill()
            path.fill()
        }
        return img.withRenderingMode(.alwaysTemplate)
    }()

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
                Label {
                    Text("Camiler")
                } icon: {
                    Image(uiImage: ContentView.mosqueTabUIImage)
                }
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

