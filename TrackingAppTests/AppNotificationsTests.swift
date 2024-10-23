//
//  AppNotificationsTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreLocation
import Combine
@testable import TrackingApp

final class AppNotificationsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testTransportationModeNotification() {
        let expectation = XCTestExpectation(description: "Transportation mode notification received")
        let testMode = TransportationMode.automotive
        
        NotificationCenter.default
            .transportationModePublisher()
            .sink { mode in
                XCTAssertEqual(mode, testMode)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationHelper.postTransportationModeChange(testMode)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocationUpdateNotification() {
        let expectation = XCTestExpectation(description: "Location update notification received")
        let testLocation = CLLocation(latitude: 37.3317, longitude: -122.0325)
        
        NotificationCenter.default
            .locationUpdatePublisher()
            .sink { location in
                XCTAssertEqual(location.coordinate.latitude, testLocation.coordinate.latitude, accuracy: 0.0001)
                XCTAssertEqual(location.coordinate.longitude, testLocation.coordinate.longitude, accuracy: 0.0001)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationHelper.postLocationUpdate(testLocation)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSpeedUpdateNotification() {
        let expectation = XCTestExpectation(description: "Speed update notification received")
        let testSpeed = 15.5
        
        NotificationCenter.default
            .speedUpdatePublisher()
            .sink { speed in
                XCTAssertEqual(speed, testSpeed, accuracy: 0.0001)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.post(
            name: .locationSpeedDidUpdate,
            object: testSpeed
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocationPermissionDeniedNotification() {
        let expectation = XCTestExpectation(description: "Permission denied notification received")
        let testError = NSError(domain: "com.test", code: 123, userInfo: nil)
        
        NotificationCenter.default
            .publisher(for: .locationPermissionDenied)
            .sink { notification in
                XCTAssertNotNil(notification.userInfo)
                XCTAssertEqual(
                    (notification.userInfo?[NotificationKeys.errorKey] as? NSError)?.code,
                    testError.code
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationHelper.postLocationPermissionDenied(error: testError)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
