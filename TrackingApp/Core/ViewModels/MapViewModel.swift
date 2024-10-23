//
//  MapViewModel.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit
import Combine
import MapKit


// MARK: - Map ViewModel
final class MapViewModel {
    @Published private(set) var currentSpeed: Double = 0.0
    @Published private(set) var currentLocation: CLLocation?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationObserver()
    }
    
    private func setupLocationObserver() {
        NotificationCenter.default.publisher(for: .locationDidUpdate)
            .compactMap { $0.object as? CLLocation }
            .sink { [weak self] location in
                self?.currentLocation = location
                self?.currentSpeed = location.speed > 0 ? location.speed * 3.6 : 0 // Convert m/s to km/h
            }
            .store(in: &cancellables)
    }
}




