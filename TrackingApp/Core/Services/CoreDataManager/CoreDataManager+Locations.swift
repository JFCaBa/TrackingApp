//
//  CoreDataManager+Locations.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Location-specific Core Data operations
//  Details: Manages location entity operations and queries
//

import Combine
import CoreData
import Foundation

// CoreDataManager+Locations.swift
extension CoreDataManager {
    func fetchLocations(for trip: Trip) -> AnyPublisher<[Location], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trip.id as CVarArg)
        
        return Future { promise in
            context.perform {
                do {
                    let results = try context.fetch(fetchRequest)
                    guard let tripEntity = results.first,
                          let locationEntities = tripEntity.locations
                    else {
                        promise(.success([]))
                        return
                    }
                    
                    let locations = locationEntities.map { Location(from: $0) }
                        .sorted { $0.timestamp < $1.timestamp }
                    
                    promise(.success(locations))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
