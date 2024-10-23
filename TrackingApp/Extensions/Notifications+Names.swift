//
//  AppNotifications.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Notification Names

extension Notification.Name {
    // MARK: Location Updates
    
    /// Posted when a new location update is received
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
    
    /// Posted when location speed changes
    /// - Note: Object contains the speed value as Double in m/s
    static let locationSpeedDidUpdate = Notification.Name("locationSpeedDidUpdate")
    
    // MARK: Transportation Mode
    
    /// Posted when the transportation mode changes
    /// - Note: Object contains the new TransportationMode value
    static let transportationModeDidChange = Notification.Name("transportationModeDidChange")
    
    // MARK: Permissions
    
    /// Posted when location permissions are denied
    static let locationPermissionDenied = Notification.Name("locationPermissionDenied")
    
    // MARK: Geofencing
    
    /// Posted when trip ends
    static let vehicleParked = Notification.Name("vehicleParked")
    
    /// Posted when trip starts
    static let vehicleDeparted = Notification.Name("vehicleDeparted")
}

// MARK: - Notification Keys

enum NotificationKeys {
    // Add any notification userInfo keys here if needed
    static let errorKey = "error"
    static let speedKey = "speed"
    static let locationKey = "location"
    static let transportationModeKey = "transportationMode"
}

// MARK: - Notification Helper

final class NotificationHelper {
    static func postTransportationModeChange(_ mode: TransportationMode) {
        NotificationCenter.default.post(
            name: .transportationModeDidChange,
            object: mode,
            userInfo: [NotificationKeys.transportationModeKey: mode]
        )
    }
    
    static func postLocationUpdate(_ location: CLLocation) {
        NotificationCenter.default.post(
            name: .locationDidUpdate,
            object: location,
            userInfo: [NotificationKeys.locationKey: location]
        )
        
        // Also post speed update
        NotificationCenter.default.post(
            name: .locationSpeedDidUpdate,
            object: location.speed,
            userInfo: [NotificationKeys.speedKey: location.speed]
        )
    }
    
    static func postLocationPermissionDenied(error: Error? = nil) {
        var userInfo: [String: Any]? = nil
        if let error = error {
            userInfo = [NotificationKeys.errorKey: error]
        }
        
        NotificationCenter.default.post(
            name: .locationPermissionDenied,
            object: nil,
            userInfo: userInfo
        )
    }
}

// MARK: - Publisher Extensions

extension NotificationCenter {
    /// Returns a publisher for transportation mode changes
    func transportationModePublisher() -> AnyPublisher<TransportationMode, Never> {
        publisher(for: .transportationModeDidChange)
            .compactMap { $0.object as? TransportationMode }
            .eraseToAnyPublisher()
    }
    
    /// Returns a publisher for location updates
    func locationUpdatePublisher() -> AnyPublisher<CLLocation, Never> {
        publisher(for: .locationDidUpdate)
            .compactMap { $0.object as? CLLocation }
            .eraseToAnyPublisher()
    }
    
    /// Returns a publisher for speed updates
    func speedUpdatePublisher() -> AnyPublisher<Double, Never> {
        publisher(for: .locationSpeedDidUpdate)
            .compactMap { $0.object as? Double }
            .eraseToAnyPublisher()
    }
}

// MARK: - Testing Support

#if DEBUG
extension NotificationHelper {
    static func testPostNotification(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
}
#endif
