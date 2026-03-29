//
//  VakitNiyetApp.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 27.03.2026.
//

import SwiftUI

@main
struct VakitNiyetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @State private var showSplash = true
    
    init() {
        // DEBUG: Token temizle (sadece test için)
        // UserDefaults.standard.removeObject(forKey: "accessToken")
        // UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isLoggedIn {
                    ContentView()
                        .environmentObject(appState)
                } else {
                    SignInView()
                        .environmentObject(appState)
                }
                
                // Splash Screen
                if showSplash {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                print("📱 App launched - isLoggedIn: \(appState.isLoggedIn)")
                
                // 2 saniye sonra splash screen'i kaldır
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
