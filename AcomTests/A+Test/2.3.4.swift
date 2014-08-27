//
//  2.3.3.swift
//  Acom
//
//  Created by yanamura on 2014/08/27.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import Foundation

import Foundation

import UIKit
import XCTest

class Tests2_3_4: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
        2.3.4: If `x` is not an object or function, fulfill `promise` with `x`
    */
    func test2_3_4_fulfill() {
        let expectation = expectationWithDescription("test2_3_4_1")

        var testResult: Int?

        let promise1 = Promise.resolve(1)

        let promise2 = promise1.then(
            {(result: Int) -> Int in
                testResult = result
                expectation.fulfill()
                return result
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(testResult!, 1, "")
        })
    }
}