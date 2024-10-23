//
//  LocationEntity+CoreDataProperties.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Foundation
import CoreData

extension LocationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var speed: Double
    @NSManaged public var trip: TripEntity?
}
