//
//  SpeedViewTests.swift
//  TrackingAppTests
//
//  Created by Jose on 25/10/2024.
//

import XCTest

class SpeedViewTests: XCTestCase {
    var sut: SpeedView!
    
    override func setUp() {
        super.setUp()
        sut = SpeedView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSpeedViewLayout() {
        // Testing that the view has the correct shape
        XCTAssertEqual(sut.layer.cornerRadius, 50)
        XCTAssertTrue(sut.clipsToBounds)
    }
    
    func testSpeedUpdate() {
        // Given
        let speed = 65.4
        
        // When
        sut.updateSpeed(speed)
        
        // Then
        let speedLabel = sut.subviews.compactMap { $0 as? UILabel }.first
        XCTAssertEqual(speedLabel?.text, "65")
    }
}
