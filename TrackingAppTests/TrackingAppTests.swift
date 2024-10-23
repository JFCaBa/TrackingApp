//
//  TrackingAppTests.swift
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

// MARK: - Trips ViewModel Tests
class TripsViewModelTests: XCTestCase {
    var sut: TripsViewModel!
    
    override func setUp() {
        super.setUp()
        sut = TripsViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLoadTrips() {
        // Given
        let expectation = XCTestExpectation(description: "Load trips")
        
        // When
        sut.loadTrips()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Add assertions here once you implement the actual data loading
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Trip Model Tests
class TripModelTests: XCTestCase {
    func testTripEncoding() throws {
        // Given
        let trip = Trip(
            id: UUID(),
            startDate: Date(),
            endDate: Date(),
            averageSpeed: 50.0,
            maxSpeed: 80.0,
            distance: 1000.0,
            transportationMode: .unknown
        )
        
        // When
        let encodedData = try JSONEncoder().encode(trip)
        let decodedTrip = try JSONDecoder().decode(Trip.self, from: encodedData)
        
        // Then
        XCTAssertEqual(trip.id, decodedTrip.id)
        XCTAssertEqual(trip.averageSpeed, decodedTrip.averageSpeed)
        XCTAssertEqual(trip.maxSpeed, decodedTrip.maxSpeed)
        XCTAssertEqual(trip.distance, decodedTrip.distance)
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

// MARK: - UI Tests
class SpeedViewTests: XCTestCase {
    var sut: SpeedView!
    
    override func setUp() {
        super.setUp()
        sut = SpeedView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSpeedViewLayout() {
        // Testing that the view has the correct shape
        XCTAssertEqual(sut.layer.cornerRadius, 50)
        XCTAssertTrue(sut.clipsToBounds)
    }
    
    func testSpeedUpdate() {
        // Given
        let speed = 65.4
        
        // When
        sut.updateSpeed(speed)
        
        // Then
        let speedLabel = sut.subviews.compactMap { $0 as? UILabel }.first
        XCTAssertEqual(speedLabel?.text, "65")
    }
}
