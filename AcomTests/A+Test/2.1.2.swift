//
//  2.1.2.swift
//  Acom
//
//  Created by yanamura on 2014/08/13.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
//


import UIKit
import XCTest

class Tests2_1_2: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {

        super.tearDown()
    }

    /* 
        2.1.2.1: When fulfilled, a promise: must not transition to any other state.
     */
    func test2_1_2_1_trying_to_fulfill_then_immediately_reject() {
        let expectation = expectationWithDescription("test2_1_2_1_1")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
                reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
            }
        ).then(
            {(result: String) -> Void in
                testResult = result

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    expectation.fulfill()
                })
            },
            {(reason: NSError) -> NSError in
                testReason = reason
                XCTFail("")
                return testReason!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult!, "")
            XCTAssertNil(testReason, "")
        })
    }

    func test2_1_2_1_trying_to_fulfill_then_reject_delayed() {
        let expectation = expectationWithDescription("test2_1_2_1_2")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
                })
            }
        ).then(
            {(result: String) -> Void in
                testResult = result

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    expectation.fulfill()
                })
            },
            {(reason: NSError) -> NSError in
                testReason = reason
                XCTFail("")
                return testReason!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult!, "")
            XCTAssertNil(testReason, "")
        })
    }

    func test2_1_2_1_trying_to_fulfill_immediately_then_reject_delayed() {
        let expectation = expectationWithDescription("test2_1_2_1_3")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
                dispatch_async(dispatch_get_main_queue(), {
                    reject(reason: NSError(domain: "test", code: 1, userInfo: nil))
                })
            }
        ).then(
            {(result: String) -> Void in
                testResult = result
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    expectation.fulfill()
                })
            },
            {(reason: NSError) -> NSError in
                testReason = reason
                XCTFail("")
                return testReason!
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual("Hello", testResult!, "")
            XCTAssertNil(testReason, "")
        })
    }
}
