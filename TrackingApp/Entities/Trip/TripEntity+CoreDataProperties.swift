//
//  TripEntity+CoreDataProperties.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreData
import Foundation

public extension TripEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TripEntity> {
        return NSFetchRequest<TripEntity>(entityName: "TripEntity")
    }

    @NSManaged var id: UUID
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
    @NSManaged var averageSpeed: Double
    @NSManaged var maxSpeed: Double
    @NSManaged var distance: Double
    @NSManaged var locations: Set<LocationEntity>?
    @NSManaged var transportationMode: String
}
