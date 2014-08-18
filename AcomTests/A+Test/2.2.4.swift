//
//  2.2.4.swift
//  Acom
//
//  Created by yanamura on 2014/08/18.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//


import UIKit
import XCTest

class Tests2_2_4: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
        2.2.4: `onFulfilled` or `onRejected` must not be called until the execution context stack contains only platform code
    */
    func test2_2_4_then_returns_before_the_promise_becomes_fulfilled() {
        let expectation = expectationWithDescription("test2_2_4_1")

        var hasReturned = false

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
            ).then(
                {(result: String) -> Void in
                    expectation.fulfill()
                }
        )

        hasReturned = true

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(hasReturned, "")
        })
    }

    func test2_2_4_then_returns_before_the_promise_becomes_rejected() {
        let expectation = expectationWithDescription("test2_2_4_2")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var hasReturned = false

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
            }
            ).then(
                nil,
                {(reason: NSError) -> NSError in
                    expectation.fulfill()
                    return reason
                }
        )

        hasReturned = true

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(hasReturned, "")
        })
    }

    /*
        Clean-stack execution ordering tests (fulfillment case)
    */
    func test2_2_4_when_onFulfilled_is_added_immediately_before_the_promise_is_fulfilled() {
        let expectation = expectationWithDescription("test2_2_4_3")

        var onFulFilledCalled = false
        var resolveHandler: ((result: String) -> Void)?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolveHandler = resolve
            }
            ).then(
                {(result: String) -> Void in
                    onFulFilledCalled = true
                    expectation.fulfill()
                }
        )

        resolveHandler?(result: "Hello")

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onFulFilledCalled, "")
        })
    }

    func test2_2_4_when_onFulfilled_is_added_immediately_after_the_promise_is_fulfilled() {
        let expectation = expectationWithDescription("test2_2_4_4")

        var onFulFilledCalled = false

        let promise = Promise.resolve("Hello")

        promise.then(
                {(result: String) -> Void in
                    onFulFilledCalled = true
                    expectation.fulfill()
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onFulFilledCalled, "")
        })
    }

    func test2_2_4_when_one_onFulfilled_is_added_inside_another_onFulfilled() {
        let expectation = expectationWithDescription("test2_2_4_5")

        var firstOnFulfilledFinished = false

        let promise = Promise.resolve("Hello")

        promise.then(
            {(result: String) -> Void in
                promise.then(
                    {(result: String) -> Void in
                        expectation.fulfill()
                }
                )
                firstOnFulfilledFinished = true
                return
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(firstOnFulfilledFinished, "")
        })
    }

    func test2_2_4_when_onFulfilled_is_added_inside_an_onRejected() {
        let expectation = expectationWithDescription("test2_2_4_6")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var firstOnRejectedFinished = false

        let promise = Promise<NSError>.reject(err)
        let promise2 = Promise.resolve("Hello")

        promise.then(
            nil,
            {(reason: NSError) -> NSError in
                promise2.then(
                    {(result: String) -> Void in
                        expectation.fulfill()
                    }
                )
                firstOnRejectedFinished = true
                return reason
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(firstOnRejectedFinished, "")
        })
    }

    func test2_2_4_when_the_promise_is_fulfilled_asynchronously() {
        let expectation = expectationWithDescription("test2_2_4_7")

        var firstOnFulfilledFinished = false

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    resolve(result: "Hello")
                    firstOnFulfilledFinished = true
                })
            }
        )

        promise.then(
            {(result: String) -> Void in
                expectation.fulfill()
                return
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(firstOnFulfilledFinished, "")
        })
    }

    /*
        Clean-stack execution ordering tests (rejection case)
    */
    func test2_2_4_when_onRejected_is_added_immediately_before_the_promise_is_rejected() {
        let expectation = expectationWithDescription("test2_2_4_8")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var onRejectedCalled = false
        var rejectHandler: ((reason: NSError) -> Void)?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                rejectHandler = reject
            }
            ).then(
                nil,
                {(reason: NSError) -> NSError in
                    onRejectedCalled = true
                    expectation.fulfill()
                    return reason
                }
        )

        rejectHandler?(reason: err)

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onRejectedCalled, "")
        })
    }

    func test2_2_4_when_onRejected_is_added_immediately_after_the_promise_is_rejected() {
        let expectation = expectationWithDescription("test2_2_4_9")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var onRejectedCalled = false


        let promise = Promise<NSError>.reject(err)

        promise.then(
                nil,
                {(reason: NSError) -> NSError in
                    onRejectedCalled = true
                    expectation.fulfill()
                    return reason
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onRejectedCalled, "")
        })
    }

    func test2_2_4_when_onRejected_is_added_inside_an_onFulfilled() {
        let expectation = expectationWithDescription("test2_2_4_10")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var onRejectedCalled = false

        let promise = Promise.resolve("Hello")
        let promise2 = Promise<NSError>.reject(err)

        promise.then(
            {(result: String) -> Void in
                promise2.then(
                    nil,
                    {(reason: NSError) -> NSError in
                        expectation.fulfill()
                        return reason
                })
                onRejectedCalled = true
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onRejectedCalled, "")
        })
    }

    func test2_2_4_when_one_onRejected_is_added_inside_another_onRejected() {
        let expectation = expectationWithDescription("test2_2_4_11")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var onRejectedCalled = false

        let promise = Promise<NSError>.reject(err)

        promise.then(
            nil,
            {(reason: NSError) -> NSError in
                promise.then(
                    nil,
                    {(reason: NSError) -> NSError in
                        expectation.fulfill()
                        return reason
                })
                onRejectedCalled = true
                return reason
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onRejectedCalled, "")
        })
    }

    func test2_2_4_when_the_promise_is_rejected_asynchronously() {
        let expectation = expectationWithDescription("test2_2_4_12")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var onRejectedCalled = false

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    reject(reason: err)
                })
        })

        promise.then(
            nil,
            {(reason: NSError) -> NSError in
                onRejectedCalled = true
                expectation.fulfill()
                return reason
            }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertTrue(onRejectedCalled, "")
        })
    }

}