//
//  CoreDataManager.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Core Data stack and operations manager
//  Details: Handles persistence and data operations
//

import Combine
import CoreData
import CoreLocation
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    public let persistentContainer: NSPersistentContainer
    var currentTrip: TripEntity?

    // Default initializer using AppDelegate's persistentContainer
    private init(persistentContainer: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - Trip Management
    
    func startNewTrip() {
        let context = persistentContainer.viewContext
        currentTrip = TripEntity(context: context)
        currentTrip?.id = UUID()
        currentTrip?.startDate = Date()
        saveContext()
    }
    
    func addLocation(_ location: CLLocation) {
        guard let trip = currentTrip else { return }
        let context = persistentContainer.viewContext
        
        let locationEntity = LocationEntity(context: context)
        locationEntity.latitude = location.coordinate.latitude
        locationEntity.longitude = location.coordinate.longitude
        locationEntity.timestamp = location.timestamp
        locationEntity.speed = location.speed
        locationEntity.trip = trip
        
        saveContext()
    }
    
    // MARK: - Trip Queries
    
    func fetchAllTrips() -> AnyPublisher<[Trip], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        return Future { promise in
            context.perform {
                do {
                    let tripEntities = try context.fetch(fetchRequest)
                    let trips = tripEntities.map { Trip(from: $0) }
                    let completedTrips = trips.filter({$0.endDate != nil})
                    promise(.success(completedTrips))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteTrip(_ trip: Trip) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trip.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let tripEntity = results.first {
                context.delete(tripEntity)
                saveContext()
            }
        } catch {
            print("Error deleting trip: \(error)")
        }
    }
    
    func deleteAllTrips() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TripEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            saveContext()
        } catch {
            print("Error deleting all trips: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateTripStatistics(_ trip: TripEntity) {
        guard let locations = trip.locations else { return }
        
        let speeds = locations.compactMap { $0.speed > 0 ? $0.speed : nil }
        trip.maxSpeed = speeds.max() ?? 0
        trip.averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        let locationArray = Array(locations).sorted { $0.timestamp < $1.timestamp }
        var distance = 0.0
        
        for i in 0 ..< locationArray.count - 1 {
            let loc1 = CLLocation(latitude: locationArray[i].latitude,
                                  longitude: locationArray[i].longitude)
            let loc2 = CLLocation(latitude: locationArray[i+1].latitude,
                                  longitude: locationArray[i+1].longitude)
            distance += loc1.distance(from: loc2)
        }
        
        trip.distance = distance
    }
    
    // MARK: - Public Methods
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
