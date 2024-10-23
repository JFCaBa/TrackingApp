//
//  AppLocationManager+Geofencing.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreLocation

extension AppLocationManager {
    // MARK: - Geofencing Integration
    
    func handlePotentialParking(_ location: CLLocation) {
        guard currentSpeed < 1.0 else { return } // Speed less than 1 m/s
        
        // Create a geofence if we've been stationary for a while
        Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
            guard let self = self,
                  let currentLocation = self.currentLocation,
                  self.currentSpeed < 1.0 else { return }
            
            GeofencingService.shared.createGeofenceForParkedLocation(currentLocation)
        }
    }
    
    private func setupGeofencingObservers() {
        NotificationCenter.default.publisher(for: .vehicleDeparted)
            .sink { [weak self] _ in
                self?.startNewTrip()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .vehicleParked)
            .sink { [weak self] notification in
                guard let location = notification.object as? CLLocation else { return }
                self?.endCurrentTrip(at: location)
            }
            .store(in: &cancellables)
    }
    
    private func startNewTrip() {
        isTracking = true
        CoreDataManager.shared.startNewTrip()
    }
    
    private func endCurrentTrip(at location: CLLocation) {
        isTracking = false
        CoreDataManager.shared.endCurrentTrip()
    }
}
