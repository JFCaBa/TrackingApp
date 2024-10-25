//
//  StatisticsCoordinator.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Statistics-related navigation coordinator
//  Details: Manages navigation and view creation for statistics screens
//

import UIKit

final class StatisticsCoordinator: Coordinator {
    func createViewController() -> UIViewController {
        let viewModel = StatisticsViewModel()
        let viewController = StatisticsViewController(viewModel: viewModel)
        return viewController
    }
    
    func start() {
        // Implementation for deeper navigation if needed
    }
}
