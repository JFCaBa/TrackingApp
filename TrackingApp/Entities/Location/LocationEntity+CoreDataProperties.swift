//
//  LocationEntity+CoreDataProperties.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Core Data location entity properties
//  Details: Generated Core Data properties for locations
//

import CoreData
import Foundation

public extension LocationEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var timestamp: Date
    @NSManaged var speed: Double
    @NSManaged var trip: TripEntity?
}
