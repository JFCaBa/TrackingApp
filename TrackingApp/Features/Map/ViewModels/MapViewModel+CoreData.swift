//
//  MapViewModel+CoreData.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Core Data operations for map functionality
//  Details: Manages persistence operations for map features
//

import CoreLocation

extension MapViewModel {
    func startTracking() {
        CoreDataManager.shared.startNewTrip()
    }
    
    func stopTracking() {
        CoreDataManager.shared.endCurrentTrip()
    }
    
    func updateLocation(_ location: CLLocation) {
        CoreDataManager.shared.addLocation(location)
    }
}
