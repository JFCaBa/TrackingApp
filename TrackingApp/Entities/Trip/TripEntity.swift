//
//  TripEntity.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Foundation

// MARK: - Trip Model
struct Trip: Codable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let averageSpeed: Double
    let maxSpeed: Double
    let distance: Double
    let transportationMode: TransportationMode
}

extension Trip {
    init(from entity: TripEntity) {
        self.id = entity.id
        self.startDate = entity.startDate
        self.endDate = entity.endDate ?? .now
        self.averageSpeed = entity.averageSpeed
        self.maxSpeed = entity.maxSpeed
        self.distance = entity.distance
        self.transportationMode = TransportationMode(rawValue: entity.transportationMode) ?? .unknown
    }
}
