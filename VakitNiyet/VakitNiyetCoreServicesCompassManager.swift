//
//  CompassManager.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import Foundation
import CoreLocation
import Combine

/// Manager for compass heading and location updates
class CompassManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current device heading (0-360 degrees from true North)
    @Published var trueHeading: Double = 0
    
    /// User's current location
    @Published var userLocation: CLLocationCoordinate2D?
    
    /// Heading accuracy (-1 = invalid, positive = degrees of accuracy)
    @Published var headingAccuracy: Double = -1
    
    /// Authorization status
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check current authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        // Request permission if needed
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Start updates if authorized
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdates()
        }
    }
    
    // MARK: - Public Methods
    
    /// Start compass and location updates
    func startUpdates() {
        print("📍 Starting compass updates")
        locationManager.startUpdatingLocation()
        
        // Check if heading is available
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
            print("🧭 Compass heading updates started")
        } else {
            print("⚠️ Compass not available on this device")
        }
    }
    
    /// Stop compass and location updates
    func stopUpdates() {
        print("📍 Stopping compass updates")
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    /// Request location permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension CompassManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Update heading
        if newHeading.trueHeading >= 0 {
            trueHeading = newHeading.trueHeading
        } else {
            // Use magnetic heading if true heading is not available
            trueHeading = newHeading.magneticHeading
        }
        
        // Update accuracy
        headingAccuracy = newHeading.headingAccuracy
        
        // Debug log (only in debug mode)
        #if DEBUG
        if headingAccuracy < 0 || headingAccuracy > 20 {
            print("⚠️ Compass needs calibration - accuracy: \(headingAccuracy)")
        }
        #endif
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLocation = location.coordinate
        
        // Stop location updates after getting first location (we only need it once for Qibla)
        // Keep heading updates running
        manager.stopUpdatingLocation()
        
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        print("📍 Authorization status changed: \(authorizationStatus.rawValue)")
        
        // Start updates if authorized
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdates()
        }
    }
}
