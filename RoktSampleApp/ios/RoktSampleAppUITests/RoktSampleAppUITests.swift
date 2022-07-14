//
//  RoktSampleAppUITests.swift
//  RoktSampleAppUITests
//
//  Copyright 2020 Rokt Pte Ltd
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import XCTest

class RoktSampleAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
  
  func testExample() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()
    app.otherElements["Initialize"].tap()
    waiting(5.0)
    app.otherElements["Execute"].tap()
    waiting(5.0)
    XCTAssert(app.buttons["Rokt Privacy Policy"].exists, "Rokt Privacy Policy" )
    
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func waiting(_ secounds: TimeInterval) {
    _ = XCTWaiter.wait(for: [expectation(description: "Wait for n seconds")], timeout: secounds)
  }
}
