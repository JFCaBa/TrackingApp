//
//  TripEntity+CoreDataProperties.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Foundation
import CoreData

extension TripEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripEntity> {
        return NSFetchRequest<TripEntity>(entityName: "TripEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var averageSpeed: Double
    @NSManaged public var maxSpeed: Double
    @NSManaged public var distance: Double
    @NSManaged public var locations: Set<LocationEntity>?
    @NSManaged public var transportationMode: String
}
