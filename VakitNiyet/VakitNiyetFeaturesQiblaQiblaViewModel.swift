//
//  QiblaViewModel.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import Foundation
import CoreLocation
import Combine

/// ViewModel for Qibla compass view
class QiblaViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let compassManager = CompassManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        // Forward compassManager's objectWillChange to our own
        // This ensures the view updates when compassManager's @Published properties change
        compassManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    /// Check if compass needs calibration
    var needsCalibration: Bool {
        return compassManager.headingAccuracy < 0 || compassManager.headingAccuracy > 20
    }
    
    /// Arrow rotation angle (Qibla direction relative to device heading)
    var arrowRotationAngle: Double {
        guard let location = compassManager.userLocation else {
            return 0
        }
        
        let qiblaAngle = QiblaService.qiblaAngle(from: location)
        let deviceHeading = compassManager.trueHeading
        
        // Calculate relative angle
        let rotation = qiblaAngle - deviceHeading
        
        // Normalize to 0-360
        let normalized = rotation.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
    
    /// Qibla direction text
    var qiblaDirectionText: String {
        guard let location = compassManager.userLocation else {
            return "Konum bekleniyor..."
        }
        
        let qiblaAngle = QiblaService.qiblaAngle(from: location)
        let direction = QiblaService.cardinalDirection(from: qiblaAngle)
        
        return "Kıble: \(direction)"
    }
    
    /// Current heading text
    var currentHeadingText: String {
        let heading = compassManager.trueHeading
        let direction = QiblaService.cardinalDirection(from: heading)
        
        return "\(direction): \(Int(heading))°"
    }
    
    /// Authorization status message
    var authorizationMessage: String? {
        switch compassManager.authorizationStatus {
        case .notDetermined:
            return "Kıble yönünü gösterebilmek için konum izninize ihtiyacımız var."
        case .restricted, .denied:
            return "Kıble yönü için konum izni gereklidir. Ayarlar'dan konum erişimini açın."
        case .authorizedWhenInUse, .authorizedAlways:
            return nil
        @unknown default:
            return nil
        }
    }
    
    /// Check if location is available
    var hasLocation: Bool {
        return compassManager.userLocation != nil
    }
    
    // MARK: - Methods
    
    /// Start compass updates
    func startUpdates() {
        compassManager.startUpdates()
    }
    
    /// Stop compass updates
    func stopUpdates() {
        compassManager.stopUpdates()
    }
    
    /// Request location permission
    func requestPermission() {
        compassManager.requestPermission()
    }
}
