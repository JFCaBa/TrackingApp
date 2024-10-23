//
//  AppDelegateTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
@testable import TrackingApp

final class AppDelegateTests: XCTestCase {
    
    var sut: AppDelegate!
    
    override func setUp() {
        super.setUp()
        sut = AppDelegate()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAppDelegateInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.window)
    }
    
    func testApplicationDidFinishLaunching() {
        // When
        let result = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertNotNil(sut.window)
        XCTAssertNotNil(sut.window?.rootViewController)
    }
    
    func testPersistentContainerInitialization() {
        // When
        let container = sut.persistentContainer
        
        // Then
        XCTAssertNotNil(container)
        XCTAssertEqual(container.name, "TrackingApp")
    }
    
    func testSaveContext_WithNoChanges() {
        // Given
        let context = sut.persistentContainer.viewContext
        
        // When
        XCTAssertNoThrow(sut.saveContext())
        
        // Then
        XCTAssertFalse(context.hasChanges)
    }
}

// MARK: - Integration Tests
final class AppDelegateIntegrationTests: XCTestCase {
    
    var sut: AppDelegate!
    
    override func setUp() {
        super.setUp()
        sut = AppDelegate()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAppCoordinatorSetup() {
        // When
        _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        
        // Then
        XCTAssertNotNil(sut.window?.rootViewController as? UITabBarController)
    }
    
    func testWindowConfiguration() {
        // When
        _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        
        // Then
        XCTAssertEqual(sut.window?.frame, UIScreen.main.bounds)
        XCTAssertEqual(sut.window?.backgroundColor, .systemBackground)
    }
}
