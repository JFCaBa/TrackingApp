//
//  TripCoordinator.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit

final class TripsCoordinator: Coordinator {
    // MARK: - Properties
    
    private let navigationController: UINavigationController
    private var tripsViewController: TripsViewController?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.setupNavigationBarAppearance()
    }
    
    private func setupNavigationBarAppearance() {
        // Create a new appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // Makes background opaque
        
        // Set the background color of the navigation bar
        appearance.backgroundColor = .systemBackground // Or any other color you want

        // Apply the appearance to the current navigation bar
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        // Ensure the background color extends to the top
        navigationController.navigationBar.compactAppearance = appearance
    }
    
    // MARK: - Coordinator
    
    func start() {
        let viewModel = TripsViewModel()
        let viewController = TripsViewController(viewModel: viewModel)
        viewController.coordinator = self
        viewController.title = "Trips"
        tripsViewController = viewController
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func createViewController() -> UIViewController {
        start()
        return navigationController
    }
    
    // MARK: - Navigation
    
    func showTripDetails(for trip: Trip) {
        let viewModel = TripMapViewModel(trip: trip)
        let viewController = TripMapViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
