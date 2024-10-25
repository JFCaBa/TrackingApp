//
//  TripModelTests.swift
//  TrackingAppTests
//
//  Created by Jose on 25/10/2024.
//

import XCTest

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
