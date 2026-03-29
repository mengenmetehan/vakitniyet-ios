//
//  QiblaService.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import Foundation
import CoreLocation

// MARK: - Double Extension

extension Double {
    /// Convert degrees to radians
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    /// Convert radians to degrees
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
}

// MARK: - Qibla Service

/// Service for calculating Qibla (prayer direction toward Mecca)
struct QiblaService {
    
    /// Mecca coordinates
    private static let makkah = CLLocationCoordinate2D(
        latitude: 21.4225,
        longitude: 39.8262
    )
    
    /// Calculate Qibla angle from user's location
    /// - Parameter coordinate: User's current location
    /// - Returns: Angle in degrees (0-360, clockwise from North)
    static func qiblaAngle(from coordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = coordinate.latitude.toRadians()
        let lat2 = makkah.latitude.toRadians()
        let deltaLon = (makkah.longitude - coordinate.longitude).toRadians()
        
        // Spherical haversine bearing formula
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        
        let angle = atan2(y, x).toDegrees()
        
        // Normalize to 0-360
        return (angle + 360).truncatingRemainder(dividingBy: 360)
    }
    
    /// Get cardinal direction from angle
    /// - Parameter degrees: Angle in degrees (0-360)
    /// - Returns: Cardinal direction in Turkish
    static func cardinalDirection(from degrees: Double) -> String {
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        
        switch normalized {
        case 0..<22.5, 337.5...360:
            return "Kuzey"
        case 22.5..<67.5:
            return "Kuzeydoğu"
        case 67.5..<112.5:
            return "Doğu"
        case 112.5..<157.5:
            return "Güneydoğu"
        case 157.5..<202.5:
            return "Güney"
        case 202.5..<247.5:
            return "Güneybatı"
        case 247.5..<292.5:
            return "Batı"
        case 292.5..<337.5:
            return "Kuzeybatı"
        default:
            return "Kuzey"
        }
    }
}
