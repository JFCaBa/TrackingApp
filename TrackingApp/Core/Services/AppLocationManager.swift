//
//  AppLocationManager.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreLocation
import Combine

final class AppLocationManager: NSObject {
    static let shared = AppLocationManager()
    
    private let locationManager = CLLocationManager()
    private var isTracking = false
    
    @Published private(set) var currentLocation: CLLocation?
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        setupLocationManager()
        setupMotionObservers()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    private func setupMotionObservers() {
        NotificationCenter.default.publisher(for: .tripShouldStart)
            .sink { [weak self] _ in
                self?.startTrip()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .tripShouldEnd)
            .sink { [weak self] _ in
                self?.endTrip()
            }
            .store(in: &cancellables)
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        MotionActivityManager.shared.startMonitoring()
    }
    
    private func startTrip() {
        guard !isTracking else { return }
        isTracking = true
        CoreDataManager.shared.startNewTrip()
    }
    
    private func endTrip() {
        guard isTracking else { return }
        isTracking = false
        CoreDataManager.shared.endCurrentTrip()
    }
}

extension AppLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        NotificationCenter.default.post(name: .locationDidUpdate, object: location)
        NotificationCenter.default.post(name: .locationSpeedDidUpdate, object: location.speed)
        
        if isTracking {
            CoreDataManager.shared.addLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
