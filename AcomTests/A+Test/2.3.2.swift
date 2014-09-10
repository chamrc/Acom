//
//  2.3.2.swift
//  Acom
//
//  Created by yanamura on 2014/08/17.
//  Copyright (c) 2014 Yasuharu Yanamura. All rights reserved.
//

import Foundation

import UIKit
import XCTest

class Tests2_3_2: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
        2.3.2: If `x` is a promise, adopt its state
    */
    /*
        2.3.2.1: If `x` is pending, `promise` must remain pending until `x` is fulfilled or rejected
    */
    func test2_3_2_1() {
        let expectation = expectationWithDescription("test2_3_2_1")

        var testResult: String?
        var testReason: NSError?

        var wasFulfilled = false
        var wasRejected = false

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        let promise2 = promise.then(
            {(result: String) -> Promise<Any> in
                if result == "Hello" {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                        }
                    )
                } else {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            resolve(result: "World")
                        }
                    )
                }
            }
            )
        promise2.then(
            {(result: Any) -> Void in
                wasFulfilled = true
            }
        ).catch(
            {(reason: NSError) -> NSError in
                wasRejected = true
                return reason
            }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertFalse(wasFulfilled, "")
            XCTAssertFalse(wasRejected, "")
        })
    }

    /*
        2.3.2.2: If/when `x` is fulfilled, fulfill `promise` with the same value
    */
    /*
    func test2_3_2_2() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: Any?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        let promise2 = promise.then(
            {(result: String) -> Promise<Any> in
                if result == "Hello" {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            resolve(result: "HelloWorld")
                        }
                    )
                } else {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            resolve(result: "World")
                        }
                    )
                }
            }
        )
        promise2.then(
            {(result: Any) -> Void in
                testResult = result
            }
            ).catch(
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return reason
                }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            if let result = testResult as? String {
                XCTAssertEqual("HelloWorld", result, "")
            } else {
                XCTFail("")
            }
        })
    }
    */

    /*
        2.3.2.3: If/when `x` is rejected, reject `promise` with the same reason.
    */
    func test2_3_2_3_x_is_already_rejected() {
        let expectation = expectationWithDescription("test2_3_2_3_1")

        var testResult: Any?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        let promise2 = promise.then(
            {(result: String) -> Promise<Any> in
                if result == "Hello" {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            reject(reason: NSError(domain: "hoge", code: 40, userInfo: nil))
                        }
                    )
                } else {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            resolve(result: "World")
                        }
                    )
                }
            }
        )
        promise2.then(
            {(result: Any) -> Void in
                testResult = result
            }
            ).catch(
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return reason
                }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            if let reason = testReason {
                XCTAssertEqual(NSError(domain: "hoge", code: 40, userInfo: nil), reason, "")
            } else {
                XCTFail("")
            }
        })
    }

    func test2_3_2_3_x_is_eventually_rejected() {
        let expectation = expectationWithDescription("test2_3_2_3_2")

        var testResult: Any?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                resolve(result: "Hello")
            }
        )
        let promise2 = promise.then(
            {(result: String) -> Promise<Any> in
                if result == "Hello" {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                                reject(reason: NSError(domain: "hoge", code: 40, userInfo: nil))
                            })
                        }
                    )
                } else {
                    return Promise(
                        {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                            resolve(result: "World")
                        }
                    )
                }
            }
        )
        promise2.then(
            {(result: Any) -> Void in
                testResult = result
            }
            ).catch(
                {(reason: NSError) -> NSError in
                    testReason = reason
                    return reason
                }
        )

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            if let reason = testReason {
                XCTAssertEqual(NSError(domain: "hoge", code: 40, userInfo: nil), reason, "")
            } else {
                XCTFail("")
            }
        })
    }

}