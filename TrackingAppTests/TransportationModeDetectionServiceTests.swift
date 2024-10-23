//
//  TransportationModeDetectionServiceTests.swift
//  TrackingAppTests
//
//  Created by Jose on 23/10/2024.
//

import XCTest
import CoreMotion
import Combine
@testable import TrackingApp

final class TransportationModeDetectionServiceTests: XCTestCase {
    var service: TransportationModeDetectionService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        service = TransportationModeDetectionService.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testWalkingSpeedDetection() {
        let expectation = XCTestExpectation(description: "Walking mode detected")
        
        service.$currentMode
            .dropFirst()
            .sink { mode in
                XCTAssertEqual(mode, .walking)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Test with 5 km/h speed (typical walking speed)
        service.testProcessSpeed(5.0 / 3.6) // Convert km/h to m/s
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCyclingSpeedDetection() {
        let expectation = XCTestExpectation(description: "Cycling mode detected")
        
        service.$currentMode
            .dropFirst()
            .sink { mode in
                XCTAssertEqual(mode, .cycling)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Test with 15 km/h speed (typical cycling speed)
        service.testProcessSpeed(15.0 / 3.6)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAutomotiveSpeedDetection() {
        let expectation = XCTestExpectation(description: "Automotive mode detected")
        
        service.$currentMode
            .dropFirst()
            .sink { mode in
                XCTAssertEqual(mode, .automotive)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Test with 50 km/h speed (typical driving speed)
        service.testProcessSpeed(50.0 / 3.6)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMotionActivityDetection() {
        let expectation = XCTestExpectation(description: "Motion activity detected")
        
        service.$currentMode
            .dropFirst()
            .sink { mode in
                XCTAssertEqual(mode, .automotive)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Create mock CMMotionActivity
        let activity = MockMotionActivity(
            automotive: true,
            cycling: false,
            walking: false,
            confidence: .high
        )
        
        service.testProcessActivity(activity)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Objects

private class MockMotionActivity: CMMotionActivity {
    private let _automotive: Bool
    private let _cycling: Bool
    private let _walking: Bool
    private let _confidence: CMMotionActivityConfidence
    
    init(automotive: Bool, cycling: Bool, walking: Bool, confidence: CMMotionActivityConfidence) {
        self._automotive = automotive
        self._cycling = cycling
        self._walking = walking
        self._confidence = confidence
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var automotive: Bool { _automotive }
    override var cycling: Bool { _cycling }
    override var walking: Bool { _walking }
    override var confidence: CMMotionActivityConfidence { _confidence }
}
