//
//  2.1.3.swift
//  Acom
//
//  Created by yanamura on 2014/08/14.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import UIKit
import XCTest

class Tests2_1_3: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
    2.1.3.1: When rejected, a promise: must not transition to any other state.
    */
    func test2_1_3_1_trying_to_reject_then_immediately_fulfill() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
                resolve(result: "Hello")
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                    XCTFail("")
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(5, dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                    return testReason!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(err, testReason!, "")
            XCTAssertNil(testResult, "")
        })
    }

    func test2_1_3_1_trying_to_reject_then_fulfill_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    reject(reason: err)
                    resolve(result: "Hello")
                })
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                    XCTFail("")
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(5, dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                    return testReason!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(err, testReason!, "")
            XCTAssertNil(testResult, "")
        })
    }

    func test2_1_3_1_trying_to_reject_immediately_then_fulfill_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
                dispatch_async(dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                    XCTFail("")
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(5, dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                    return testReason!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(err, testReason!, "")
            XCTAssertNil(testResult, "")
        })
    }

}
