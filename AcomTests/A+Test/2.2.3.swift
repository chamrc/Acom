//
//  2.2.3.swift
//  Acom
//
//  Created by yanamura on 2014/08/17.
//  Copyright (c) 2014年 Yasuharu Yanamura. All rights reserved.
//


import UIKit
import XCTest

class Tests2_2_3: XCTestCase {
    // MARK: - Setups
    override func setUp() {
        super.setUp()

    }

    override func tearDown() {

        super.tearDown()
    }

    /*
    2.2.3: If `onRejected` is a function
    */
    /*
    2.2.3.1: it must be called after `promise` is rejected, with `promise`’s rejection reason as its first argument.
    */
    func test2_2_3_1() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                },
                {(reason: NSError) -> NSError in
                    XCTAssertEqual(err, reason, "")
                    expectation.fulfill()
                    return err
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(testResult, "")
        })
    }

    /*
    2.2.3.2: it must not be called before `promise` is rejected
    */
    func test2_2_3_2_rejected_after_a_delay() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: err)
                })
            }
            ).then(
                {(result: String) -> Void in
                    testResult = result
                },
                {(reason: NSError) -> NSError in
                    XCTAssertEqual(err, reason, "")
                    expectation.fulfill()
                    return err
                }
        )

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(testResult, "")
        })
    }

    func test2_2_3_2_never_rejected() {
        let expectation = expectationWithDescription("Promise Test")

        var testResult: String?
        var testReason: NSError?

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in}
            ).then(
                {(result: String) -> Void in
                    testResult = result
                },
                {(reason: NSError) -> NSError in
                    XCTFail("")
                    expectation.fulfill()
                    return reason
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
    2.2.3.3: it must not be called more than once.
    */
    func test2_2_3_3_already_rejected() {
        let expectation = expectationWithDescription("Promise Test")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var timesCalled = 0

        //FIXME:
        let promise = Promise<NSError>.reject(err).then(nil,{(reason: NSError) -> NSError in
            timesCalled++
            expectation.fulfill()
            return reason
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_3_3_trying_to_reject_a_pending_promise_more_than_once_immediately() {
        let expectation = expectationWithDescription("Promise Test")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
                reject(reason: err)
            }
            ).then(nil,{(reason: NSError) -> NSError in
                timesCalled++
                return reason
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_3_3_trying_to_reject_a_pending_promise_more_than_once_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: err)
                    reject(reason: err)
                })
            }
            ).then(nil,{(reason: NSError) -> NSError in
                timesCalled++
                return reason
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_3_3_trying_to_reject_a_pending_promise_more_than_once_immediately_then_delayed() {
        let expectation = expectationWithDescription("Promise Test")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var timesCalled = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                reject(reason: err)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: err)
                })
            }
            ).then(nil,{(reason: NSError) -> NSError in
                timesCalled++
                return reason
            })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertEqual(1, timesCalled, "")
        })
    }

    func test2_2_3_3_when_multiple_then_calls_are_made_spaced_apart_in_time() {
        let expectation = expectationWithDescription("Promise Test")

        let err = NSError(domain: "test", code: 1, userInfo: nil)

        var timesCalled1 = 0
        var timesCalled2 = 0
        var timesCalled3 = 0

        let promise = Promise(
            {(resolve: (result: String) -> Void, reject: (reason: NSError) -> Void) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    reject(reason: err)
                })
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then(nil,{(reason: NSError) -> NSError in
                timesCalled1++
                return reason
            })
            return
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then(nil,{(reason: NSError) -> NSError in
                timesCalled2++
                return reason
            })
            return
        })

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            promise.then(nil,{(reason: NSError) -> NSError in
                timesCalled3++
                return reason
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
