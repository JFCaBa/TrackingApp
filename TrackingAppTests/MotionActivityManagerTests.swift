//
//  MotionActivityManagerTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreMotion
@testable import TrackingApp

final class MotionActivityManagerTests: XCTestCase {
    var motionManager: MotionActivityManager!
    
    override func setUp() {
        super.setUp()
        motionManager = MotionActivityManager.shared
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTripStartDetection() {
        let expectation = expectation(forNotification: .tripShouldStart, object: nil)
        
        // Simulate high speed
        NotificationCenter.default.post(
            name: .locationSpeedDidUpdate,
            object: 10.0 // 36 km/h
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTripEndDetection() {
        let expectation = expectation(forNotification: .tripShouldEnd, object: nil)
        
        // First start a trip
        NotificationCenter.default.post(
            name: .locationSpeedDidUpdate,
            object: 10.0
        )
        
        // Then simulate stopping
        NotificationCenter.default.post(
            name: .locationSpeedDidUpdate,
            object: 1.0
        )
        
        // Wait for 5 minutes (simulated in test)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Simulate time passing
            self.motionManager.considerTripEnd()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
