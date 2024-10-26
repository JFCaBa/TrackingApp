//
//  CoreDataManager+TransportationMode.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Transportation mode Core Data operations
//  Details: Handles mode detection and persistence
//

import CoreLocation
import Foundation

extension CoreDataManager {
    func endCurrentTrip() {
        guard let trip = currentTrip else { return }
        trip.endDate = Date()
        
        guard let locations = trip.locations else {
            currentTrip = nil
            saveContext()
            return
        }
        
        // Calculate statistics
        let locationArray = Array(locations).sorted { $0.timestamp < $1.timestamp }
        var distance = 0.0
        var speeds: [Double] = []
        
        for i in 0 ..< locationArray.count - 1 {
            let loc1 = CLLocation(latitude: locationArray[i].latitude,
                                  longitude: locationArray[i].longitude)
            let loc2 = CLLocation(latitude: locationArray[i+1].latitude,
                                  longitude: locationArray[i+1].longitude)
            distance += loc1.distance(from: loc2)
            
            if locationArray[i].speed > 0 {
                speeds.append(locationArray[i].speed)
            }
        }
        
        // Add last location speed if valid
        if let lastSpeed = locationArray.last?.speed, lastSpeed > 0 {
            speeds.append(lastSpeed)
        }
        
        trip.distance = distance
        trip.maxSpeed = speeds.max() ?? 0
        
        let averageSpeed = speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
        trip.averageSpeed = averageSpeed * 3.6 // Convert to km/h
        
        // Determine transportation mode
        if !speeds.isEmpty {
            let dominantSpeed = speeds.sorted()[(speeds.count * 3) / 4] // 75th percentile
            trip.transportationMode = TransportationMode.detect(speed: dominantSpeed).rawValue
        } else {
            trip.transportationMode = TransportationMode.unknown.rawValue
        }
        
        // Use the current mode from the detection service
        trip.transportationMode = TransportationModeDetectionService.shared.currentMode.rawValue
        
        
        currentTrip = nil
        saveContext()
    }
}
