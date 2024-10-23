import XCTest
import CoreLocation
import Combine
@testable import TrackingApp

final class GeofencingServiceTests: XCTestCase {
    var geofencingService: GeofencingService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        geofencingService = GeofencingService.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        geofencingService.removeAllGeofences()
        super.tearDown()
    }
    
    func testCreateGeofence() {
        let expectation = XCTestExpectation(description: "Geofence created")
        let testLocation = CLLocation(latitude: 37.3317, longitude: -122.0325)
        
        geofencingService.$lastVisitedLocation
            .dropFirst()
            .sink { location in
                XCTAssertNotNil(location)
                XCTAssertEqual(location!.coordinate.latitude, testLocation.coordinate.latitude, accuracy: 0.0001)
                XCTAssertEqual(location!.coordinate.longitude, testLocation.coordinate.longitude, accuracy: 0.0001)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        geofencingService.createGeofenceForParkedLocation(testLocation)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGeofenceState() {
        let expectation = XCTestExpectation(description: "Parked state changed")
        let testLocation = CLLocation(latitude: 37.3317, longitude: -122.0325)
        
        geofencingService.$isInParkedState
            .dropFirst()
            .sink { isParked in
                XCTAssertTrue(isParked)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        geofencingService.createGeofenceForParkedLocation(testLocation)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGeofenceNotifications() {
        let parkedExpectation = XCTestExpectation(description: "Vehicle parked notification")
        let departedExpectation = XCTestExpectation(description: "Vehicle departed notification")
        let testLocation = CLLocation(latitude: 37.3317, longitude: -122.0325)
        
        NotificationCenter.default.publisher(for: .vehicleParked)
            .sink { _ in
                parkedExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .vehicleDeparted)
            .sink { _ in
                departedExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate parking
        geofencingService.createGeofenceForParkedLocation(testLocation)
        
        // Simulate departure by triggering exit region
        let delegate = geofencingService as CLLocationManagerDelegate
        let region = CLCircularRegion(
            center: testLocation.coordinate,
            radius: 100,
            identifier: "TestRegion"
        )
        delegate.locationManager!(CLLocationManager(), didExitRegion: region)
        
        wait(for: [parkedExpectation, departedExpectation], timeout: 1.0)
    }
}
