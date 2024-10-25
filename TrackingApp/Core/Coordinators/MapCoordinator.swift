//
//  MapCoordinator.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Map-related navigation coordinator
//  Details: Handles navigation and view creation for map functionality
//

import UIKit

final class MapCoordinator: Coordinator {
    func createViewController() -> UIViewController {
        let viewModel = MapViewModel()
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
    
    func start() {
        // Implementation for deeper navigation if needed
    }
}
