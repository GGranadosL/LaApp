//
//  La_AppTests.swift
//  La AppTests
//
//  Created by Gerardo Granados Lopez on 1/31/19.
//  Copyright © 2019 Gerardo Granados Lopez. All rights reserved.
//

import XCTest
@testable import La_App

class La_AppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // XCTAssert to test model
        func testScoreIsComputed() {
            // 1. given
            let result = Utils.containsOnlyLetters(input: "555")
            
            XCTAssertFalse(result)
            //XCTAssertEqual(Utils.containsOnlyLetters(input: "5555555555"), "Create user failed")
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
