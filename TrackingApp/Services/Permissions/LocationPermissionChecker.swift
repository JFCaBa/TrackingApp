//
//  LocationPermissionChecker.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Location authorization service
//  Details: Handles location permission checks and requests
//

import Combine
import CoreLocation
import UIKit

final class LocationPermissionChecker: NSObject {
    // MARK: - Properties

    static let shared = LocationPermissionChecker()
    
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization

    override private init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods

    func requestLocationPermissions() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            handleRestrictedOrDeniedAccess()
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            
        case .authorizedAlways:
            AppLocationManager.shared.startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Methods

    private func handleRestrictedOrDeniedAccess() {
        NotificationCenter.default.post(
            name: .locationPermissionDenied,
            object: nil
        )
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL)
        else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationPermissionChecker: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            AppLocationManager.shared.startUpdatingLocation()
        default:
            break
        }
    }
}

