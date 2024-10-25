//
//  MapViewModelTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreLocation
@testable import TrackingApp


// MARK: - Map ViewModel Tests
class MapViewModelTests: XCTestCase {
    var sut: MapViewModel!
    
    override func setUp() {
        super.setUp()
        sut = MapViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSpeedCalculation() {
        // Given
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: 0,
            speed: 10, // 10 m/s
            timestamp: Date()
        )
        
        // When
        NotificationCenter.default.post(name: .locationDidUpdate, object: location)
        
        // Then
        XCTAssertEqual(sut.currentSpeed, 36.0) // 10 m/s = 36 km/h
    }
    
    func testLocationUpdate() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: 0,
            speed: 0,
            timestamp: Date()
        )
        
        // When
        NotificationCenter.default.post(name: .locationDidUpdate, object: location)
        
        // Then
        XCTAssertEqual(sut.currentLocation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(sut.currentLocation?.coordinate.longitude, coordinate.longitude)
    }
    
    func testZeroSpeedHandling() {
        // Given
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: 0,
            speed: -1, // Invalid speed
            timestamp: Date()
        )
        
        // When
        NotificationCenter.default.post(name: .locationDidUpdate, object: location)
        
        // Then
        XCTAssertEqual(sut.currentSpeed, 0.0) // Should default to 0
    }
}





// MARK: - Location Manager Tests
//class LocationManagerTests: XCTestCase {
//    var sut: AppLocationManager!
//    
//    override func setUp() {
//        super.setUp()
//        sut = AppLocationManager.shared
//    }
//    
//    override func tearDown() {
//        sut = nil
//        super.tearDown()
//    }
//    
//    func testLocationManagerConfiguration() {
//        // Testing the configuration of CLLocationManager
//        let locationManager = sut.locationManager
//        
//        XCTAssertEqual(locationManager.location?.horizontalAccuracy, kCLLocationAccuracyBestForNavigation)
//        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates)
//        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically)
//    }
//}


