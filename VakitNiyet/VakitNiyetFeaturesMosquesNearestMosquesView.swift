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
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "3B6D11"))
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mosque.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Text(mosque.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

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
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
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

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 180, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 11)
            }

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
