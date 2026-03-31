//
//  LaunchScreenView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 28.03.2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background gradient - SignInView ile aynı
            LinearGradient(
                colors: [
                    Color(hex: "534AB7"),
                    Color(hex: "27500A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Static image (eğer Assets'e eklediyseniz)
            // Image("LaunchIcon")
            //     .resizable()
            //     .scaledToFit()
            //     .padding(60)
            
            // Geçici: SF Symbol (Assets'e görsel ekleyene kadar)
            VStack(spacing: 20) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)

                Text("Vakit Niyet")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Namaz Takip Uygulaması")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    LaunchScreenView()
}



