//
//  CoordinatorTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
@testable import TrackingApp

final class CoordinatorTests: XCTestCase {
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        window = UIWindow(frame: UIScreen.main.bounds)
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func testAppCoordinator() {
        // Given
        let appCoordinator = AppCoordinator(window: window)
        
        // When
        appCoordinator.start()
        
        // Then
        XCTAssertNotNil(window.rootViewController)
        guard let tabBarController = window.rootViewController as? UITabBarController else {
            XCTFail("Root view controller should be UITabBarController")
            return
        }
        
        XCTAssertEqual(tabBarController.viewControllers?.count, 3)
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        // Verify tab bar items
        XCTAssertEqual(tabBarController.viewControllers?[0].tabBarItem.title, "Map")
        XCTAssertEqual(tabBarController.viewControllers?[1].tabBarItem.title, "Trips")
        XCTAssertEqual(tabBarController.viewControllers?[2].tabBarItem.title, "Statistics")
    }
    
    func testStatisticsCoordinator() {
        // Given
        let statisticsCoordinator = StatisticsCoordinator()
        
        // When
        let viewController = statisticsCoordinator.createViewController()
        
        // Then
        XCTAssertTrue(viewController is StatisticsViewController)
        
        guard let statisticsVC = viewController as? StatisticsViewController else {
            XCTFail("View controller should be StatisticsViewController")
            return
        }
        
        // Verify view model is initialized
        let mirror = Mirror(reflecting: statisticsVC)
        let hasViewModel = mirror.children.contains { $0.label == "viewModel" }
        XCTAssertTrue(hasViewModel)
    }
}
