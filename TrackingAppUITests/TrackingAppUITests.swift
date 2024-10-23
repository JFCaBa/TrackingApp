//
//  TrackingAppUITests.swift
//  TrackingAppUITests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
@testable import TrackingApp

final class TrackingAppUITests: XCTestCase {
    var app: XCUIApplication!
    var mockDataHelper: MockDataHelper!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        mockDataHelper = MockDataHelper()
        
        // Clear previous app data
        clearAppData()
        
        // Setup mock data before launching the app
        setupMockTrips()
        
        // Launch arguments to indicate we're running UI tests
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        mockDataHelper = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Navigation
    
    func testTabBarNavigation() throws {
        // Test Map Tab
        XCTAssertTrue(app.tabBars.buttons["Map"].exists)
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.maps.element.exists)
        
        // Test Trips Tab
        app.tabBars.buttons["Trips"].tap()
        XCTAssertTrue(app.tables.element.exists)
        
        // Test Statistics Tab
        app.tabBars.buttons["Statistics"].tap()
        XCTAssertTrue(app.scrollViews.element.exists)
    }
    
    // MARK: - Test Trips List
    
    func testTripsListDisplay() {
        // Navigate to Trips tab
        app.tabBars.buttons["Trips"].tap()
        
        // Verify trips table exists
        let tripsTable = app.tables.element
        XCTAssertTrue(tripsTable.exists)
        
        // Check for trip cells
        let cells = tripsTable.cells
        XCTAssertEqual(cells.count, 3) // We created 3 mock trips
        
        // Verify first trip cell content
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.staticTexts["120.0 km"].exists)
        XCTAssertTrue(firstCell.staticTexts["60 km/h avg"].exists)
    }
    
    func testTripDeletion() {
        // Navigate to Trips tab
        app.tabBars.buttons["Trips"].tap()
        
        let tripsTable = app.tables.element
        let initialCellCount = tripsTable.cells.count
        
        // Swipe to delete first trip
        let firstCell = tripsTable.cells.element(boundBy: 0)
        firstCell.swipeLeft()
        app.buttons["Delete"].tap()
        
        // Verify cell was deleted
        XCTAssertEqual(tripsTable.cells.count, initialCellCount - 1)
    }
    
    // MARK: - Test Statistics
    
    func testStatisticsDisplay() {
        // Navigate to Statistics tab
        app.tabBars.buttons["Statistics"].tap()
        
        // Verify statistics cards exist
        XCTAssertTrue(app.staticTexts["Total Trips"].exists)
        XCTAssertTrue(app.staticTexts["Total Distance"].exists)
        XCTAssertTrue(app.staticTexts["Average Speed"].exists)
        XCTAssertTrue(app.staticTexts["Total Duration"].exists)
        
        // Verify statistics values
        XCTAssertTrue(app.staticTexts["3"].exists) // Total trips
        XCTAssertTrue(app.staticTexts["300.0 km"].exists) // Total distance
        XCTAssertTrue(app.staticTexts["60 km/h"].exists) // Average speed
    }
    
    // MARK: - Helper Methods
    
    private func clearAppData() {
        let fileManager = FileManager.default
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
              let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return
        }
        
        try? fileManager.removeItem(atPath: documentPath)
        try? fileManager.removeItem(atPath: libraryPath)
    }
    
    private func setupMockTrips() {
        mockDataHelper.createMockTrips()
    }
}
