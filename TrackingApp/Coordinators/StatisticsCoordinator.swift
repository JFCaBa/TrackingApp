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

final class StatisticsCoordinator: CoordinatorProtocol {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        setupNavigationBarAppearance()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
    }
    
    func start() {
        let viewModel = StatisticsViewModel()
        let viewController = StatisticsViewController(viewModel: viewModel)
        viewController.title = "Statistics"
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func createViewController() -> UIViewController {
        start()
        return navigationController
    }
}
