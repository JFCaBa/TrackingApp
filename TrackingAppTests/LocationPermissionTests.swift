//
//  LocationPermissionCheckerTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreLocation
import Combine
@testable import TrackingApp

final class LocationPermissionCheckerTests: XCTestCase {
    
    var sut: LocationPermissionChecker!
    private var mockLocationManager: MockCLLocationManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = LocationPermissionChecker.shared
        mockLocationManager = MockCLLocationManager()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        mockLocationManager = nil
        sut = nil
        super.tearDown()
    }
    
    func testInitialAuthorizationStatus() {
        XCTAssertEqual(sut.authorizationStatus, .notDetermined)
    }
    
    func testAuthorizationStatusUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Authorization status update")
        var receivedStatus: CLAuthorizationStatus?
        
        sut.$authorizationStatus
            .sink { status in
                receivedStatus = status
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockLocationManager.simulateAuthorizationChange(.authorizedWhenInUse)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStatus, .authorizedWhenInUse)
    }
    
    func testLocationPermissionDeniedNotification() {
        // Given
        let expectation = XCTestExpectation(description: "Permission denied notification")
        
        NotificationCenter.default.addObserver(
            forName: .locationPermissionDenied,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }
        
        // When
        mockLocationManager.simulateAuthorizationChange(.denied)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Mock CLLocationManager
private final class MockCLLocationManager: CLLocationManager {
    private var authorizationStatusToReturn: CLAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: CLAuthorizationStatus {
        return authorizationStatusToReturn
    }
    
    func simulateAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatusToReturn = status
        delegate?.locationManagerDidChangeAuthorization?(self)
    }
}
