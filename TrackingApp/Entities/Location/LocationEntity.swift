//
//  LocationEntity.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let speed: Double
}

extension Location {
    init(from location: LocationEntity) {
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.timestamp = location.timestamp
        self.speed = location.speed
    }
}
