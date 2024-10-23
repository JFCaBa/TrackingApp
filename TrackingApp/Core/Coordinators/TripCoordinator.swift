//
//  TripCoordinator.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit

// MARK: - Trips Coordinator
final class TripsCoordinator: Coordinator {
    func createViewController() -> UIViewController {
        let viewModel = TripsViewModel()
        let viewController = TripsViewController(viewModel: viewModel)
        return viewController
    }
    
    func start() {
        // Implementation for deeper navigation if needed
    }
}
