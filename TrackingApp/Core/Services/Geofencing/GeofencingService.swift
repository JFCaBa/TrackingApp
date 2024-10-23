//
//  GeofencingService.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Combine
import CoreLocation
import Foundation

final class GeofencingService: NSObject {
    // MARK: - Properties
    
    static let shared = GeofencingService()
    private let locationManager = CLLocationManager()
    private let geofenceRadius: CLLocationDistance = 100 // meters
    private var monitoredRegions: Set<CLCircularRegion> = []
    
    @Published private(set) var lastVisitedLocation: CLLocation?
    @Published private(set) var isInParkedState = false
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Request "Always" authorization for geofencing
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Geofencing Methods
    
    func createGeofenceForParkedLocation(_ location: CLLocation) {
        // Remove any existing geofences
        removeAllGeofences()
        
        // Create a new circular region
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: min(geofenceRadius, location.horizontalAccuracy),
            identifier: "ParkedLocation-\(Date().timeIntervalSince1970)"
        )
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        // Start monitoring the region
        locationManager.startMonitoring(for: region)
        monitoredRegions.insert(region)
        lastVisitedLocation = location
        isInParkedState = true
        
        NotificationCenter.default.post(
            name: .vehicleParked,
            object: location
        )
    }
    
    func removeAllGeofences() {
        monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        monitoredRegions.removeAll()
    }
    
    // MARK: - Helper Methods
    
    private func handleVehicleDeparture() {
        isInParkedState = false
        NotificationCenter.default.post(name: .vehicleDeparted, object: nil)
    }
    
    private func handleVehicleArrival(at location: CLLocation) {
        isInParkedState = true
        lastVisitedLocation = location
        NotificationCenter.default.post(name: .vehicleParked, object: location)
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofencingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let location = locationManager.location else { return }
        handleVehicleArrival(at: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleVehicleDeparture()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofencing failed for region: \(region?.identifier ?? "unknown"). Error: \(error.localizedDescription)")
    }
}
