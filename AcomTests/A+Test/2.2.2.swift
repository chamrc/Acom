//
//  2.2.2.swift
//  Acom
//
//  Created by yanamura on 2014/08/16.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//

import UIKit
import XCTest

class Tests2_2_2: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
    2.2.2: If `onFulfilled` is a function,
    */
    /*
    2.2.2.1: it must be called after `promise` is fulfilled, with `promise`’s fulfillment value as its first argument.
    */
    func test2_2_2_1_() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).then(
                {(result: String) -> Void in
                    XCTAssertEqual("Hello", result, "")
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return testReason!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(testResult, "")
        })
    }

    /*
    2.2.2.2: it must not be called before `promise` is fulfilled
    */
    func test2_2_2_2_fulfilled_after_a_delay() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
            ).then(
                {(result: String) -> Void in
                    XCTAssertEqual("Hello", result, "")
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return testReason!
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(testResult, "")
        })
    }

    func test2_2_2_2_never_fulfilled() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in}
            ).then(
                {(result: String) -> Void in
                    XCTFail("")
                    expectation.fulfill()
                },
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return testReason!
                }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(testResult, "")
        })
    }

    /*
    2.2.2.3: it must not be called more than once.
    */
    func test2_2_2_3_already_fulfilled() {
        let expectation = expectationWithDescription("Promise Test")

        var timesCalled = 0

        let promise = Promise.resolve("Hello").then({(result: String) -> Void in
            timesCalled++
            expectation.fulfill()
            })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_2_3_trying_to_fulfill_a_pending_promise_more_than_once_immediately() {
        let expectation = expectationWithDescription("Promise Test")

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
                resolve(result: "Hello")
            }
            ).then({(result: String) -> Void in
                timesCalled++
                return
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_2_3_trying_to_fulfill_a_pending_promise_more_than_once_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                    resolve(result: "Hello")
                })
            }
            ).then({(result: String) -> Void in
                timesCalled++
                return
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_2_3_trying_to_fulfill_a_pending_promise_more_than_once_immediately_then_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            }
            ).then({(result: String) -> Void in
                timesCalled++
                return
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_2_3_when_multiple_then_calls_are_made_spaced_apart_in_time() {
        let expectation = expectationWithDescription("Promise Test")

        var timesCalled1 = 0
        var timesCalled2 = 0
        var timesCalled3 = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                })
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then({(result: String) -> Void in
                timesCalled1++
                return
            })
            return
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then({(result: String) -> Void in
                timesCalled2++
                return
            })
            return
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then({(result: String) -> Void in
                timesCalled3++
                return
            })
            return
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled1, "")
            XCTAssertEqual(1, timesCalled2, "")
            XCTAssertEqual(1, timesCalled3, "")
        })
    }

}