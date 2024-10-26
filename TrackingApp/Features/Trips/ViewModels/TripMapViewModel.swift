//
//  TripMapViewModel.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Trip map view model
//  Details: Handles individual trip map visualization logic
//

import Combine
import CoreLocation

final class TripMapViewModel {
    struct TripDetails: Equatable {
        static func == (lhs: TripMapViewModel.TripDetails, rhs: TripMapViewModel.TripDetails) -> Bool {
            lhs.trip.id == rhs.trip.id
        }
        
        let trip: Trip
        let routeCoordinates: [CLLocationCoordinate2D]
    }
    
    // MARK: - Properties
    
    @Published private(set) var state: LoadingState<TripDetails> = .loading
    private let trip: Trip
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: - Initialization
    
    init(trip: Trip) {
        self.trip = trip
    }
    
    // MARK: - Public Methods
    
    func loadTripDetails() {
        state = .loading
        
        CoreDataManager.shared.fetchLocations(for: trip)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error)
                }
            } receiveValue: { [weak self] locations in
                guard let self = self else { return }
                let coordinates = locations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                let details = TripDetails(trip: self.trip, routeCoordinates: coordinates)
                self.state = .loaded(details)
            }
            .store(in: &cancellables)
    }
}
