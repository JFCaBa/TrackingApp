//
//  TripsViewControllerTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
@testable import TrackingApp

final class TripsViewControllerTests: XCTestCase {
    func testEmptyState() {
        let viewModel = TripsViewModel()
        let viewController = TripsViewController(viewModel: viewModel)
        
        // Load the view
        viewController.loadViewIfNeeded()
        
        // Initially should show loading
        XCTAssertFalse(viewController.loadingView.isHidden)
        
        // Simulate empty data
        viewModel.state = .empty
        
        // Should show empty state
        XCTAssertFalse(viewController.emptyStateView.isHidden)
        XCTAssertTrue(viewController.loadingView.isHidden)
//        XCTAssertTrue(viewController.tableView.isHidden)
    }
}
