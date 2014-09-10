//
//  2.2.1.swift
//  Acom
//
//  Created by yanamura on 2014/08/14.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
//

import UIKit
import XCTest

class Tests2_2_1: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

/*
  2.2.1: Both `onFulfilled` and `onRejected` are optional arguments.
 */
    /*
       2.2.1.1: If `onFulfilled` is not a function, it must be ignored.
    */
    func test2_2_1_1_applied_to_a_directly_rejected_promise() {
        let expectation = expectationWithDescription("test2_2_1_1_1")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
            }
            ).then(
                nil,
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
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

    func test2_2_1_1_applied_to_a_promise_rejected_and_then_chained_off_of() {
        let expectation = expectationWithDescription("test2_2_1_1_2")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
            }
            ).then(
                {(result: String) -> String in
                    return result
                },
                nil
            ).then(
                nil,
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
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

    /*
       2.2.1.2: If `onRejected` is not a function, it must be ignored.
    */
    func test2_2_1_2_applied_to_a_directly_fulfilled_promise() {
        let expectation = expectationWithDescription("test2_2_1_2_1")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                },
                nil
            )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult!, "")
            XCTAssertNil(testReason, "")
        })
    }

    func test2_2_1_2_applied_to_a_promise_fulfilled_and_then_chained_off_of() {
        let expectation = expectationWithDescription("test2_2_1_2_1")

        var testResult: String?
        var testReason: NSError?
        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).then(
                nil,
                {(reason: NSError) -> NSError in
                    testReason = reason
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                    return testReason!
                }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        expectation.fulfill()
                    })
                },
                nil
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult!, "")
            XCTAssertNil(testReason, "")
        })
    }

}