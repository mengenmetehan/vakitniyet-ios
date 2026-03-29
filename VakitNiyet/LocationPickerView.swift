import SwiftUI

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
    @State private var errorMessage: String?
    
    private let api = PrayerAPIService.shared
    
    var body: some View {
        NavigationStack {
            List {
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
            .onChange(of: selectedCountry) { _, newValue in
                if let country = newValue {
                    Task {
                        await loadCities(ulkeId: country.UlkeID)
                    }
                }
            }
            .onChange(of: selectedCity) { _, newValue in
                if let city = newValue {
                    Task {
                        await loadDistricts(ilId: city.SehirID)
                    }
                }
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
}

#Preview {
    LocationPickerView()
        .environmentObject(PrayerStore())
}
