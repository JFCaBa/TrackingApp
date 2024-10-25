//
//  TransportationMode.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Transportation mode enumeration and detection logic
//  Details: Defines transport types and provides mode detection algorithms
//

import Foundation
import UIKit

enum TransportationMode: String, Codable, CaseIterable {
    case automotive
    case cycling
    case walking
    case unknown
    
    var allCases: [TransportationMode] {
        return [.automotive, .cycling, .walking, .unknown]
    }
    
    var icon: String {
        switch self {
        case .automotive:
            return "car.fill"
        case .cycling:
            return "bicycle"
        case .walking:
            return "figure.walk"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .automotive:
            return .systemBlue
        case .cycling:
            return .systemGreen
        case .walking:
            return .systemOrange
        case .unknown:
            return .systemGray
        }
    }
    
    var speedRange: ClosedRange<Double> {
        switch self {
        case .walking:
            return 0...7
        case .cycling:
            return 7...25
        case .automotive:
            return 25...200
        case .unknown:
            return 0...0
        }
    }
    
    static func detect(speed: Double) -> TransportationMode {
        let speedKmh = speed * 3.6 // Convert m/s to km/h
        
        switch speedKmh {
        case 0..<7:
            return .walking
        case 7..<25:
            return .cycling
        case 25...:
            return .automotive
        default:
            return .unknown
        }
    }
    
    var displayName: String {
        switch self {
        case .automotive:
            return "Driving"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .unknown:
            return "Unknown"
        }
    }
    
    // Helper method to determine if a speed is typical for this mode
    func isTypicalSpeed(_ speed: Double) -> Bool {
        return speedRange.contains(speed)
    }
    
    // Helper method to get the average speed for this mode
    var typicalAverageSpeed: Double {
        switch self {
        case .walking:
            return 5.0 // 5 km/h
        case .cycling:
            return 15.0 // 15 km/h
        case .automotive:
            return 50.0 // 50 km/h
        case .unknown:
            return 0.0
        }
    }
    
    // Helper method to determine confidence in mode detection
    static func detectWithConfidence(
        averageSpeed: Double,
        maxSpeed: Double,
        distance: Double,
        duration: TimeInterval
    ) -> (mode: TransportationMode, confidence: Double) {
        let avgSpeedKmh = averageSpeed * 3.6
        let maxSpeedKmh = maxSpeed * 3.6
        
        // Calculate confidence based on multiple factors
        var bestMode = detect(speed: averageSpeed)
        var confidence = 0.0
        
        // Check if speeds are typical for the detected mode
        let isAvgSpeedTypical = bestMode.isTypicalSpeed(avgSpeedKmh)
        let isMaxSpeedTypical = bestMode.isTypicalSpeed(maxSpeedKmh)
        
        // Calculate base confidence
        if isAvgSpeedTypical && isMaxSpeedTypical {
            confidence = 0.8
        } else if isAvgSpeedTypical {
            confidence = 0.6
        } else if isMaxSpeedTypical {
            confidence = 0.4
        } else {
            confidence = 0.2
            bestMode = .unknown
        }
        
        // Adjust confidence based on trip duration and distance
        let minutes = duration / 60
        if minutes < 2 {
            confidence *= 0.5 // Very short trips are less reliable
        } else if minutes > 5 {
            confidence *= 1.2 // Longer trips are more reliable
        }
        
        // Cap confidence at 1.0
        confidence = min(confidence, 1.0)
        
        return (bestMode, confidence)
    }
}

// Extension for analytics and statistics
extension Array where Element == Trip {
    func groupedByTransportationMode() -> [TransportationMode: [Trip]] {
        return Dictionary(grouping: self) { $0.transportationMode }
    }
    
    func statistics(for mode: TransportationMode) -> (count: Int, totalDistance: Double, averageSpeed: Double)? {
        let modeTrips = filter { $0.transportationMode == mode }
        guard !modeTrips.isEmpty else { return nil }
        
        let count = modeTrips.count
        let totalDistance = modeTrips.reduce(0) { $0 + $1.distance }
        let averageSpeed = modeTrips.reduce(0) { $0 + $1.averageSpeed } / Double(count)
        
        return (count, totalDistance, averageSpeed)
    }
}
