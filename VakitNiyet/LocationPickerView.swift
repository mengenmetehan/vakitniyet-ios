import SwiftUI
import CoreLocation

// MARK: - One-time Location Fetcher

private class OneTimeLocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    func getLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            let status = manager.authorizationStatus
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            } else {
                cont.resume(throwing: LocationError.denied)
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
            continuation?.resume(throwing: LocationError.denied)
            continuation = nil
        default:
            break
        }
    }

    enum LocationError: LocalizedError {
        case denied
        var errorDescription: String? { "Konum izni verilmedi. Ayarlar'dan izin verin." }
    }
}

// MARK: - Location Picker View

struct LocationPickerView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PrayerStore

    @State private var countries: [DiyanetUlke] = []
    @State private var cities: [DiyanetSehir] = []
    @State private var districts: [DiyanetIlce] = []

    @State private var selectedCountry: DiyanetUlke?
    @State private var selectedCity: DiyanetSehir?
    @State private var selectedDistrict: DiyanetIlce?

    @State private var isLoading = false
    @State private var isDetectingLocation = false
    @State private var errorMessage: String?
    @State private var locationFetcher: OneTimeLocationFetcher?

    private let api = PrayerAPIService.shared
    private let trLocale = Locale(identifier: "tr_TR")

    var body: some View {
        NavigationStack {
            List {
                // GPS Auto-detect
                Section {
                    Button(action: { Task { await autoDetectLocation() } }) {
                        HStack(spacing: 12) {
                            if isDetectingLocation {
                                ProgressView()
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color(hex: "3B6D11"))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("GPS ile Otomatik Seç")
                                    .foregroundColor(.primary)
                                Text("Bulunduğun ilçeyi otomatik bul")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isDetectingLocation)
                }

                // Country Selection
                Section {
                    if isLoading && countries.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Picker("Ülke", selection: $selectedCountry) {
                            Text("Seçiniz").tag(nil as DiyanetUlke?)
                            ForEach(countries, id: \.UlkeID) { country in
                                Text(country.UlkeAdi).tag(country as DiyanetUlke?)
                            }
                        }
                    }
                } header: {
                    Text("Ülke")
                }
                
                // City Selection
                if selectedCountry != nil {
                    Section {
                        if isLoading && cities.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Picker("Şehir", selection: $selectedCity) {
                                Text("Seçiniz").tag(nil as DiyanetSehir?)
                                ForEach(cities, id: \.SehirID) { city in
                                    Text(city.SehirAdi).tag(city as DiyanetSehir?)
                                }
                            }
                        }
                    } header: {
                        Text("Şehir")
                    }
                }
                
                // District Selection
                if selectedCity != nil {
                    Section {
                        if isLoading && districts.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Picker("İlçe", selection: $selectedDistrict) {
                                Text("Seçiniz").tag(nil as DiyanetIlce?)
                                ForEach(districts, id: \.IlceID) { district in
                                    Text(district.IlceAdi).tag(district as DiyanetIlce?)
                                }
                            }
                        }
                    } header: {
                        Text("İlçe")
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Konum Seçimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveLocation()
                    }
                    .disabled(selectedDistrict == nil)
                }
            }
            .task {
                await loadCountries()
            }
            .onChange(of: selectedCountry) { country in
                guard let country else { return }
                Task { await loadCities(ulkeId: country.UlkeID) }
            }
            .onChange(of: selectedCity) { city in
                guard let city else { return }
                Task { await loadDistricts(ilId: city.SehirID) }
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadCountries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            countries = try await api.getCountries()
            
            // Türkiye'yi otomatik seç
            if let turkey = countries.first(where: { $0.UlkeAdi.contains("Türkiye") || $0.UlkeAdi.contains("Turkey") }) {
                selectedCountry = turkey
            }
        } catch {
            errorMessage = "Ülkeler yüklenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadCities(ulkeId: String) async {
        isLoading = true
        errorMessage = nil
        selectedCity = nil
        cities = []
        districts = []
        
        do {
            cities = try await api.getCities(ulkeId: ulkeId)
        } catch {
            errorMessage = "Şehirler yüklenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadDistricts(ilId: String) async {
        isLoading = true
        errorMessage = nil
        selectedDistrict = nil
        districts = []
        
        do {
            districts = try await api.getDistricts(ilId: ilId)
        } catch {
            errorMessage = "İlçeler yüklenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func saveLocation() {
        guard let district = selectedDistrict else { return }
        store.saveSelectedLocation(district.IlceID)
        dismiss()
    }

    // MARK: - GPS Auto-detect

    private func autoDetectLocation() async {
        isDetectingLocation = true
        errorMessage = nil
        defer { isDetectingLocation = false }

        // Ensure Turkey is loaded
        if countries.isEmpty {
            await loadCountries()
        }
        guard let turkey = selectedCountry else {
            errorMessage = "Ülke listesi yüklenemedi."
            return
        }
        if cities.isEmpty {
            await loadCities(ulkeId: turkey.UlkeID)
        }

        // Get device location
        let fetcher = OneTimeLocationFetcher()
        locationFetcher = fetcher
        defer { locationFetcher = nil }

        let location: CLLocation
        do {
            location = try await fetcher.getLocation()
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        // Reverse geocode
        let geocoder = CLGeocoder()
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            errorMessage = "Konum bilgisi alınamadı."
            return
        }

        let rawCity = placemark.administrativeArea ?? ""

        // Match city (case-insensitive, Turkish locale)
        guard let matchedCity = cities.first(where: { city in
            let a = city.SehirAdi.lowercased(with: trLocale)
            let b = rawCity.lowercased(with: trLocale)
            return a == b || a.contains(b) || b.contains(a)
        }) else {
            errorMessage = "'\(rawCity)' şehri Diyanet listesinde bulunamadı. Manuel seçin."
            return
        }

        selectedCity = matchedCity
        await loadDistricts(ilId: matchedCity.SehirID)

        // Try subLocality first, then locality as district name
        let rawDistrict = placemark.subLocality ?? placemark.locality ?? ""

        if let matchedDistrict = districts.first(where: { ilce in
            let a = ilce.IlceAdi.lowercased(with: trLocale)
            let b = rawDistrict.lowercased(with: trLocale)
            return a == b || a.contains(b) || b.contains(a)
        }) {
            selectedDistrict = matchedDistrict
        } else {
            // City matched but district not found — show list for manual selection
            errorMessage = "Şehir bulundu ama ilçe eşleştirilemedi. Listeden seçin."
        }
    }
}

#Preview {
    LocationPickerView()
        .environmentObject(PrayerStore())
}
