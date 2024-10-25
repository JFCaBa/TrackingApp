//
//  StatisticsViewModel.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Statistics screen view model
//  Details: Manages statistics calculation and presentation
//

import Combine
import Foundation

final class StatisticsViewModel {
    struct ModeStatistics {
        let mode: TransportationMode
        let tripCount: Int
        let totalDistance: Double
        let averageSpeed: Double
    }
    
    struct Statistics: Equatable {
        static func == (lhs: StatisticsViewModel.Statistics, rhs: StatisticsViewModel.Statistics) -> Bool {
            return lhs.totalTrips == rhs.totalTrips && lhs.totalDistance == rhs.totalDistance
        }
        
        let totalTrips: Int
        let totalDistance: Double
        let averageSpeed: Double
        let totalDuration: TimeInterval
        let longestTrip: Trip?
        let fastestTrip: Trip?
        let modeStats: [ModeStatistics]
    }
    
    @Published private(set) var state: LoadingState<Statistics> = .empty
    private var cancellables = Set<AnyCancellable>()
    
    func loadStatistics() {
        guard state != .loading else { return }
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
                
                calculateStatistics(from: trips)
            }
            .store(in: &cancellables)
    }
    
    private func calculateStatistics(from trips: [Trip]) {
        guard !trips.isEmpty else {
            state = .empty
            return
        }
        
        let totalDistance = trips.reduce(0) { $0 + $1.distance }
        let totalDuration = trips.reduce(0) { $0 + ($1.endDate ?? .now).timeIntervalSince($1.startDate) }
        let averageSpeed = trips.reduce(0) { $0 + $1.averageSpeed } / Double(trips.count)
        
        let longestTrip = trips.max(by: { $0.distance < $1.distance })
        let fastestTrip = trips.max(by: { $0.averageSpeed < $1.averageSpeed })
        
        // Calculate per-mode statistics
        let modeStats = TransportationMode.allCases.compactMap { mode -> ModeStatistics? in
            let modeTrips = trips.filter { $0.transportationMode == mode }
            guard !modeTrips.isEmpty else { return nil }
            
            return ModeStatistics(
                mode: mode,
                tripCount: modeTrips.count,
                totalDistance: modeTrips.reduce(0) { $0 + $1.distance },
                averageSpeed: modeTrips.reduce(0) { $0 + $1.averageSpeed } / Double(modeTrips.count)
            )
        }
        
        let statistics = Statistics(
            totalTrips: trips.count,
            totalDistance: totalDistance,
            averageSpeed: averageSpeed,
            totalDuration: totalDuration,
            longestTrip: longestTrip,
            fastestTrip: fastestTrip,
            modeStats: modeStats
        )
        
        state = .loaded(statistics)
    }
}
