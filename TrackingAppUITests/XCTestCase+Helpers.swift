//
//  XCTestCase+Helpers.swift
//  TrackingAppUITests
//
//  Created by Jose on 23/10/2024.
//

import XCTest

extension XCTestCase {
    func wait(forElement element: XCUIElement, timeout: TimeInterval = 5) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists)
    }
    
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed)
    }
}

extension XCUIElement {
    func scrollToElement(_ element: XCUIElement) {
        while !element.isHittable {
            swipeUp()
        }
    }
    
    var isVisible: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}
