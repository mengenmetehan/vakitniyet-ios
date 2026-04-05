//
//  LocationAutoDetectService.swift
//  VakitNiyet
//

import Foundation
import CoreLocation

// MARK: - One-Time Location Fetcher

class LocationAutoFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func getLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                cont.resume(throwing: LocationAutoDetectError.permissionDenied)
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
            continuation?.resume(throwing: LocationAutoDetectError.permissionDenied)
            continuation = nil
        default:
            break
        }
    }
}

// MARK: - Errors

enum LocationAutoDetectError: LocalizedError {
    case permissionDenied
    case geocodingFailed(String)
    case cityNotFound(String)
    case districtNotFound(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Konum izni verilmedi. Ayarlar > VakitNiyet > Konum'dan izin verin."
        case .geocodingFailed(let reason):
            return "Şehir adı alınamadı: \(reason)"
        case .cityNotFound(let city):
            return "'\(city)' şehri Diyanet listesinde bulunamadı. Manuel seçin."
        case .districtNotFound(let district):
            return "'\(district)' ilçesi eşleştirilemedi. Manuel seçin."
        }
    }
}

// MARK: - Service

struct LocationAutoDetectService {
    private let api = PrayerAPIService.shared
    private let trLocale = Locale(identifier: "tr_TR")

    /// GPS konumunu alır, Diyanet API ile eşleştirir ve ilçe döner.
    func detect() async throws -> DiyanetIlce {
        // Adım 1: GPS
        let fetcher = LocationAutoFetcher()
        let location = try await fetcher.getLocation()

        // Adım 2: Reverse geocode
        let geocoder = CLGeocoder()
        let placemarks: [CLPlacemark]
        do {
            placemarks = try await geocoder.reverseGeocodeLocation(location)
        } catch {
            throw LocationAutoDetectError.geocodingFailed("Adım 2: Geocoding — \(error.localizedDescription)")
        }
        guard let placemark = placemarks.first else {
            throw LocationAutoDetectError.geocodingFailed("Adım 2: Geocoding sonuç boş")
        }

        let rawCity = placemark.administrativeArea ?? ""
        let rawDistrict = placemark.subAdministrativeArea ?? placemark.locality ?? ""

        // Adım 3: Ülke listesi
        let countries: [DiyanetUlke]
        do {
            countries = try await api.getCountries()
        } catch {
            throw LocationAutoDetectError.geocodingFailed("Adım 3: Ülke listesi — \(error.localizedDescription)")
        }

        guard let turkey = countries.first(where: {
            $0.UlkeAdi.uppercased().contains("TÜRK") || $0.UlkeAdi.uppercased().contains("TURK")
        }) else {
            let names = countries.prefix(3).map { $0.UlkeAdi }.joined(separator: ", ")
            throw LocationAutoDetectError.geocodingFailed("Adım 3: Türkiye bulunamadı. İlk ülkeler: \(names)")
        }

        // Adım 4: Şehir listesi
        let cities: [DiyanetSehir]
        do {
            cities = try await api.getCities(ulkeId: turkey.UlkeID)
        } catch {
            throw LocationAutoDetectError.geocodingFailed("Adım 4: Şehir listesi — \(error.localizedDescription)")
        }

        guard let matchedCity = cities.first(where: { match($0.SehirAdi, rawCity) }) else {
            throw LocationAutoDetectError.cityNotFound("Adım 4: '\(rawCity)' eşleşmedi")
        }

        // Adım 5: İlçe listesi
        let districts: [DiyanetIlce]
        do {
            districts = try await api.getDistricts(ilId: matchedCity.SehirID)
        } catch {
            throw LocationAutoDetectError.geocodingFailed("Adım 5: İlçe listesi (\(matchedCity.SehirAdi), ID:\(matchedCity.SehirID)) — \(error.localizedDescription)")
        }

        // Adım 6: İlçe eşleştir
        guard let matchedDistrict = districts.first(where: { match($0.IlceAdi, rawDistrict) }) else {
            let sample = districts.prefix(3).map { $0.IlceAdi }.joined(separator: ", ")
            throw LocationAutoDetectError.districtNotFound("Adım 6: '\(rawDistrict)' eşleşmedi. İlk ilçeler: \(sample)")
        }

        return matchedDistrict
    }

    private func match(_ a: String, _ b: String) -> Bool {
        guard !b.isEmpty else { return false }
        let x = a.uppercased()
        let y = b.uppercased()
        return x == y || x.contains(y) || y.contains(x)
    }
}
