//
//  QiblaView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import SwiftUI

struct QiblaView: View {
    
    @StateObject private var viewModel = QiblaViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D1F16")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Kıble")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Spacer()
                
                // Main Compass
                if let authMessage = viewModel.authorizationMessage {
                    // Permission needed
                    VStack(spacing: 20) {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "2D6A4F"))
                        
                        Text(authMessage)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            viewModel.requestPermission()
                        }) {
                            Text("Konum İzni Ver")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color(hex: "1B4332"))
                                .cornerRadius(12)
                        }
                    }
                } else if !viewModel.hasLocation {
                    // Loading location
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "2D6A4F")))
                            .scaleEffect(1.5)
                        
                        Text("Konum alınıyor...")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else {
                    // Compass
                    compassView
                }
                
                Spacer()
                
                // Direction info
                if viewModel.hasLocation {
                    VStack(spacing: 12) {
                        Text(viewModel.qiblaDirectionText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "2D6A4F"))
                        
                        Text(viewModel.currentHeadingText)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                }
                
                // Calibration warning
                if viewModel.needsCalibration && viewModel.hasLocation {
                    calibrationBanner
                }
            }
        }
        .onAppear {
            viewModel.startUpdates()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
    }
    
    // MARK: - Compass View
    
    private var compassView: some View {
        ZStack {
            // Outer circle with tick marks
            compassRing
            
            // Qibla arrow
            qiblaArrow
                .rotationEffect(.degrees(viewModel.arrowRotationAngle))
                .animation(.easeInOut(duration: 0.3), value: viewModel.arrowRotationAngle)
            
            // Center Kaaba icon
            Image(systemName: "cube.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "1B4332"))
                .shadow(color: Color(hex: "2D6A4F").opacity(0.5), radius: 10)
        }
        .frame(width: 280, height: 280)
    }
    
    // MARK: - Compass Ring
    
    private var compassRing: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(hex: "1B4332").opacity(0.3), lineWidth: 2)
                .frame(width: 280, height: 280)
            
            Circle()
                .fill(Color(hex: "0D1F16"))
                .frame(width: 260, height: 260)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "2D6A4F").opacity(0.2), lineWidth: 1)
                )
            
            // Tick marks (every 30 degrees = 12 marks)
            ForEach(0..<12) { index in
                Rectangle()
                    .fill(Color.white.opacity(index % 3 == 0 ? 0.8 : 0.3))
                    .frame(width: index % 3 == 0 ? 2 : 1, height: index % 3 == 0 ? 15 : 10)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
            
            // Cardinal directions (N, E, S, W)
            // Kuzey (North) - Üstte
            Text("K")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .offset(y: -145)
            
            // Doğu (East) - Sağda
            Text("D")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: 145)
            
            // Güney (South) - Altta
            Text("G")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .offset(y: 145)
            
            // Batı (West) - Solda
            Text("B")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: -145)
        }
    }
    
    // MARK: - Qibla Arrow
    
    private var qiblaArrow: some View {
        ZStack {
            // Arrow shaft
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "2D6A4F"),
                            Color(hex: "1B4332")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 100)
                .offset(y: -50)
            
            // Arrow head (triangle)
            Triangle()
                .fill(Color(hex: "1B4332"))
                .frame(width: 30, height: 30)
                .offset(y: -110)
                .shadow(color: Color(hex: "2D6A4F").opacity(0.5), radius: 5)
            
            // Crescent on arrow tip
            Image(systemName: "moon.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .offset(y: -110)
        }
    }
    
    // MARK: - Calibration Banner
    
    private var calibrationBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Puslayı kalibre edin")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text("Telefonu 8 şeklinde hareket ettirin")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview

#Preview {
    QiblaView()
}
