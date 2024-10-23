//
//  MockDataHelper.swift
//  TrackingAppUITests
//
//  Created by Jose on 23/10/2024.
//

import Foundation
import CoreData
@testable import TrackingApp

final class MockDataHelper {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TrackingApp")
        
        // Use in-memory store for testing
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
    }
    
    func createMockTrips() {
        let context = container.viewContext
        
        // Create three mock trips
        createTrip(
            context: context,
            startDate: Date().addingTimeInterval(-7200), // 2 hours ago
            duration: 7200,
            distance: 120000,
            averageSpeed: 60,
            maxSpeed: 80
        )
        
        createTrip(
            context: context,
            startDate: Date().addingTimeInterval(-3600), // 1 hour ago
            duration: 3600,
            distance: 90000,
            averageSpeed: 65,
            maxSpeed: 85
        )
        
        createTrip(
            context: context,
            startDate: Date().addingTimeInterval(-1800), // 30 minutes ago
            duration: 1800,
            distance: 90000,
            averageSpeed: 55,
            maxSpeed: 75
        )
        
        try? context.save()
    }
    
    private func createTrip(
        context: NSManagedObjectContext,
        startDate: Date,
        duration: TimeInterval,
        distance: Double,
        averageSpeed: Double,
        maxSpeed: Double
    ) {
        let trip = TripEntity()
        trip.id = UUID()
        trip.startDate = startDate
        trip.endDate = startDate.addingTimeInterval(duration)
        trip.distance = distance
        trip.averageSpeed = averageSpeed
        trip.maxSpeed = maxSpeed
        
        // Add some location points
        let locationCount = Int(duration / 30) // One point every 30 seconds
        var currentDate = startDate
        var currentDistance = 0.0
        let distanceIncrement = distance / Double(locationCount)
        
        for _ in 0..<locationCount {
            let location = LocationEntity()
            location.timestamp = currentDate
            location.speed = averageSpeed + Double.random(in: -5...5)
            location.trip = trip
            
            // Calculate roughly where this location should be based on distance
            let angle = Double.random(in: 0...360)
            let latitude = 37.7749 + (currentDistance / 111000) * cos(angle)
            let longitude = -122.4194 + (currentDistance / 111000) * sin(angle)
            
            location.latitude = latitude
            location.longitude = longitude
            
            currentDate = currentDate.addingTimeInterval(30)
            currentDistance += distanceIncrement
        }
    }
}
