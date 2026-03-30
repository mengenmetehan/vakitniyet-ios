//
//  MosqueService.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 30.03.2026.
//

import Foundation
import CoreLocation

// MARK: - Models

struct MosqueDto: Codable, Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let distanceMeters: Double
    let source: String  // MosqueSource enum string olarak decode edilir

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var distanceText: String {
        distanceMeters < 1000
            ? "\(Int(distanceMeters)) m"
            : String(format: "%.1f km", distanceMeters / 1000)
    }
}

private struct MosqueListResponse: Decodable {
    let mosques: [MosqueDto]
}

// MARK: - Service

struct MosqueService {
    static let shared = MosqueService()
    private let network = NetworkService.shared

    func getNearby(lat: Double, lon: Double, radius: Int = 5000) async throws -> [MosqueDto] {
        let response: MosqueListResponse = try await network.request(
            path: "/mosques?lat=\(lat)&lon=\(lon)&radius=\(radius)",
            requiresAuth: true
        )
        return response.mosques
    }
}
