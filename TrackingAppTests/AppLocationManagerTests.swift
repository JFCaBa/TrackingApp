//
//  AppLocationManagerTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreLocation
import Combine
@testable import TrackingApp

final class AppLocationManagerTests: XCTestCase {
    var locationManager: AppLocationManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        locationManager = AppLocationManager.shared
        locationManager.testResetState()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testLocationUpdates() {
        let expectation = XCTestExpectation(description: "Location update received")
        
        locationManager.$currentLocation
            .dropFirst()
            .sink { location in
                XCTAssertNotNil(location)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate location update
        let location = CLLocation(latitude: 37.3317, longitude: -122.0325)
        let delegate = locationManager as CLLocationManagerDelegate
        delegate.locationManager!(CLLocationManager(), didUpdateLocations: [location])
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTrackingStateChanges() {
        let expectation = XCTestExpectation(description: "Tracking state changed")
        
        locationManager.$isTracking
            .dropFirst()
            .sink { isTracking in
                XCTAssertTrue(isTracking)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate automotive mode detection
        NotificationCenter.default.post(
            name: .transportationModeDidChange,
            object: TransportationMode.automotive
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTrackingEndsWithNonAutomotiveMode() {
        // Start tracking
        locationManager.testSetTracking(true)
        
        let expectation = XCTestExpectation(description: "Tracking ended")
        
        locationManager.$isTracking
            .dropFirst()
            .sink { isTracking in
                XCTAssertFalse(isTracking)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate walking mode detection
        NotificationCenter.default.post(
            name: .transportationModeDidChange,
            object: TransportationMode.walking
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocationPermissionDeniedNotification() {
        let expectation = XCTestExpectation(description: "Permission denied notification received")
        
        NotificationCenter.default.publisher(for: .locationPermissionDenied)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate permission denied
        let delegate = locationManager as CLLocationManagerDelegate
        let mockManager = CLLocationManager()
        delegate.locationManagerDidChangeAuthorization!(mockManager)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
