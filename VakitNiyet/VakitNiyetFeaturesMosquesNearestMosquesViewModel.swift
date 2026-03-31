//
//  NearestMosquesViewModel.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 30.03.2026.
//

import Foundation
import CoreLocation
import MapKit
import Combine

// MARK: - One-time Location Fetcher

private class MosqueLocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    func getLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                cont.resume(throwing: MosqueLocationError.denied)
                self.continuation = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        continuation?.resume(returning: loc)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(throwing: MosqueLocationError.denied)
            continuation = nil
        default:
            break
        }
    }

    enum MosqueLocationError: LocalizedError {
        case denied
        var errorDescription: String? { "Konum izni verilmedi. Ayarlar'dan konum erişimini açın." }
    }
}

// MARK: - ViewModel

@MainActor
class NearestMosquesViewModel: ObservableObject {

    @Published var mosques: [MosqueDto] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.015137, longitude: 28.979530), // İstanbul default
        span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
    )

    private(set) var userLocation: CLLocationCoordinate2D?
    private var fetcher: MosqueLocationFetcher?
    private let service = MosqueService.shared

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        let location: CLLocation
        do {
            let f = MosqueLocationFetcher()
            fetcher = f
            location = try await f.getLocation()
            fetcher = nil
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return
        }

        userLocation = location.coordinate
        updateRegion(center: location.coordinate)

        do {
            mosques = try await service.getNearby(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        } catch {
            self.error = "Camiler yüklenemedi: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func retry() {
        Task { await load() }
    }

    // MARK: - Region Helpers

    private func updateRegion(center: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        )
    }
}
