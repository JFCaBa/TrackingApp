//
//  MapViewModel+CoreData.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
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
