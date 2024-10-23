//
//  TripStatCardViewTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
@testable import TrackingApp

final class TripStatCardViewTests: XCTestCase {
    var cardView: TripStatCardView!
    
    override func setUp() {
        super.setUp()
        cardView = TripStatCardView()
    }
    
    override func tearDown() {
        cardView = nil
        super.tearDown()
    }
    
    func testCardConfiguration() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(7200) // 2 hours
        let trip = Trip(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            averageSpeed: 60.0,
            maxSpeed: 80.0,
            distance: 120000, // 120 km
            transportationMode: .automotive
        )
        
        // When
        cardView.configure(
            title: "Test Trip",
            trip: trip,
            iconName: "car.fill"
        )
        
        // Then
        let labels = cardView.testLabels
        
        // Test distance format
        XCTAssertTrue(labels.distance.text?.contains("120.0 kilometers") ?? false)
        
        // Test speed format
        XCTAssertTrue(labels.speed.text?.contains("60 km/h") ?? false)
        
        // Test duration format
        XCTAssertTrue(labels.duration.text?.contains("2h 0m") ?? false)
    }
    
    func testShortTripDurationFormat() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(1800) // 30 minutes
        let trip = Trip(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            averageSpeed: 30.0,
            maxSpeed: 40.0,
            distance: 15000, // 15 km
            transportationMode: .cycling
        )
        
        // When
        cardView.configure(
            title: "Short Trip",
            trip: trip,
            iconName: "car.fill"
        )
        
        // Then
        let labels = cardView.testLabels
        XCTAssertTrue(labels.duration.text?.contains("30m") ?? false)
        XCTAssertFalse(labels.duration.text?.contains("h") ?? false)
    }
}
