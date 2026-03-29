//
//  ZikirmatikView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import SwiftUI

struct ZikirmatikView: View {

    @StateObject private var viewModel: ZikirmatikViewModel
    @State private var showResetAlert = false
    @State private var isPressed = false

    init() {
        _viewModel = StateObject(wrappedValue: ZikirmatikViewModel())
    }

    var body: some View {
        ZStack {
            Color(hex: "0D1F16")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Başlık
                Text("Zikirmatik")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 60)

                Spacer()

                // Sayaç
                VStack(spacing: 8) {
                    Text("\(viewModel.count)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.count)

                    Text("Bugün")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Tap Butonu
                Button(action: handleTap) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1B4332"))
                            .frame(width: 220, height: 220)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "2D6A4F"), lineWidth: 2)
                            )
                            .shadow(color: Color(hex: "2D6A4F").opacity(0.4), radius: isPressed ? 8 : 20)

                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 52))
                            .foregroundColor(Color(hex: "2D6A4F"))
                    }
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .buttonStyle(.plain)

                Spacer()

                // Sıfırla Butonu
                Button(action: { showResetAlert = true }) {
                    Text("Sıfırla")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                }
                .padding(.bottom, 48)
            }
        }
        .alert("Sayacı Sıfırla", isPresented: $showResetAlert) {
            Button("Sıfırla", role: .destructive) { viewModel.reset() }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Bugünkü zikir sayacı sıfırlanacak.")
        }
    }

    private func handleTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        isPressed = true
        viewModel.increment()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }
    }
}

#Preview {
    ZikirmatikView()
}
