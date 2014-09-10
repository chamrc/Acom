//
//  2.3.1.swift
//  Acom
//
//  Created by yanamura on 2014/08/17.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
//

import UIKit
import XCTest

class Tests2_3_1: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
    2.3.1: If `promise` and `x` refer to the same object, reject `promise` with a `TypeError' as the reason.
    */
    /*
    func test2_3_1_via_return_from_a_fulfilled_promise() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        promise.then(
                {(result: String) -> Any in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                    if result == "Hello" {
                        return promise
                    } else {
                        return "World"
                    }
                }
        ).catch(
            {(reason: NSError) -> NSError in
                testReason = reason
                expectation.fulfill()
                return testReason!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(NSError(domain: "Promise.TypeError", code: 1, userInfo: nil), testReason!, "")
            XCTAssertNil(testReason, "")
        })
    }
    */
}