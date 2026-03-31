//
//  NearestMosquesView.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 30.03.2026.
//

import SwiftUI
import MapKit

struct NearestMosquesView: View {

    @StateObject private var viewModel = NearestMosquesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Map
            mapSection
                .frame(height: UIScreen.main.bounds.height * 0.35)

            Divider()

            // MARK: Content
            ZStack {
                if viewModel.isLoading {
                    skeletonList
                } else if let error = viewModel.error {
                    errorState(message: error)
                } else if viewModel.mosques.isEmpty {
                    emptyState
                } else {
                    mosqueList
                }
            }
        }
        .navigationTitle("En Yakın Camiler")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    // MARK: - Map

    private var mapSection: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.mosques
        ) { mosque in
            MapAnnotation(coordinate: mosque.coordinate) {
                MosquePinView(name: mosque.name)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Mosque List

    private var mosqueList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.mosques) { mosque in
                    MosqueRow(mosque: mosque)
                    Divider().padding(.leading, 60)
                }
            }
        }
    }

    // MARK: - Skeleton

    private var skeletonList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonRow()
                    Divider().padding(.leading, 60)
                }
            }
        }
    }

    // MARK: - Error State

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Tekrar Dene") { viewModel.retry() }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "3B6D11"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.columns")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Yakında cami bulunamadı")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Mosque Row

private struct MosqueRow: View {
    let mosque: MosqueDto

    var body: some View {
        Button(action: openInMaps) {
            HStack(spacing: 12) {
                MosqueShape()
                    .fill(Color(hex: "3B6D11"))
                    .frame(width: 22, height: 22)
                    .frame(width: 36)

                Text(mosque.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                Text(mosque.distanceText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "3B6D11"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "3B6D11").opacity(0.1))
                    .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private func openInMaps() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: mosque.coordinate))
        item.name = mosque.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Map Pin

private struct MosquePinView: View {
    let name: String

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1B4332"))
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                MosqueShape()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
            }
            MosqueTriangle()
                .fill(Color(hex: "1B4332"))
                .frame(width: 8, height: 6)
        }
    }
}

// MARK: - Skeleton Row

private struct SkeletonRow: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 36)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray4))
                .frame(width: 180, height: 14)

            Spacer()

            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray4))
                .frame(width: 50, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                opacity = 0.7
            }
        }
    }
}

// MARK: - Mosque Silhouette Shape

private struct MosqueShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()

        // Minaret tip (pointed triangle)
        p.move(to: CGPoint(x: w * 0.02, y: h * 0.22))
        p.addLine(to: CGPoint(x: w * 0.10, y: h * 0.04))
        p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.22))
        p.closeSubpath()

        // Minaret shaft
        p.addRect(CGRect(x: w * 0.04, y: h * 0.22, width: w * 0.12, height: h * 0.78))

        // Main building body
        p.addRect(CGRect(x: w * 0.22, y: h * 0.55, width: w * 0.76, height: h * 0.45))

        // Dome (semicircle via Bézier – avoids clockwise ambiguity)
        let cx = w * 0.60, cy = h * 0.55, r = w * 0.24
        let k: CGFloat = 0.5523
        p.move(to: CGPoint(x: cx - r, y: cy))
        p.addCurve(to: CGPoint(x: cx, y: cy - r),
                   control1: CGPoint(x: cx - r, y: cy - r * k),
                   control2: CGPoint(x: cx - r * k, y: cy - r))
        p.addCurve(to: CGPoint(x: cx + r, y: cy),
                   control1: CGPoint(x: cx + r * k, y: cy - r),
                   control2: CGPoint(x: cx + r, y: cy - r * k))
        p.closeSubpath()

        return p
    }
}

// MARK: - Pin Triangle

private struct MosqueTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NearestMosquesView()
    }
}
