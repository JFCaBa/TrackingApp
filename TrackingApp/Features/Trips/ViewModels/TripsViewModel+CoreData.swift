//
//  TripsViewModel+CoreData.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Core Data operations for trips
//  Details: Handles trips-related persistence operations
//

import Foundation

extension TripsViewModel {
    func loadTrips() {
        state = .loading
        
        CoreDataManager.shared.fetchAllTrips()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                if case .failure(let error) = completion {
                    state = .error(error)
                }
            } receiveValue: { [weak self] trips in
                guard let self else { return }
                
                state = trips.isEmpty ? .empty : .loaded(trips)
            }
            .store(in: &cancellables)
    }
    
    func deleteTrip(_ trip: Trip) {
        CoreDataManager.shared.deleteTrip(trip)
        loadTrips()
    }
}
